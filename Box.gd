extends "res://addons/godot-xr-tools/objects/Object_pickable.gd"

onready var mesh = $BoxMesh

var seen_by: Array = []
var unobscured: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for view_cone in get_tree().get_nodes_in_group("view_cones"):
		view_cone.connect("body_entered", self, "_on_entered_view_cone", [view_cone])
		view_cone.connect("body_exited", self, "_on_exited_view_cone", [view_cone])

func _on_entered_view_cone(body, view_cone):
	if body == self:
		if not view_cone in seen_by:
			seen_by.append(view_cone)

func _on_exited_view_cone(body, view_cone):
	if body == self:
		if not is_picked_up() and view_cone in seen_by:
			seen_by.remove(seen_by.find(view_cone))
			if len(seen_by) <= 0:
				disappear()

func _physics_process(_delta):
	unobscured.clear()
	var space_state = get_world().direct_space_state
	for view_cone in seen_by:
		var is_player_cam = view_cone.name == "HeadsetViewcone"
		unobscured.append(check_obscured(space_state, view_cone, is_player_cam))
	
func check_obscured(space_state, view_cone, is_player_cam):
	var cast_to = view_cone.get_parent().global_transform.origin if is_player_cam else view_cone.get_node("../../../MirrorOrigin").global_transform.origin
	for vertex in mesh.get_mesh().get_faces():
		var result = space_state.intersect_ray(mesh.global_transform.xform(vertex), cast_to, [self])
		if result.size() <= 0 or result.collider.is_in_group("player_body"):
			return true
	return false

func disappear():
	queue_free()
