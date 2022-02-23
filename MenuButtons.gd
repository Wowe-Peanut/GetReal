extends MarginContainer


onready var play = $PanelContainer/VBoxContainer/Play
onready var credits = $PanelContainer/VBoxContainer/Credits
onready var quit = $PanelContainer/VBoxContainer/Quit

onready var credits_panel = get_parent().get_node("CreditsPanel")


# Called when the node enters the scene tree for the first time.
func _ready():
	play.connect("pressed", self, "_on_play_pressed")
	credits.connect("pressed", self, "_on_credits_pressed")
	quit.connect("pressed", self, "_on_quit_pressed")
	
	credits_panel.visible = false

func _on_play_pressed():
	get_tree().change_scene("res://Levels/Level1.tscn")
	
func _on_credits_pressed():
	credits_panel.visible = !credits_panel.visible

func _on_quit_pressed():
	get_tree().quit()
