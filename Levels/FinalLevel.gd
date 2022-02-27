extends Spatial

onready var cut_wall = $Level/Room/CutWall
onready var door = $Barriers/Door
onready var stop_wall = $Level/StopPlayer
onready var extra_wall = $Level/ExtraWall

onready var text_animation = $HUD/AnimationPlayer

var outside_hidden: bool = false
var close_enough: bool = false
var dont_turn_triggered: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Level/FakeOutside/VisibilityNotifier.connect("screen_exited", self, "_on_fake_outside_hidden")
	$Barriers/Door.connect("player_entered", self, "get_drunk")
	$Level/DisappearTrigger.connect("body_entered", self, "_on_disappear_trigger")
	$HUD/DontTurn/DontTurn.modulate = Color(1, 1, 1, 0)
	$HUD/DontTurn/TooLate.modulate = Color(1, 1, 1, 0)
	extra_wall.get_node("CollisionShape").disabled = true
	extra_wall.get_node("MeshInstance").visible = false


func _on_fake_outside_hidden():
	if not outside_hidden and close_enough:
		$HUD/DontTurn/DontTurn.modulate = Color(1, 1, 1, 0)
		text_animation.play("TooLate")
		extra_wall.get_node("MeshInstance").visible = true
		cut_wall.visible = false
		door.visible = true
		stop_wall.queue_free()
		outside_hidden = true

func _on_disappear_trigger(body):
	if body.name == "Player" and not dont_turn_triggered:
		dont_turn_triggered = true
		close_enough = true
		extra_wall.get_node("CollisionShape").disabled = false
		text_animation.play("DontTurn")
		yield(get_tree().create_timer(5), "timeout")
		if not outside_hidden:
			text_animation.play("DontTurnFlash")

func get_drunk():
	get_tree().change_scene("res://EndingScreen.tscn")
