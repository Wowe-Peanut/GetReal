extends "res://Levels/LevelBase.gd"

onready var hint_player = $HUD/HintAnimationPlayer
var played_hints = [false, false, false, false]
var play_other_hints: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_hints()
	$HUD/HintContainer/BoxHint.show()
	hint_player.play("BoxHint")
	
	$Level/BoxHint2.connect("body_entered", self, "_on_box_hint_2_triggered")
	$Level/ButtonHint.connect("body_entered", self, "_on_button_hint_triggered")


func _process(delta):
	if $Boxes.get_child_count() == 0 and !played_hints[2]:
		play_other_hints = false
		hide_hints()
		print("playing")
		$HUD/HintContainer/ResetHint.show()
		hint_player.stop()
		hint_player.play("ResetHint")
		played_hints[2] = true
	
	
func _on_box_hint_2_triggered(_body):
	if !played_hints[1] and play_other_hints:
		hide_hints()
		$HUD/HintContainer/BoxHint2.show()
		hint_player.play("BoxHint2")
		played_hints[1] = true
		
func _on_button_hint_triggered(_body):
	if !played_hints[3] and play_other_hints:
		hide_hints()
		$HUD/HintContainer/ButtonHint.show()
		hint_player.play("ButtonHint")
		played_hints[3] = true
	
func hide_hints():
	for hint in $HUD/HintContainer.get_children():
		hint.hide()
