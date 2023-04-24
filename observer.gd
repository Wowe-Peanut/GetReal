extends Area3D

@onready var shape: CollisionShape3D = $CollisionShape3D

var seen: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


func _on_body_entered(body) -> void:
	if not body in seen:
		seen.append(body) 
		print(name, seen)
		LosChecker.emit_signal("observer_state_changed")
	
func _on_body_exited(body) -> void:
	if body in seen:
		seen.erase(body)
		print(name, seen)
		LosChecker.emit_signal("observer_state_changed")


func set_points(points) -> void:
	shape.shape.points = points
