extends StaticBody

signal triggered()

export var unlocks: bool = true
export var connection: int = 0
var triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_area_entered")
	$Area.connect("body_exited", self, "_on_area_exited")


func _on_area_entered(body):
	if "Box" in body.name:
		print("triggered")
		triggered = true
		emit_signal("triggered")

func _on_area_exited(body):
	if "Box" in body.name:
		print("off button")
		triggered = false
		emit_signal("triggered")
