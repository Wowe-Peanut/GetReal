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


func _physics_process(_delta) -> void:
	var state = get_world_3d().direct_space_state
	for observed_object in seen:
		if observed_object.is_in_group("box"):
			#cast rays
			
			#if obscured and not previously: remove
			#if obscured and previously: nothing
			#if not obscured and previously: add
			#if not obscured and not previously: nothing
			var obscured = is_obscured(state, observed_object)
			if obscured:
				var len = len(observed)
				observed.erase(observed_object)
				if len(observed) != len:
					LosChecker.emit_signal("observer_state_changed")
			elif not observed.has(observed_object):
				observed.append(observed_object)
				LosChecker.emit_signal("observer_state_changed")

func is_obscured(state: PhysicsDirectSpaceState3D, observed: RigidBody3D) -> bool:
	for vertex in remove_duplicate(observed.mesh.mesh.get_faces()):
		var result = cast_ray(state, observed, vertex, camera.global_position)
		if result.collider == self_collider:
			return false
	return true
	
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


