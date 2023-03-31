extends Node3D

@onready var view = $View
@onready var mesh = $Mesh
@onready var mirror_cam: Camera3D = $View/MirrorCam

@export var pixels_per_unit: int = 100

var player_cam: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_cam = get_tree().root.get_camera_3d()
	
	mesh.get_surface_override_material(0).albedo_texture = view.get_texture()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	mirror_cam.global_transform = player_cam.global_transform
