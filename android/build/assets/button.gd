extends StaticBody3D

@onready var detection = $DetectionArea

var powered: bool = false

signal powered_changed(button, powered)

# Called when the node enters the scene tree for the first time.
func _ready():
	detection.connect("body_entered", _on_body_entered)
	detection.connect("body_exited", _on_body_exited)


func _on_body_entered(body):
	print("Entered: ", body)
	powered = true
	emit_signal("powered_changed", self, powered)
	
func _on_body_exited(body):
	print("Exited: ", body)
	powered = false
	emit_signal("powered_changed", self, powered)
