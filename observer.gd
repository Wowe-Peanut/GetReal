class_name Observer
extends Area3D

@export var camera: Camera3D = get_parent()
@export var self_collider: PhysicsBody3D


@onready var shape: CollisionShape3D = $CollisionShape3D


var seen: Array = []
var observed: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
	
func remove_duplicate(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func set_points(points) -> void:
	shape.shape.points = points

func cast_ray(state: PhysicsDirectSpaceState3D, box: RigidBody3D, vertex: Vector3, camera_position: Vector3) -> Dictionary:
	var query = PhysicsRayQueryParameters3D.create(box.global_transform * vertex, camera_position)
	query.exclude = [box] # this should change as more types of colliders are added
	return state.intersect_ray(query)

func _on_body_entered(body) -> void:
	if not body in seen:
		seen.append(body)
		LosChecker.emit_signal("observer_state_changed")

func _on_body_exited(body) -> void:
	if body in observed:
		observed.erase(body)
	if body in seen:
		seen.erase(body)
		LosChecker.emit_signal("observer_state_changed")


