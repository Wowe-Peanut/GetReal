extends Node3D


@export_enum("right", "left") var hand: String = "right"

@onready var look_ray: RayCast3D = get_parent()

var held_object: HoldableBody = null


func _unhandled_input(event) -> void:
	if event.is_action_pressed("hand_interact_" + hand):
		if held_object:
			held_object.drop()
			held_object = null
		else:
			var target = look_ray.targeted
			if target:
				target.interact(self)


func _on_dropped():
	if held_object:
		held_object.disconnect("on_dropped", _on_dropped)
		held_object = null
