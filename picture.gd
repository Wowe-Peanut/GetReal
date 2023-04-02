extends Node3D

@onready var texture: Sprite3D = $Texture
@onready var viewport: SubViewport = $SubViewport
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("take_picture"): take_picture()


func take_picture():
	var camera = Camera3D.new()
	camera.current = true
	viewport.add_child(camera)
	
	camera.global_transform = get_tree().root.get_camera_3d().global_transform

	texture.texture = viewport.get_texture()
	await RenderingServer.frame_post_draw
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
