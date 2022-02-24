extends StaticBody

signal triggered()


export(Array, int) var powers = []
export(Array, int) var unpowers = []
var triggered: bool = false
var trigger_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_area_entered")
	$Area.connect("body_exited", self, "_on_area_exited")


func _on_area_entered(body):
	if "Box" in body.name:
		trigger_count += 1
		triggered = true
		if trigger_count == 1:
			emit_signal("triggered")

func _on_area_exited(body):
	if "Box" in body.name:
		trigger_count -= 1
		triggered = false
		if trigger_count == 0:
			emit_signal("triggered")
