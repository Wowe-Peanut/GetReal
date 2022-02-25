extends Spatial

onready var cut_wall = $Level/Room/CutWall
onready var door = $Barriers/Door
onready var stop_wall = $Level/StopPlayer

var outside_hidden: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Level/FakeOutside/VisibilityNotifier.connect("screen_exited", self, "_on_fake_outside_hidden")
	$Barriers/Door.connect("player_entered", self, "get_drunk")


func _on_fake_outside_hidden():
	if not outside_hidden:
		cut_wall.visible = false
		door.visible = true
		stop_wall.queue_free()
		outside_hidden = true


func get_drunk():
	get_tree().change_scene("res://EndingScreen.tscn")
