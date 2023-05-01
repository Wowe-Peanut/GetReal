class_name Observer
extends Area3D

@export var camera: Camera3D = get_parent()
@export var self_collider: PhysicsBody3D

@onready var shape: CollisionShape3D = $CollisionShape3D

var seen: Array = []

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

func cast_ray(state: PhysicsDirectSpaceState3D, start_global_position: Vector3, end_global_position: Vector3, exclude: Array[PhysicsBody3D]) -> Dictionary:
	var query = PhysicsRayQueryParameters3D.create(start_global_position, end_global_position)
	
	# convert objects to RIDs, because reasons
	var exclude_rid: Array[RID] = []
	for object in exclude:
		exclude_rid.append(object.get_rid())
	query.exclude = exclude_rid
	
	return state.intersect_ray(query)

func _on_body_entered(body) -> void:
	if not body in seen:
		print(self, "enter: ", body)
		seen.append(body)

func _on_body_exited(body) -> void:
	if body in seen:
		print(self, "exit: ", body)
		seen.erase(body)


