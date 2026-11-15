extends Resource
## Prototype building data, independent of the renderer and input.
@export var id: StringName
@export var display_name: String = ""
@export var footprint: Vector2i = Vector2i(2, 2)
@export var cost: Dictionary = {}
@export var allowed_terrain: PackedInt32Array = PackedInt32Array([0, 1])
@export var color: Color = Color.WHITE
@export var height: float = 2.0
@export_range(0, 10, 1) var workers_required: int = 0
@export var output_resource: String = ""
@export_range(0, 100, 1) var output_amount: int = 0
@export_range(0.1, 120.0, 0.1) var cycle_seconds: float = 5.0
@export var requires_stockpile: bool = false
@export var requires_granary: bool = false
@export var input_cost: Dictionary = {}
@export_range(0, 32, 1) var wood_gather_radius: int = 0
@export_range(0, 32, 1) var stone_gather_radius: int = 0
@export_range(0, 32, 1) var iron_gather_radius: int = 0
