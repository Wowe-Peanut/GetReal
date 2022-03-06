extends "res://addons/godot-xr-tools/objects/Object_pickable.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("VisibilityNotifier").connect("screen_exited", self, "_on_screen_exit")
	#get_node("VisibilityNotifier").connect("camera_exited", self, "_on_camera_exit")
	
func _on_screen_exit():
	if not is_picked_up():
		queue_free()

func _on_camera_exit(camera):
	if not is_picked_up():
		print(camera)
		queue_free()

