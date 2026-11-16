extends Node3D
## Scene orchestration. Construction, food chain, recruitment and unit orders; no combat yet.

const MapGridScript = preload("res://scripts/rts/map_grid.gd")
const CameraRigScript = preload("res://scripts/rts/rts_camera.gd")
const ConstructionScript = preload("res://scripts/rts/construction.gd")
const RecruitmentScript = preload("res://scripts/rts/recruitment.gd")
const UnitCommanderScript = preload("res://scripts/rts/unit_commander.gd")

@onready var map_grid: MapGridScript = $MapGrid
@onready var camera_rig: CameraRigScript = $RTSCamera
@onready var construction: ConstructionScript = $Construction
@onready var recruitment: RecruitmentScript = $Recruitment
@onready var unit_commander: UnitCommanderScript = $UnitCommander

func _ready() -> void:
	map_grid.active_camera = camera_rig.camera
	camera_rig.set_map_extent(map_grid.get_extent())
	construction.map_grid = map_grid
	recruitment.map_grid = map_grid
	recruitment.construction = construction
	unit_commander.map_grid = map_grid
	unit_commander.construction = construction
	map_grid.cell_selected.connect(_on_cell_selected)
	print("[RTS Phase 3C] Archer and crossbowman recruitment ready; combat is not implemented")

func _on_cell_selected(cell: Vector2i, terrain_type: int) -> void:
	if construction.active_definition != null:
		construction.try_place(cell)
		return
	if terrain_type < 0:
		print("[RTS Grid] Selection cleared")
	else:
		print("[RTS Grid] Selected cell=%s terrain=%d" % [cell, terrain_type])
