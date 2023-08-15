extends Marker3D

var held_object: RigidBody3D = null
var object_collision = 0
var aiming: bool = false

func _process(_delta) -> void:
	if is_instance_valid(held_object) and held_object:
		if aiming: 
			held_object.global_transform = get_parent().global_transform
		else:
			held_object.global_transform = global_transform

func toggle_hold(object) -> void:
	if held_object:
		held_object.collision_layer = object_collision
		held_object.freeze = false
		held_object = null
	else:
		if not object or not object.is_in_group("holdable"):
			return
		held_object = object as RigidBody3D
		held_object.freeze = true
		object_collision = held_object.collision_layer
		held_object.collision_layer = 16 + 65536 #box layer + held object layer, so it doesn't disappear and counts as being held

func toggle_aim(to_aim):
	aiming = to_aim

func has_object():
	return is_instance_valid(held_object) and held_object
