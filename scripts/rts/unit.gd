extends Node3D
## Prototype soldier actor: primitive body, selection ring and follow-path movement.
## Combat, morale and formation spacing come later.
const BODY_HEIGHT: float = 1.1
const ARRIVE_DISTANCE: float = 0.2
const HIT_POINTS: Dictionary = {&"swordsman": 30, &"archer": 20, &"crossbowman": 20}

var unit_type: StringName = &"swordsman"
var hit_points: int = 30
var move_speed: float = 6.0
var path: PackedVector3Array = PackedVector3Array()
var selection_ring: MeshInstance3D
var selected: bool = false:
	set(value):
		selected = value
		if selection_ring != null:
			selection_ring.visible = value

func setup(type: StringName, color: Color) -> void:
	unit_type = type
	hit_points = int(HIT_POINTS.get(type, 20))
	var body: MeshInstance3D = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.28
	capsule.height = BODY_HEIGHT
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	capsule.material = material
	body.mesh = capsule
	body.position.y = BODY_HEIGHT * 0.5
	add_child(body)

func _ready() -> void:
	add_to_group("units")
	if get_child_count() == 0:
		setup(unit_type, Color(0.28, 0.42, 0.68))
	_build_selection_ring()

func _build_selection_ring() -> void:
	selection_ring = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.32
	torus.outer_radius = 0.4
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.15, 0.8, 1.0, 0.9)
	torus.material = material
	selection_ring.mesh = torus
	selection_ring.position.y = 0.06
	selection_ring.visible = false
	add_child(selection_ring)

func order_path(points: PackedVector3Array) -> void:
	path = points

func _physics_process(delta: float) -> void:
	if path.is_empty():
		return
	var target: Vector3 = path[0]
	var to_target: Vector3 = target - global_position
	to_target.y = 0.0
	var step: float = move_speed * delta
	if to_target.length() <= maxf(step, ARRIVE_DISTANCE):
		global_position = Vector3(target.x, global_position.y, target.z)
		path.remove_at(0)
	else:
		global_position += to_target.normalized() * step
