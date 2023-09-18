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
	
	
func remove_duplicates(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique


func sort_seen() -> void:
	seen.sort_custom(func(a, b): return a.is_in_group("box") and not b.is_in_group("box"))


func set_points(points) -> void:
	shape.shape.points = points


func update_view_cone(quad_mesh: MeshInstance3D) -> void:
	var points: Array[Vector3] = []
	
	var corners = remove_duplicates(quad_mesh.mesh.get_faces())

	for corner in corners: 
		points.append(camera.to_local(quad_mesh.to_global(corner)))

	for corner in corners:
		var point = camera.to_local(quad_mesh.to_global(corner)).normalized() * 100
		points.append(point)
	
	set_points(points)


func cast_ray(state: PhysicsDirectSpaceState3D, start_global_position: Vector3, end_global_position: Vector3, exclude: Array[PhysicsBody3D]) -> Dictionary:
	var query = PhysicsRayQueryParameters3D.create(start_global_position, end_global_position)
	
	# convert objects to RIDs, because reasons
	var exclude_rid: Array[RID] = []
	for object in exclude:
		exclude_rid.append(object.get_rid())
	query.exclude = exclude_rid
	
	return state.intersect_ray(query)


func _on_body_entered(body) -> void:
	if body == self_collider: return
	if not body in seen:
		seen.append(body)


func _on_body_exited(body) -> void:
	if body in seen:
		seen.erase(body)


