extends Node3D
## Local construction and prototype production state; no physical workers or transport.
const MapGridScript = preload("res://scripts/rts/map_grid.gd")
const Definition = preload("res://scripts/rts/building_definition.gd")
const STOCKPILE: Definition = preload("res://assets/data/buildings/stockpile.tres")
const WHEAT_FARM: Definition = preload("res://assets/data/buildings/wheat_farm.tres")
const MILL: Definition = preload("res://assets/data/buildings/mill.tres")
const BAKERY: Definition = preload("res://assets/data/buildings/bakery.tres")
const GRANARY: Definition = preload("res://assets/data/buildings/granary.tres")
const TREASURY: Definition = preload("res://assets/data/buildings/treasury.tres")
const LUMBERMILL: Definition = preload("res://assets/data/buildings/lumbermill.tres")
const QUARRY: Definition = preload("res://assets/data/buildings/quarry.tres")
const IRON_MINE: Definition = preload("res://assets/data/buildings/iron_mine.tres")
const WEAPONSMITH: Definition = preload("res://assets/data/buildings/weaponsmith.tres")
const BOW_WORKSHOP: Definition = preload("res://assets/data/buildings/bow_workshop.tres")
const FOOD_INTERVAL: float = 10.0
const SOCIETY_INTERVAL: float = 10.0

var map_grid: MapGridScript
var resources: Dictionary = {"wood": 200, "stone": 100, "iron": 100, "food": 100, "gold": 200, "wheat": 0, "flour": 0, "bread": 0, "swords": 0, "bows": 0}
@export_range(0, 100, 1) var worker_pool: int = 3
@export_range(1, 100, 1) var population_capacity: int = 10
var food_elapsed: float = 0.0
var food_access: bool = false
var unfed_residents: int = 0
var meal_served: bool = false
var meal_population: int = 0
var popularity: int = 50
var tax_rate: int = 0
var society_elapsed: float = 0.0
var tax_elapsed: float = 0.0
var treasury_access: bool = false
var occupied: Dictionary = {}
var buildings: Array[Dictionary] = []
var active_definition: Definition
var preview: MeshInstance3D
var preview_material: StandardMaterial3D

func _ready() -> void:
	worker_pool = clampi(worker_pool, 0, population_capacity)
	preview = MeshInstance3D.new()
	preview_material = StandardMaterial3D.new()
	preview_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	preview_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	preview.material_override = preview_material
	preview.visible = false
	add_child(preview)
	print("[RTS Build] Ready: 1=stockpile, 2=wheat farm, 3=mill, 4=bakery, 5=granary, 6=treasury, 7=lumbermill, 8=quarry, 9=iron mine, 0=weaponsmith, B=bow workshop, Esc/RMB=cancel; resources=%s" % resources)
	print("[RTS Food] Residents=%d; waiting for granary; interval=10s" % worker_pool)
	print("[RTS Society] Popularity=50; tax=0; T changes tax; interval=10s")
	print("[RTS Population] Residents=%d capacity=%d; migration thresholds: <40 leave, >=60 arrive" % [worker_pool, population_capacity])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_stockpile"):
		_begin_placement(STOCKPILE)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_wheat_farm"):
		_begin_placement(WHEAT_FARM)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_mill"):
		_begin_placement(MILL)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_bakery"):
		_begin_placement(BAKERY)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_granary"):
		_begin_placement(GRANARY)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_treasury"):
		_begin_placement(TREASURY)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_lumbermill"):
		_begin_placement(LUMBERMILL)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_quarry"):
		_begin_placement(QUARRY)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_iron_mine"):
		_begin_placement(IRON_MINE)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_weaponsmith"):
		_begin_placement(WEAPONSMITH)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_bow_workshop"):
		_begin_placement(BOW_WORKSHOP)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cycle_tax"):
		tax_rate = (tax_rate + 1) % 3
		print("[RTS Society] Tax rate=%d gold/resident; treasury access=%s" % [tax_rate, treasury_access])
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("build_cancel") and active_definition != null:
		active_definition = null
		preview.visible = false
		print("[RTS Build] Placement cancelled")
		get_viewport().set_input_as_handled()

func _begin_placement(definition: Definition) -> void:
	active_definition = definition
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(definition.footprint.x * map_grid.cell_size, definition.height, definition.footprint.y * map_grid.cell_size)
	preview.mesh = box
	print("[RTS Build] Mode=%s footprint=%s cost=%s" % [definition.id, definition.footprint, definition.cost])
	_update_preview()

func placement_error(cell: Vector2i, definition: Definition) -> String:
	if cell.x < 0 or cell.y < 0 or cell.x + definition.footprint.x > map_grid.grid_size or cell.y + definition.footprint.y > map_grid.grid_size:
		return "outside map"
	for z in range(cell.y, cell.y + definition.footprint.y):
		for x in range(cell.x, cell.x + definition.footprint.x):
			var tile: Vector2i = Vector2i(x, z)
			if occupied.has(tile):
				return "occupied cells"
			if map_grid.has_tree(tile):
				return "tree blocks construction"
			if map_grid.has_stone(tile):
				return "stone deposit blocks construction"
			if map_grid.has_iron(tile):
				return "iron deposit blocks construction"
			var kind: int = map_grid.terrain[z * map_grid.grid_size + x]
			if not definition.allowed_terrain.has(kind):
				return "unsuitable terrain"
	for resource_id in definition.cost:
		if int(resources.get(resource_id, 0)) < int(definition.cost[resource_id]):
			return "insufficient %s" % resource_id
	return ""

func _building_center(cell: Vector2i, definition: Definition) -> Vector3:
	return Vector3((cell.x + definition.footprint.x * 0.5) * map_grid.cell_size, definition.height * 0.5 + 0.08, (cell.y + definition.footprint.y * 0.5) * map_grid.cell_size)

func _update_preview() -> void:
	if active_definition == null or not is_instance_valid(map_grid):
		preview.visible = false
		return
	var cell: Vector2i = map_grid.cell_at_screen(get_viewport().get_mouse_position())
	preview.visible = cell != MapGridScript.NO_CELL
	if not preview.visible:
		return
	preview.position = _building_center(cell, active_definition)
	if placement_error(cell, active_definition).is_empty():
		preview_material.albedo_color = Color(0.2, 1.0, 0.35, 0.45)
	else:
		preview_material.albedo_color = Color(1.0, 0.15, 0.1, 0.5)

func _process(_delta: float) -> void:
	_update_preview()

func try_place(cell: Vector2i) -> void:
	if active_definition == null:
		return
	# Revalidate at click time, never trust the preview from a previous frame.
	var reason: String = placement_error(cell, active_definition)
	if not reason.is_empty():
		print("[RTS Build] Rejected %s at %s: %s" % [active_definition.id, cell, reason])
		return
	var building: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(active_definition.footprint.x * map_grid.cell_size * 0.94, active_definition.height, active_definition.footprint.y * map_grid.cell_size * 0.94)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = active_definition.color
	material.roughness = 1.0
	box.material = material
	building.mesh = box
	building.position = _building_center(cell, active_definition)
	building.name = "%s_%d" % [active_definition.id, buildings.size()]
	# Synchronous commit: no yield between validation, payment and occupancy.
	for resource_id in active_definition.cost:
		resources[resource_id] = int(resources[resource_id]) - int(active_definition.cost[resource_id])
	for z in range(cell.y, cell.y + active_definition.footprint.y):
		for x in range(cell.x, cell.x + active_definition.footprint.x):
			occupied[Vector2i(x, z)] = buildings.size()
	buildings.append({"definition": active_definition, "cell": cell, "workers": 0, "progress": 0.0, "cycle_active": false, "production_state": ""})
	add_child(building)
	_assign_workers()
	print("[RTS Build] Placed %s at %s; buildings=%d resources=%s" % [active_definition.id, cell, buildings.size(), resources])
	_update_preview()

func _assign_workers() -> void:
	# Stable construction order; assign complete crews, not partial crews.
	var available: int = worker_pool
	for index in range(buildings.size()):
		var record: Dictionary = buildings[index]
		var definition: Definition = record["definition"]
		var assigned: int = definition.workers_required if available >= definition.workers_required else 0
		var previous: int = int(record["workers"])
		record["workers"] = assigned
		available -= assigned
		if previous != assigned:
			print("[RTS Economy] %s #%d workers=%d -> %d; available=%d" % [definition.id, index, previous, assigned, available])

func _physics_process(delta: float) -> void:
	var has_stockpile: bool = false
	var has_granary: bool = false
	var has_treasury: bool = false
	for record in buildings:
		var definition: Definition = record["definition"]
		if definition.id == &"stockpile":
			has_stockpile = true
		elif definition.id == &"granary":
			has_granary = true
		elif definition.id == &"treasury":
			has_treasury = true
	var produced: Dictionary = {}
	for index in range(buildings.size()):
		var record: Dictionary = buildings[index]
		var definition: Definition = record["definition"]
		if definition.output_resource.is_empty() or definition.output_amount <= 0:
			continue
		var state: String = "working"
		if int(record["workers"]) < definition.workers_required:
			state = "waiting for workers"
		elif definition.requires_stockpile and not has_stockpile:
			state = "waiting for stockpile"
		elif definition.requires_granary and not has_granary:
			state = "waiting for granary"
		if state == "working":
			var remaining: float = delta
			var duration: float = maxf(definition.cycle_seconds, 0.1)
			while remaining > 0.0:
				if not bool(record["cycle_active"]):
					# Validate all inputs before committing any debit.
					for resource_id in definition.input_cost:
						if int(resources.get(resource_id, 0)) < int(definition.input_cost[resource_id]):
							state = "waiting for %s" % resource_id
							break
					if state != "working":
						break
					if definition.wood_gather_radius > 0:
						var origin: Vector2i = record["cell"]
						var center: Vector2 = Vector2(origin) + Vector2(definition.footprint) * 0.5
						if map_grid.reserve_tree_wood(center, definition.wood_gather_radius, definition.output_amount) == MapGridScript.NO_CELL:
							state = "waiting for trees"
							break
					if definition.stone_gather_radius > 0:
						var origin: Vector2i = record["cell"]
						var center: Vector2 = Vector2(origin) + Vector2(definition.footprint) * 0.5
						if map_grid.reserve_stone(center, definition.stone_gather_radius, definition.output_amount) == MapGridScript.NO_CELL:
							state = "waiting for stone deposits"
							break
					if definition.iron_gather_radius > 0:
						var origin: Vector2i = record["cell"]
						var center: Vector2 = Vector2(origin) + Vector2(definition.footprint) * 0.5
						if map_grid.reserve_iron(center, definition.iron_gather_radius, definition.output_amount) == MapGridScript.NO_CELL:
							state = "waiting for iron deposits"
							break
					for resource_id in definition.input_cost:
						resources[resource_id] = int(resources[resource_id]) - int(definition.input_cost[resource_id])
					if not definition.input_cost.is_empty():
						print("[RTS Economy] %s #%d cycle started; consumed=%s" % [definition.id, index, definition.input_cost])
					record["cycle_active"] = true
					record["progress"] = 0.0
				var step: float = minf(remaining, duration - float(record["progress"]))
				record["progress"] = float(record["progress"]) + step
				remaining -= step
				if float(record["progress"]) >= duration:
					var resource_id: String = definition.output_resource
					resources[resource_id] = int(resources.get(resource_id, 0)) + definition.output_amount
					produced[resource_id] = int(produced.get(resource_id, 0)) + definition.output_amount
					record["cycle_active"] = false
					record["progress"] = 0.0
		if record["production_state"] != state:
			record["production_state"] = state
			print("[RTS Economy] %s #%d: %s" % [definition.id, index, state])
	if not produced.is_empty():
		print("[RTS Economy] Produced=%s; resources=%s" % [produced, resources])
	_update_food(delta, has_granary)
	_update_society(delta, has_granary, has_treasury)

func _update_food(delta: float, has_granary: bool) -> void:
	if food_access != has_granary:
		food_access = has_granary
		print("[RTS Food] Granary access=%s" % food_access)
	if not has_granary or worker_pool <= 0:
		food_elapsed = 0.0
		unfed_residents = 0
		meal_served = false
		meal_population = 0
		return
	food_elapsed += delta
	while food_elapsed >= FOOD_INTERVAL:
		food_elapsed -= FOOD_INTERVAL
		var bread_used: int = mini(worker_pool, int(resources["bread"]))
		var food_used: int = mini(worker_pool - bread_used, int(resources["food"]))
		resources["bread"] = int(resources["bread"]) - bread_used
		resources["food"] = int(resources["food"]) - food_used
		unfed_residents = worker_pool - bread_used - food_used
		meal_served = true
		meal_population = worker_pool
		print("[RTS Food] Meal: residents=%d bread=%d food=%d unfed=%d; remaining bread=%d food=%d" % [worker_pool, bread_used, food_used, unfed_residents, resources["bread"], resources["food"]])

func _update_society(delta: float, has_granary: bool, has_treasury: bool) -> void:
	if treasury_access != has_treasury:
		treasury_access = has_treasury
		print("[RTS Society] Treasury access=%s" % treasury_access)
	if not has_treasury or worker_pool <= 0:
		tax_elapsed = 0.0
	else:
		tax_elapsed += delta
		while tax_elapsed >= SOCIETY_INTERVAL:
			tax_elapsed -= SOCIETY_INTERVAL
			var income: int = worker_pool * tax_rate
			resources["gold"] = int(resources["gold"]) + income
			print("[RTS Society] Tax collected=%d rate=%d residents=%d gold=%d" % [income, tax_rate, worker_pool, resources["gold"]])
	society_elapsed += delta
	while society_elapsed >= SOCIETY_INTERVAL:
		society_elapsed -= SOCIETY_INTERVAL
		if worker_pool <= 0:
			continue
		var food_modifier: int = 0
		if not has_granary:
			food_modifier = -4
		elif meal_served:
			if unfed_residents == 0:
				food_modifier = 2
			else:
				food_modifier = -ceili(4.0 * unfed_residents / maxi(meal_population, 1))
		var tax_modifier: int = -2 * tax_rate if has_treasury else 0
		popularity = clampi(popularity + food_modifier + tax_modifier, 0, 100)
		print("[RTS Society] Popularity=%d food=%d taxes=%d" % [popularity, food_modifier, tax_modifier])
		var previous_population: int = worker_pool
		if popularity >= 60 and worker_pool < population_capacity:
			worker_pool += 1
		elif popularity < 40 and worker_pool > 1:
			worker_pool -= 1
		if previous_population != worker_pool:
			print("[RTS Population] Residents=%d -> %d capacity=%d popularity=%d" % [previous_population, worker_pool, population_capacity, popularity])
			_assign_workers()
