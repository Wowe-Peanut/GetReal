extends "res://addons/godot-xr-tools/objects/Object_pickable.gd"

var seen_by: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for view_cone in get_tree().get_nodes_in_group("view_cones"):
		view_cone.connect("body_entered", self, "_on_entered_view_cone", [view_cone])
		view_cone.connect("body_exited", self, "_on_exited_view_cone", [view_cone])

func _on_entered_view_cone(body, view_cone):
	if body == self:
		if not view_cone in seen_by:
			seen_by.append(view_cone)
			print("in sight ", seen_by)

func _on_exited_view_cone(body, view_cone):
	if body == self:
		if not is_picked_up() and view_cone in seen_by:
			seen_by.remove(seen_by.find(view_cone))
			print("out of sight ", seen_by)
			if len(seen_by) <= 0:
				disappear()

func _physics_process(_delta):
	
	var space_state = get_world().direct_space_state
	#for view_cone in seen_by: (to be completed later)
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
