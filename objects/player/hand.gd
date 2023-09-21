extends Node3D


@export_enum("right", "left") var hand: String = "right"

@onready var look_ray: RayCast3D = get_parent()


var held_object: HoldableBody = null


func _unhandled_input(event) -> void:
	if event.is_action_pressed("hand_interact_" + hand):
		toggle_hold()


func toggle_hold() -> void:
	if held_object:
		held_object.drop()
		held_object = null
	else:
		var object = look_ray.get_collider()
		
		if object and object.is_in_group("holdable"):
			object.pick_up(self)
			object.connect("on_dropped", _on_dropped)
			held_object = object

func _on_dropped():
	if held_object:
		held_object.disconnect("on_dropped", _on_dropped)
		held_object = null
