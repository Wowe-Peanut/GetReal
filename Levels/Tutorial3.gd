extends "res://Levels/LevelBase.gd"


onready var hint_player: AnimationPlayer = $HUD/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_hints()
	
	hint_player.play("BarrierHint")
	yield(get_tree().create_timer(3), "timeout")
	hide_hints()
	
	hint_player.play("TransBarrierHint")
	yield(get_tree().create_timer(3), "timeout")
	hide_hints()
	
	hint_player.play("BoxesDestroyHint")
	yield(get_tree().create_timer(3), "timeout")
	hide_hints()


func hide_hints():
	for hint in get_node("HUD/HintsContainer").get_children():
		hint.modulate = Color(1, 1, 1, 0)
