extends Node3D
## Prototype soldier actor: a primitive body only. Movement, selection and combat come later.
const BODY_HEIGHT: float = 1.1

var unit_type: StringName = &"swordsman"
var hit_points: int = 30

func setup(type: StringName, color: Color) -> void:
	unit_type = type
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
	if get_child_count() == 0:
		setup(unit_type, Color(0.28, 0.42, 0.68))
