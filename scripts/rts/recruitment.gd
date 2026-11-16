extends Node3D
## Prototype recruitment: produced weapons become idle soldier actors.
## Selection, movement and combat belong to later phases.
const MapGridScript = preload("res://scripts/rts/map_grid.gd")
const UnitScript = preload("res://scripts/rts/unit.gd")
const TRAIN_SECONDS: float = 5.0
const UNIT_COSTS: Dictionary = {
	&"swordsman": {"swords": 1, "gold": 10},
	&"archer": {"bows": 1, "gold": 10},
	&"crossbowman": {"crossbows": 1, "gold": 15},
}
const UNIT_COLORS: Dictionary = {
	&"swordsman": Color(0.28, 0.42, 0.68),
	&"archer": Color(0.25, 0.52, 0.28),
	&"crossbowman": Color(0.38, 0.32, 0.5),
}

var map_grid: MapGridScript
var construction: Node3D
var queue: Array[StringName] = []
var progress: float = 0.0
var units_spawned: int = 0
var blocked_logged: bool = false

func _ready() -> void:
	print("[RTS Military] Ready: R=swordsman (1 sword + 10 gold), F=archer (1 bow + 10 gold), G=crossbowman (1 crossbow + 15 gold); training 5s each")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("recruit_swordsman"):
		_enqueue(&"swordsman")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("recruit_archer"):
		_enqueue(&"archer")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("recruit_crossbowman"):
		_enqueue(&"crossbowman")
		get_viewport().set_input_as_handled()

func _find_barracks_index() -> int:
	for index in range(construction.buildings.size()):
		if construction.buildings[index]["definition"].id == &"barracks":
			return index
	return -1

func _enqueue(unit_type: StringName) -> void:
	if _find_barracks_index() < 0:
		print("[RTS Military] Recruitment rejected: no barracks")
		return
	var cost: Dictionary = UNIT_COSTS[unit_type]
	for resource_id in cost:
		if int(construction.resources.get(resource_id, 0)) < int(cost[resource_id]):
			print("[RTS Military] Recruitment rejected: insufficient %s" % resource_id)
			return
	# Single debit at queue time, mirroring the production rules.
	for resource_id in cost:
		construction.resources[resource_id] = int(construction.resources[resource_id]) - int(cost[resource_id])
	queue.append(unit_type)
	print("[RTS Military] Queued %s; queue=%d cost=%s resources=%s" % [unit_type, queue.size(), cost, construction.resources])

func _physics_process(delta: float) -> void:
	if queue.is_empty():
		progress = 0.0
		return
	# Do not consume training time without a free spawn cell.
	if _free_cell_near_barracks() == MapGridScript.NO_CELL:
		if not blocked_logged:
			blocked_logged = true
			print("[RTS Military] Training blocked: no free cell near barracks; unit waits")
		return
	blocked_logged = false
	progress += delta
	while progress >= TRAIN_SECONDS and not queue.is_empty():
		progress -= TRAIN_SECONDS
		_spawn(queue.pop_front())

func _free_cell_near_barracks() -> Vector2i:
	var index: int = _find_barracks_index()
	if index < 0:
		return MapGridScript.NO_CELL
	var record: Dictionary = construction.buildings[index]
	var origin: Vector2i = record["cell"]
	var footprint: Vector2i = record["definition"].footprint
	for ring in range(1, 4):
		for z in range(origin.y - ring, origin.y + footprint.y + ring):
			for x in range(origin.x - ring, origin.x + footprint.x + ring):
				if x >= origin.x and x < origin.x + footprint.x and z >= origin.y and z < origin.y + footprint.y:
					continue
				var cell: Vector2i = Vector2i(x, z)
				if _cell_free(cell):
					return cell
	return MapGridScript.NO_CELL

func _cell_free(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= map_grid.grid_size or cell.y >= map_grid.grid_size:
		return false
	if construction.occupied.has(cell):
		return false
	if map_grid.has_tree(cell) or map_grid.has_stone(cell) or map_grid.has_iron(cell):
		return false
	return true

func _spawn(unit_type: StringName) -> void:
	var cell: Vector2i = _free_cell_near_barracks()
	if cell == MapGridScript.NO_CELL:
		print("[RTS Military] Spawn aborted: no free cell")
		return
	var unit: UnitScript = UnitScript.new()
	unit.name = "%s_%d" % [unit_type, units_spawned + 1]
	unit.setup(unit_type, UNIT_COLORS[unit_type])
	unit.position = Vector3((cell.x + 0.5) * map_grid.cell_size, 0.0, (cell.y + 0.5) * map_grid.cell_size)
	units_spawned += 1
	add_child(unit)
	print("[RTS Military] Spawned %s at %s; units=%d" % [unit_type, cell, units_spawned])
