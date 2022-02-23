extends "res://Levels/LevelBase.gd"

onready var hint_player = $HUD/HintAnimationPlayer
var played_hints = [false, false, false, false]


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_hints()
	hint_player.play("BoxHint")
	
	$Level/BoxHint2.connect("body_entered", self, "_on_box_hint_2_triggered")
	$Level/ButtonHint.connect("body_entered", self, "_on_button_hint_triggered")


func _process(delta):
	if len(get_node("Boxes").get_children()) == 0 and !played_hints[2]:
		hide_hints()
		print("playing")
		hint_player.play("ResetHint")
		played_hints[2] = true
	._process(delta)
	
func _on_box_hint_2_triggered(body):
	if !played_hints[1]:
		hide_hints()
		hint_player.play("BoxHint2")
		played_hints[1] = true
		
func _on_button_hint_triggered(body):
	if !played_hints[3]:
		hide_hints()
		hint_player.play("ButtonHint")
		played_hints[3] = true
	
func hide_hints():
	for hint in $HUD/HintContainer.get_children():
		hint.modulate = Color(0, 0, 0, 0)
