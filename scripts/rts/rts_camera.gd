extends Node3D
## Presentation-only RTS camera rig. Ground movement follows camera yaw.

@export var pan_speed: float = 38.0
@export var edge_margin: float = 18.0
@export var rotation_speed: float = 1.4
@export var mouse_rotation_sensitivity: float = 0.006
@export var min_zoom: float = 16.0
@export var max_zoom: float = 120.0

@onready var camera: Camera3D = $Camera3D
var map_extent: float = 128.0
var rotating: bool = false
var window_focused: bool = true

func _ready() -> void:
	print("[RTS Camera] Ready: edge pan, wheel zoom, MMB rotate")

func set_map_extent(extent: float) -> void:
	map_extent = extent
	position = Vector3(extent * 0.5, 0.0, extent * 0.5)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		window_focused = false
		rotating = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		window_focused = true

func _unhandled_input(event: InputEvent) -> void:
	if not window_focused:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			rotating = event.pressed
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.size = clampf(camera.size / 1.12, min_zoom, max_zoom)
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.size = clampf(camera.size * 1.12, min_zoom, max_zoom)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and rotating:
		rotation.y -= event.relative.x * mouse_rotation_sensitivity
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not window_focused:
		return
	# Guard against releasing MMB outside the browser viewport.
	if rotating and not Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		rotating = false
	var direction: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_back")
	var rect: Rect2 = get_viewport().get_visible_rect()
	var mouse: Vector2 = get_viewport().get_mouse_position()
	if rect.has_point(mouse) and not rotating:
		if mouse.x < rect.position.x + edge_margin:
			direction.x -= 1.0
		elif mouse.x > rect.end.x - edge_margin:
			direction.x += 1.0
		if mouse.y < rect.position.y + edge_margin:
			direction.y -= 1.0
		elif mouse.y > rect.end.y - edge_margin:
			direction.y += 1.0
	direction = direction.limit_length(1.0)
	rotation.y += Input.get_axis("camera_rotate_right", "camera_rotate_left") * rotation_speed * delta
	var movement: Vector3 = global_basis * Vector3(direction.x, 0.0, direction.y)
	position += movement * pan_speed * (camera.size / 48.0) * delta
	position.x = clampf(position.x, 0.0, map_extent)
	position.z = clampf(position.z, 0.0, map_extent)
