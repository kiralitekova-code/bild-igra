extends Node3D
## Grid state is independent of render nodes; flat terrain picking needs no physics bodies.
signal cell_selected(cell: Vector2i, terrain_type: int)

enum Terrain { SAND, FERTILE, ROCK }
const NO_CELL: Vector2i = Vector2i(-1, -1)
const COLORS: Array[Color] = [Color(0.67, 0.53, 0.32), Color(0.38, 0.49, 0.27), Color(0.47, 0.45, 0.41)]

@export_range(8, 128, 1) var grid_size: int = 64
@export var cell_size: float = 2.0
@export var map_seed: int = 7319

var terrain: PackedByteArray = PackedByteArray()
var active_camera: Camera3D
var hovered_cell: Vector2i = NO_CELL
var selected_cell: Vector2i = NO_CELL
var hover_marker: MeshInstance3D
var selected_marker: MeshInstance3D
var tree_wood: PackedInt32Array = PackedInt32Array()
var tree_instances: MultiMesh
var tree_indices: Dictionary = {}
var deposit_stone: PackedInt32Array = PackedInt32Array()
var stone_instances: MultiMesh
var stone_indices: Dictionary = {}
var deposit_iron: PackedInt32Array = PackedInt32Array()
var iron_instances: MultiMesh
var iron_indices: Dictionary = {}

func _ready() -> void:
	_generate_map()
	_generate_trees()
	_generate_stone()
	_generate_iron()
	_draw_grid()
	hover_marker = _make_marker(Color(1.0, 0.88, 0.25, 0.55), 0.05)
	selected_marker = _make_marker(Color(0.15, 0.8, 1.0, 0.65), 0.035)
	print("[RTS Map] Generated %dx%d, seed=%d, cells=%d" % [grid_size, grid_size, map_seed, terrain.size()])

func get_extent() -> float:
	return grid_size * cell_size

func _generate_map() -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = map_seed
	noise.frequency = 0.06
	terrain.resize(grid_size * grid_size)
	var tile: PlaneMesh = PlaneMesh.new()
	tile.size = Vector2(cell_size, cell_size)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	tile.material = material
	var instances: MultiMesh = MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	instances.use_colors = true
	instances.mesh = tile
	instances.instance_count = terrain.size()
	for z in range(grid_size):
		for x in range(grid_size):
			var index: int = z * grid_size + x
			var value: float = noise.get_noise_2d(float(x), float(z))
			var kind: int = Terrain.SAND
			if value > 0.23:
				kind = Terrain.ROCK
			elif value < -0.16:
				kind = Terrain.FERTILE
			terrain[index] = kind
			var center: Vector3 = Vector3((x + 0.5) * cell_size, 0.0, (z + 0.5) * cell_size)
			instances.set_instance_transform(index, Transform3D(Basis.IDENTITY, center))
			instances.set_instance_color(index, COLORS[kind])
	var tiles: MultiMeshInstance3D = MultiMeshInstance3D.new()
	tiles.name = "TerrainTiles"
	tiles.multimesh = instances
	add_child(tiles)

func _generate_trees() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = map_seed + 103
	tree_wood.resize(grid_size * grid_size)
	var cells: Array[Vector2i] = []
	for z in range(grid_size):
		for x in range(grid_size):
			var index: int = z * grid_size + x
			var chance: float = rng.randf()
			var central: bool = x >= grid_size / 2 - 4 and x < grid_size / 2 + 4 and z >= grid_size / 2 - 4 and z < grid_size / 2 + 4
			if terrain[index] != Terrain.ROCK and not central and chance < 0.07:
				tree_wood[index] = 24
				cells.append(Vector2i(x, z))
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(cell_size * 0.65, 3.0, cell_size * 0.65)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.34, 0.13)
	material.roughness = 1.0
	mesh.material = material
	tree_instances = MultiMesh.new()
	tree_instances.transform_format = MultiMesh.TRANSFORM_3D
	tree_instances.mesh = mesh
	tree_instances.instance_count = cells.size()
	for i in range(cells.size()):
		var cell: Vector2i = cells[i]
		tree_indices[cell] = i
		tree_instances.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3((cell.x + 0.5) * cell_size, 1.5, (cell.y + 0.5) * cell_size)))
	var trees: MultiMeshInstance3D = MultiMeshInstance3D.new()
	trees.name = "Trees"
	trees.multimesh = tree_instances
	add_child(trees)
	print("[RTS Wood] Generated trees=%d total wood=%d seed=%d" % [cells.size(), cells.size() * 24, map_seed])

func has_tree(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size and cell.y < grid_size and tree_wood[cell.y * grid_size + cell.x] > 0

func reserve_tree_wood(center: Vector2, radius: int, amount: int) -> Vector2i:
	# Scan only the gathering radius, not the entire map each physics tick.
	var nearest: Vector2i = NO_CELL
	var nearest_distance: float = INF
	for z in range(maxi(0, floori(center.y - radius)), mini(grid_size, ceili(center.y + radius))):
		for x in range(maxi(0, floori(center.x - radius)), mini(grid_size, ceili(center.x + radius))):
			if tree_wood[z * grid_size + x] < amount:
				continue
			var distance: float = center.distance_squared_to(Vector2(x + 0.5, z + 0.5))
			if distance <= radius * radius and distance < nearest_distance:
				nearest = Vector2i(x, z)
				nearest_distance = distance
	if nearest == NO_CELL:
		return NO_CELL
	var index: int = nearest.y * grid_size + nearest.x
	tree_wood[index] -= amount
	print("[RTS Wood] Reserved=%d tree=%s remaining=%d" % [amount, nearest, tree_wood[index]])
	if tree_wood[index] == 0:
		# Hide only this instance, preserving the authored transforms of others.
		tree_instances.set_instance_transform(int(tree_indices[nearest]), Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO))
		print("[RTS Wood] Tree depleted at %s; cell released" % nearest)
	return nearest

func _generate_stone() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = map_seed + 211
	deposit_stone.resize(grid_size * grid_size)
	var cells: Array[Vector2i] = []
	for z in range(grid_size):
		for x in range(grid_size):
			var chance: float = rng.randf()
			var index: int = z * grid_size + x
			if terrain[index] == Terrain.ROCK and chance < 0.25:
				deposit_stone[index] = 48
				cells.append(Vector2i(x, z))
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(cell_size * 0.8, 1.2, cell_size * 0.8)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.72, 0.75)
	material.roughness = 1.0
	mesh.material = material
	stone_instances = MultiMesh.new()
	stone_instances.transform_format = MultiMesh.TRANSFORM_3D
	stone_instances.mesh = mesh
	stone_instances.instance_count = cells.size()
	for i in range(cells.size()):
		var cell: Vector2i = cells[i]
		stone_indices[cell] = i
		stone_instances.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3((cell.x + 0.5) * cell_size, 0.6, (cell.y + 0.5) * cell_size)))
	var deposits: MultiMeshInstance3D = MultiMeshInstance3D.new()
	deposits.name = "StoneDeposits"
	deposits.multimesh = stone_instances
	add_child(deposits)
	print("[RTS Stone] Generated deposits=%d total stone=%d seed=%d" % [cells.size(), cells.size() * 48, map_seed])

func has_stone(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size and cell.y < grid_size and deposit_stone[cell.y * grid_size + cell.x] > 0

func reserve_stone(center: Vector2, radius: int, amount: int) -> Vector2i:
	var nearest: Vector2i = NO_CELL
	var nearest_distance: float = INF
	for z in range(maxi(0, floori(center.y - radius)), mini(grid_size, ceili(center.y + radius))):
		for x in range(maxi(0, floori(center.x - radius)), mini(grid_size, ceili(center.x + radius))):
			if deposit_stone[z * grid_size + x] < amount:
				continue
			var distance: float = center.distance_squared_to(Vector2(x + 0.5, z + 0.5))
			if distance <= radius * radius and distance < nearest_distance:
				nearest = Vector2i(x, z)
				nearest_distance = distance
	if nearest == NO_CELL:
		return NO_CELL
	var index: int = nearest.y * grid_size + nearest.x
	deposit_stone[index] -= amount
	print("[RTS Stone] Reserved=%d deposit=%s remaining=%d" % [amount, nearest, deposit_stone[index]])
	if deposit_stone[index] == 0:
		stone_instances.set_instance_transform(int(stone_indices[nearest]), Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO))
		print("[RTS Stone] Deposit depleted at %s; rock terrain unchanged" % nearest)
	return nearest

func _generate_iron() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = map_seed + 307
	deposit_iron.resize(grid_size * grid_size)
	var cells: Array[Vector2i] = []
	for z in range(grid_size):
		for x in range(grid_size):
			var chance: float = rng.randf()
			var index: int = z * grid_size + x
			if terrain[index] == Terrain.ROCK and deposit_stone[index] == 0 and chance < 0.15:
				deposit_iron[index] = 36
				cells.append(Vector2i(x, z))
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(cell_size * 0.7, 1.6, cell_size * 0.7)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.25, 0.12)
	material.roughness = 1.0
	mesh.material = material
	iron_instances = MultiMesh.new()
	iron_instances.transform_format = MultiMesh.TRANSFORM_3D
	iron_instances.mesh = mesh
	iron_instances.instance_count = cells.size()
	for i in range(cells.size()):
		var cell: Vector2i = cells[i]
		iron_indices[cell] = i
		iron_instances.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3((cell.x + 0.5) * cell_size, 0.8, (cell.y + 0.5) * cell_size)))
	var deposits: MultiMeshInstance3D = MultiMeshInstance3D.new()
	deposits.name = "IronDeposits"
	deposits.multimesh = iron_instances
	add_child(deposits)
	print("[RTS Iron] Generated deposits=%d total iron=%d seed=%d" % [cells.size(), cells.size() * 36, map_seed])

func has_iron(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size and cell.y < grid_size and deposit_iron[cell.y * grid_size + cell.x] > 0

func reserve_iron(center: Vector2, radius: int, amount: int) -> Vector2i:
	var nearest: Vector2i = NO_CELL
	var nearest_distance: float = INF
	for z in range(maxi(0, floori(center.y - radius)), mini(grid_size, ceili(center.y + radius))):
		for x in range(maxi(0, floori(center.x - radius)), mini(grid_size, ceili(center.x + radius))):
			if deposit_iron[z * grid_size + x] < amount:
				continue
			var distance: float = center.distance_squared_to(Vector2(x + 0.5, z + 0.5))
			if distance <= radius * radius and distance < nearest_distance:
				nearest = Vector2i(x, z)
				nearest_distance = distance
	if nearest == NO_CELL:
		return NO_CELL
	var index: int = nearest.y * grid_size + nearest.x
	deposit_iron[index] -= amount
	print("[RTS Iron] Reserved=%d deposit=%s remaining=%d" % [amount, nearest, deposit_iron[index]])
	if deposit_iron[index] == 0:
		iron_instances.set_instance_transform(int(iron_indices[nearest]), Transform3D(Basis.IDENTITY.scaled(Vector3.ZERO), Vector3.ZERO))
		print("[RTS Iron] Deposit depleted at %s; rock terrain unchanged" % nearest)
	return nearest

func _draw_grid() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.25, 0.23, 0.18)
	var mesh: ImmediateMesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	var extent: float = get_extent()
	for i in range(grid_size + 1):
		var coordinate: float = i * cell_size
		mesh.surface_add_vertex(Vector3(coordinate, 0.025, 0.0))
		mesh.surface_add_vertex(Vector3(coordinate, 0.025, extent))
		mesh.surface_add_vertex(Vector3(0.0, 0.025, coordinate))
		mesh.surface_add_vertex(Vector3(extent, 0.025, coordinate))
	mesh.surface_end()
	var lines: MeshInstance3D = MeshInstance3D.new()
	lines.name = "GridLines"
	lines.mesh = mesh
	add_child(lines)

func _make_marker(color: Color, height: float) -> MeshInstance3D:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(cell_size * 0.92, cell_size * 0.92)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	plane.material = material
	var marker: MeshInstance3D = MeshInstance3D.new()
	marker.mesh = plane
	marker.position.y = height
	marker.visible = false
	add_child(marker)
	return marker

func cell_at_screen(screen_position: Vector2) -> Vector2i:
	if not is_instance_valid(active_camera):
		return NO_CELL
	if not get_viewport().get_visible_rect().has_point(screen_position):
		return NO_CELL
	var origin: Vector3 = active_camera.project_ray_origin(screen_position)
	var direction: Vector3 = active_camera.project_ray_normal(screen_position)
	var intersection: Variant = Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)
	if intersection == null:
		return NO_CELL
	var point: Vector3 = intersection
	var cell: Vector2i = Vector2i(floori(point.x / cell_size), floori(point.z / cell_size))
	if cell.x < 0 or cell.y < 0 or cell.x >= grid_size or cell.y >= grid_size:
		return NO_CELL
	return cell

func _place_marker(marker: MeshInstance3D, cell: Vector2i) -> void:
	marker.visible = cell != NO_CELL
	if marker.visible:
		marker.position.x = (cell.x + 0.5) * cell_size
		marker.position.z = (cell.y + 0.5) * cell_size

func _process(_delta: float) -> void:
	hovered_cell = cell_at_screen(get_viewport().get_mouse_position())
	_place_marker(hover_marker, hovered_cell)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected_cell = cell_at_screen(event.position)
		_place_marker(selected_marker, selected_cell)
		var kind: int = -1
		if selected_cell != NO_CELL:
			kind = terrain[selected_cell.y * grid_size + selected_cell.x]
		cell_selected.emit(selected_cell, kind)
		get_viewport().set_input_as_handled()
