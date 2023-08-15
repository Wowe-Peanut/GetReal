extends RigidBody3D

const PROXY_BOX = preload("res://proxy_box.tscn")

@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var observer: Observer = $SubViewport/Camera3D/Observer
@onready var display: MeshInstance3D = $Display
	
var picture_taken: bool = false
var proxies = []
var boxes_handled = []

func _ready() -> void:
	MirrorController.register_camera(self)

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("take_picture"): take_picture()


func _process(_delta):
	if not picture_taken: camera.global_transform = global_transform


func add_proxy_box(original_box) -> void:
	
	if boxes_handled.has(original_box): return
	
	var proxy = PROXY_BOX.instantiate()
	proxy.global_transform = original_box.global_transform
	get_parent().add_child(proxy)
	proxies.append(proxy)
	boxes_handled.append(original_box)


func remove_proxy_boxes() -> void:
	for proxy in proxies:
		get_parent().remove_child(proxy)
	proxies.clear()
	boxes_handled.clear()


func reset() -> bool:
	if picture_taken:
		picture_taken = false
		display.visible = false
		remove_proxy_boxes()
		return true
	return false


func recursive_find_box_in_mirror(mirror_reflection) -> void:
	mirror_reflection.observer.sort_seen()
	for observed_object in mirror_reflection.observer.seen:
		if observed_object.is_in_group("box"):
			add_proxy_box(observed_object)
		if observed_object.is_in_group("mirror"):
			if mirror_reflection.recursive_reflection_connections.is_empty(): continue
			if !mirror_reflection.recursive_reflection_connections.has(observed_object): continue
			
			recursive_find_box_in_mirror(mirror_reflection.recursive_reflection_connections[observed_object])


func dropped() -> void:
	reset()


func take_picture() -> void:
	
	
	if reset(): return
	
	
	for observed_object in observer.seen:
		if observed_object.is_in_group("box"):
			add_proxy_box(observed_object)
		if observed_object.is_in_group("mirror"):
			# if we have a mirror, check to see if the box can be seen in the mirror (recursive too)
			recursive_find_box_in_mirror(observed_object.camera_reflection)
			pass
	
	display.visible = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await RenderingServer.frame_post_draw
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	
	picture_taken = true
	display.visible = true
