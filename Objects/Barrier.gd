extends StaticBody

onready var animation = $AnimationPlayer

export var start_locked: bool
export var connection: int = 1
var locked: bool = true



func _ready():
	locked = not start_locked
	if start_locked:
		lock()
	else:
		unlock()

func unlock():
	if locked:
		animation.play("unlock")
		locked = false
	
func lock():
	if not locked:
		animation.play("lock")
		locked = true

