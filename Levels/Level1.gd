extends "res://Levels/LevelBase.gd"

onready var hint_player = $HUD/HintAnimationPlayer

var hints_triggered = [false, false, false]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Level/LookHintArea.connect("body_entered", self, "_on_look_hint_triggered")
	$Level/JumpHintArea.connect("body_entered", self, "_on_jump_hint_triggered")
	$Level/ContinueHintArea.connect("body_entered", self, "_on_continue_hint_triggered")
	
	hide_hints()
		
	hint_player.play("MoveHint")
	
func hide_hints():
	for hint in $HUD/MovementHints.get_children():
		hint.modulate = Color(0, 0, 0, 0)
		
func _on_look_hint_triggered(body):
	if !hints_triggered[0]:
		hide_hints()
		hint_player.play("LookHint")
		hints_triggered[0] = true

func _on_jump_hint_triggered(body):
	if !hints_triggered[1]:
		hide_hints()
		hint_player.play("JumpHint")
		hints_triggered[1] = true
	
func _on_continue_hint_triggered(body):
	if !hints_triggered[2]:
		hide_hints()
		hint_player.play("DoorHint")
		hints_triggered[2] = true
