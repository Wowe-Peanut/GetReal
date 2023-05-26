extends Node3D

const PROXY_BOX = preload("res://proxy_box.tscn")

@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var observer: Observer = $SubViewport/Camera3D/Observer
	
var picture_taken: bool = false
var proxies = []

func _ready() -> void:
	MirrorController.register_polaroid(self)

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("take_picture"): take_picture()


func take_picture() -> void:
	if picture_taken:
		picture_taken = false
		visible = false
		for proxy in proxies:
			get_tree().root.remove_child(proxy)
		proxies.clear()
		return
	
	camera.global_position = Vector3.ZERO #get_tree().root.get_camera_3d().global_transform
	
	visible = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await RenderingServer.frame_post_draw
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	for observed_object in observer.seen:
		if observed_object.is_in_group("box"):
			print("box!")
			var proxy = PROXY_BOX.instantiate()
			proxy.global_transform = observed_object.global_transform
			get_tree().root.add_child(proxy)
			proxies.append(proxy)
		if observed_object.is_in_group("mirror"):
			pass
	
	picture_taken = true
	visible = true
