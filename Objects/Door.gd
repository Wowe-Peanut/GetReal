extends StaticBody

onready var animation = $AnimationPlayer
export var open_default: bool  = false
export var id: int = 0
var open: bool = false
var player_in: bool = false

signal player_entered()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_body_entered")
	$Area.connect("body_exited", self, "_on_body_exit")
	open = open_default
	if open:
		animation.play("open")
	else:
		animation.play("close")

func _on_body_entered(body):
	if "Player" in body.name:
		player_in = true
		if open:
			emit_signal("player_entered")

func _on_body_exit(body):
	if "Player" in body.name:
		player_in = false

func power(on):
	if on:
		#Go to non-default
		if open_default and open:
			animation.play("close")
			open = false
		elif (not open_default) and (not open):
			animation.play("open")
			if player_in:
				emit_signal("player_entered")
			open = true
	else:
		#Go to default
		if open_default and not open:
			animation.play("open")
			open = true
		elif (not open_default) and open:
			animation.play("close")
			open = false
