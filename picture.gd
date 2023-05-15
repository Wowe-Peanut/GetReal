extends Node3D

@onready var texture: Sprite3D = $Texture
@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/Camera3D
	
var picture_taken: bool = false
var mirror

func _ready() -> void:
	mirror = get_tree().root.get_node("test/Mirror")
	mirror.get_node("Reflections/PolaroidReflectionMesh").camera_to_reflect = camera

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("take_picture"): take_picture()


func take_picture() -> void:
	if picture_taken:
		texture.texture = null
		picture_taken = false
		return
	
	camera.global_position = Vector3.ZERO #get_tree().root.get_camera_3d().global_transform
	
	visible = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	texture.texture = viewport.get_texture()
	await RenderingServer.frame_post_draw
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	picture_taken = true
	visible = true
