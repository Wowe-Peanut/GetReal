extends StaticBody

onready var animation = $AnimationPlayer
export var start_locked: bool  = false
export var connection: int = 0
var locked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_body_entered")
	locked = not start_locked
	if start_locked:
		lock()
	else:
		unlock()

func _on_body_entered(body):
	if !locked and body.name == "Player":
		print("Player in door!")

func unlock():
	if locked:
		animation.play("unlock")
		locked = false
	
func lock():
	if not locked:
		animation.play("lock")
		locked = true
