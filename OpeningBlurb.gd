extends Control


onready var animation_player = $AnimationPlayer
onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$BlurbCenter/Blurb.percent_visible = 0.0
	$TaglineCenter/Tagline.percent_visible = 0.0
	
	stagger_skip_prompt()
	
	timer.start()
	yield(timer, "timeout")
	
	animation_player.play("Blurb")
	yield(animation_player, "animation_finished")
	
	$BlurbCenter/Blurb.percent_visible = 0.0
	
	animation_player.play("Tagline")
	yield(animation_player, "animation_finished")
	
	get_tree().change_scene("res://Levels/Level1.tscn")
	
func stagger_skip_prompt():
	yield(get_tree().create_timer(4.7), "timeout")
	$Skip/AnimationPlayer.play("Skip")
	
func _process(delta):
	if Input.is_action_pressed("interact"):
		get_tree().change_scene("res://Levels/Tutorial1.tscn")
