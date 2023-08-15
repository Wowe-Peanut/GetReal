extends StaticBody3D

@onready var detection = $DetectionArea

var powered: bool = false
var bodies: Array = []

signal powered_changed(button, powered)

# Called when the node enters the scene tree for the first time.
func _ready():
	detection.connect("body_entered", _on_body_entered)
	detection.connect("body_exited", _on_body_exited)


func modify_power():
	powered = bodies.size() > 0
	emit_signal("powered_changed", self, powered)


func _on_body_entered(body):
	if not body in bodies: bodies.append(body)
	modify_power()
	print("Entered: ", bodies, powered)
	
func _on_body_exited(body):
	if body in bodies: bodies.erase(body)
	modify_power()
	print("Exited: ", bodies, powered)
