extends Control


var can_continue: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("TitleReveal")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Continue")
	can_continue = true

func _input(event):
	if can_continue and event.is_action_pressed("interact"):
		get_tree().change_scene("res://MainMenu.tscn")
