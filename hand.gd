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
		if held_object.has_method("dropped"): held_object.dropped()
		held_object = null
	else:
		if not object or not object.is_in_group("holdable"):
			return
		held_object = object as RigidBody3D
		held_object.freeze = true
		object_collision = held_object.collision_layer
		# below needs to be changed: not only the box can be picked up now
		held_object.collision_layer = 16 + 65536 #box layer + held object layer, so it doesn't disappear and counts as being held
		if held_object.has_signal("to_drop"): held_object.connect("to_drop", func() : toggle_hold(held_object))

func toggle_aim(to_aim):
	aiming = to_aim

func has_object():
	return is_instance_valid(held_object) and held_object