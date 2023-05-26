extends StaticBody3D

@onready var detection = $DetectionArea


# Called when the node enters the scene tree for the first time.
func _ready():
	detection.connect("body_entered", _on_body_entered)
	detection.connect("body_exited", _on_body_exited)


func _on_body_entered(body):
	print("Entered: ", body)
	
func _on_body_exited(body):
	print("Exited: ", body)
