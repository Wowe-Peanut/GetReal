extends "res://addons/godot-xr-tools/objects/Object_pickable.gd"

var seen_by: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("VisibilityNotifier").connect("camera_entered", self, "_on_camera_enter")
	get_node("VisibilityNotifier").connect("camera_exited", self, "_on_camera_exit")
	#get_node("VisibilityNotifier").connect("screen_exited", self, "_on_screen_exit")

func _on_camera_enter(camera):
	if not camera in seen_by:
		seen_by.append(camera)
		print(name, " ", camera.name, " (enter) ", seen_by)

func _on_camera_exit(camera):
	if camera in seen_by:
		seen_by.remove(seen_by.find(camera))
		print(name, " ", camera, " (exit) ", seen_by)
		if len(seen_by) <= 0 and not is_picked_up():
			disappear()
			
func _on_screen_exit():
	if not is_picked_up():
		disappear()


func _physics_process(_delta):
	var space_state = get_world().direct_space_state
	for vertex in $BoxMesh.get_mesh().get_faces():
		var result = space_state.intersect_ray($BoxMesh.global_transform.xform(vertex), get_tree().root.get_camera().global_transform.origin, [self])
		if result.size() <= 0 or result.collider.is_in_group("player_body"):
			#vertex can see player
			return
	#no vertex can see player
	print(name, " can't see player")
	disappear()


func disappear():
	queue_free()
