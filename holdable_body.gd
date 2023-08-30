class_name HoldableBody
extends RigidBody3D

signal on_picked_up
signal on_dropped

func _ready():
	add_to_group("holdable")


func dropped():
	emit_signal("on_dropped")


func picked_up():
	emit_signal("on_picked_up")
