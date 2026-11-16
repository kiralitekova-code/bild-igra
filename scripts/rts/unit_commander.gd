extends Node3D
## Selection (click and drag rectangle) and mass movement orders for prototype units.
const MapGridScript = preload("res://scripts/rts/map_grid.gd")
const CLICK_RADIUS_PIXELS: float = 8.0
const PICK_RADIUS_PIXELS: float = 28.0

var map_grid: MapGridScript
var construction: Node3D
var astar: AStarGrid2D = AStarGrid2D.new()
var drag_active: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_rect: MeshInstance3D
var drag_rect_mesh: ImmediateMesh

func _ready() -> void:
	drag_rect = MeshInstance3D.new()
	drag_rect_mesh = ImmediateMesh.new()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.15, 0.8, 1.0, 0.8)
	drag_rect.mesh = drag_rect_mesh
	drag_rect.material_override = material
	drag_rect.visible = false
	add_child(drag_rect)
	print("[RTS Units] Ready: LMB select, drag = box select, RMB = move order (AStarGrid2D)")

func _selected_units() -> Array:
	var result: Array = []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.selected:
			result.append(unit)
	return result

func _unhandled_input(event: InputEvent) -> void:
	if construction.active_definition != null:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_active = true
				drag_start = event.position
			elif drag_active:
				drag_active = false
				drag_rect.visible = false
				if (event.position - drag_start).length() < CLICK_RADIUS_PIXELS:
					_click_select(event.position)
				else:
					_box_select(drag_start, event.position)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_order_move(event.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and drag_active:
		_update_drag_rect(event.position)

func _click_select(screen_position: Vector2) -> void:
	var camera: Camera3D = map_grid.active_camera
	if camera == null:
		return
	var picked: Node = null
	var best: float = PICK_RADIUS_PIXELS
	for unit in get_tree().get_nodes_in_group("units"):
		var anchor: Vector3 = unit.global_position + Vector3(0.0, 0.6, 0.0)
		if camera.is_position_behind(anchor):
			continue
		var distance: float = camera.unproject_position(anchor).distance_to(screen_position)
		if distance < best:
			best = distance
			picked = unit
	_set_selection([picked] if picked != null else [])

func _box_select(from: Vector2, to: Vector2) -> void:
	var camera: Camera3D = map_grid.active_camera
	if camera == null:
		return
	var rect: Rect2 = Rect2(Vector2(minf(from.x, to.x), minf(from.y, to.y)), (to - from).abs())
	var matches: Array = []
	for unit in get_tree().get_nodes_in_group("units"):
		var anchor: Vector3 = unit.global_position + Vector3(0.0, 0.6, 0.0)
		if camera.is_position_behind(anchor):
			continue
		if rect.has_point(camera.unproject_position(anchor)):
			matches.append(unit)
	_set_selection(matches)

func _set_selection(units: Array) -> void:
	for unit in get_tree().get_nodes_in_group("units"):
		unit.selected = units.has(unit)
	print("[RTS Units] Selected %d unit(s)" % units.size())

func _order_move(screen_position: Vector2) -> void:
	var units: Array = _selected_units()
	if units.is_empty():
		return
	var target: Vector2i = map_grid.cell_at_screen(screen_position)
	if target == MapGridScript.NO_CELL:
		print("[RTS Units] Move rejected: outside the map")
		return
	_rebuild_astar()
	var destination: Vector2i = _nearest_free_cell(target)
	if destination == MapGridScript.NO_CELL:
		print("[RTS Units] Move rejected: destination fully blocked")
		return
	var destinations: Array[Vector2i] = _gather_destinations(destination, units.size())
	var ordered: int = 0
	for i in range(units.size()):
		var unit: Node = units[i]
		var goal: Vector2i = destinations[i % destinations.size()]
		var start_cell: Vector2i = _unit_cell(unit)
		if start_cell == MapGridScript.NO_CELL or start_cell == goal:
			continue
		if astar.is_point_solid(start_cell):
			start_cell = _nearest_free_cell(start_cell)
			if start_cell == MapGridScript.NO_CELL or start_cell == goal:
				continue
		var points: PackedVector2Array = astar.get_point_path(start_cell, goal)
		var waypoints: PackedVector3Array = PackedVector3Array()
		for point in points:
			waypoints.append(Vector3(point.x, 0.0, point.y))
		if not waypoints.is_empty():
			var feet: Vector3 = Vector3(unit.global_position.x, 0.0, unit.global_position.z)
			if waypoints[0].distance_to(feet) < map_grid.cell_size * 0.5:
				waypoints.remove_at(0)
		if waypoints.is_empty():
			continue
		unit.order_path(waypoints)
		ordered += 1
	print("[RTS Units] Move order: %d/%d unit(s) -> %s" % [ordered, units.size(), destination])

func _unit_cell(unit: Node) -> Vector2i:
	var cell: Vector2i = Vector2i(floori(unit.global_position.x / map_grid.cell_size), floori(unit.global_position.z / map_grid.cell_size))
	if cell.x < 0 or cell.y < 0 or cell.x >= map_grid.grid_size or cell.y >= map_grid.grid_size:
		return MapGridScript.NO_CELL
	return cell

func _rebuild_astar() -> void:
	astar.region = Rect2i(0, 0, map_grid.grid_size, map_grid.grid_size)
	astar.cell_size = Vector2(map_grid.cell_size, map_grid.cell_size)
	astar.offset = Vector2(map_grid.cell_size * 0.5, map_grid.cell_size * 0.5)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	for z in range(map_grid.grid_size):
		for x in range(map_grid.grid_size):
			var cell: Vector2i = Vector2i(x, z)
			if not _cell_free(cell):
				astar.set_point_solid(cell, true)

func _nearest_free_cell(cell: Vector2i) -> Vector2i:
	if _cell_free(cell):
		return cell
	for ring in range(1, 7):
		for z in range(cell.y - ring, cell.y + ring + 1):
			for x in range(cell.x - ring, cell.x + ring + 1):
				if absi(x - cell.x) != ring and absi(z - cell.y) != ring:
					continue
				var candidate: Vector2i = Vector2i(x, z)
				if _cell_free(candidate):
					return candidate
	return MapGridScript.NO_CELL

func _cell_free(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= map_grid.grid_size or cell.y >= map_grid.grid_size:
		return false
	if construction.occupied.has(cell):
		return false
	if map_grid.has_tree(cell) or map_grid.has_stone(cell) or map_grid.has_iron(cell):
		return false
	return true

func _gather_destinations(center: Vector2i, count: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = [center]
	if count <= 1:
		return result
	for ring in range(1, 8):
		for z in range(center.y - ring, center.y + ring + 1):
			for x in range(center.x - ring, center.x + ring + 1):
				if absi(x - center.x) != ring and absi(z - center.y) != ring:
					continue
				var candidate: Vector2i = Vector2i(x, z)
				if _cell_free(candidate):
					result.append(candidate)
					if result.size() >= count:
						return result
	return result

func _update_drag_rect(current: Vector2) -> void:
	var begin: Variant = _ground_point(drag_start)
	var end: Variant = _ground_point(current)
	if begin == null or end == null:
		drag_rect.visible = false
		return
	var a: Vector3 = begin
	var b: Vector3 = end
	drag_rect.visible = true
	drag_rect_mesh.clear_surfaces()
	drag_rect_mesh.surface_begin(Mesh.PRIMITIVE_LINE_LOOP)
	drag_rect_mesh.surface_add_vertex(Vector3(a.x, 0.05, a.z))
	drag_rect_mesh.surface_add_vertex(Vector3(a.x, 0.05, b.z))
	drag_rect_mesh.surface_add_vertex(Vector3(b.x, 0.05, b.z))
	drag_rect_mesh.surface_add_vertex(Vector3(b.x, 0.05, a.z))
	drag_rect_mesh.surface_end()

func _ground_point(screen_position: Vector2) -> Variant:
	var camera: Camera3D = map_grid.active_camera
	if camera == null:
		return null
	var origin: Vector3 = camera.project_ray_origin(screen_position)
	var direction: Vector3 = camera.project_ray_normal(screen_position)
	return Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)
