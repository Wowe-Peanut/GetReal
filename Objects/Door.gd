extends StaticBody

onready var animation = $AnimationPlayer
export var open_default: bool  = false
export var id: int = 0
var open: bool = false

signal player_entered()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_body_entered")
	open = open_default
	if open:
		animation.play("open")
	else:
		animation.play("close")

func _on_body_entered(body):
	if open and "Player" in body.name:
		emit_signal("player_entered")

func power(on):
	if on:
		#Go to non-default
		if open_default and open:
			animation.play("close")
			open = false
		elif (not open_default) and (not open):
			animation.play("open")
			open = true
	else:
		#Go to default
		if open_default and not open:
			animation.play("open")
			open = true
		elif (not open_default) and open:
			animation.play("close")
			open = false
