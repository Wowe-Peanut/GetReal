@tool
extends RigidBody3D

var reflection = preload("res://mirror_reflection.tscn")

@export var pixels_per_unit: int = 1024
@export var size: Vector2 = Vector2(1, 1):
	set(value):
		update_size(value)
		size = value

@onready var mirror_transform: Transform3D = $MirrorOrigin.global_transform
@onready var reflections = $Reflections
@onready var player_reflection = $Reflections/PlayerReflectionMesh
@onready var polaroid_reflection = $Reflections/PolaroidReflectionMesh
@onready var observer: Observer = $Reflections/PlayerReflectionMesh.observer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_observer = get_tree().get_first_node_in_group("player_observer")
	player_reflection.camera_to_reflect = player_observer.camera
	player_reflection.recursive_parent_reflection = player_observer.self_collider
	
	for reflection_mesh in reflections.get_children():
		reflection_mesh.observer.self_collider = self
		reflection_mesh.pixels_per_unit = pixels_per_unit
		
	update_size(size)


func _process(_delta: float):
	if not Engine.is_editor_hint():
		for reflection_mesh in reflections.get_children():
			
			reflection_mesh.render(mirror_transform)
			handle_recursive_reflections(reflection_mesh)
			


func handle_recursive_reflections(reflection_mesh) -> void:
	for seen_object in reflection_mesh.observer.seen:
		if seen_object.is_in_group("mirror"):
			
			if seen_object in reflection_mesh.recursive_reflections_handled: 
				continue
			
			var render_layer = MirrorController.get_next_layer()
			if render_layer < 0:
				continue
			reflection_mesh.observer.camera.cull_mask += render_layer
			var reflection_added = seen_object.add_reflection(reflection_mesh.mirror_cam, render_layer, reflection_mesh.recursion_depth)
			reflection_mesh.recursive_reflections_handled.append(seen_object)
			reflection_mesh.recursive_reflection_connections[seen_object] = reflection_added
			reflection_added.recursive_parent_reflection = reflection_mesh
			


func add_reflection(camera_to_reflect, render_layer, recursion_depth) -> Node3D:
	var new_reflection = reflection.instantiate()
	new_reflection.render_layer = render_layer
	new_reflection.mirror_cam_cull_mask = 3
	new_reflection.camera_to_reflect = camera_to_reflect
	new_reflection.recursion_depth = recursion_depth + 1
	new_reflection.pixels_per_unit = pixels_per_unit #/ pow(2, (recursion_depth + 1))
	new_reflection.translate(Vector3(0, 0, 0.01))
	reflections.add_child(new_reflection)
	new_reflection.observer.self_collider = self
	new_reflection.set_size(size)
	return new_reflection


func register_polaroid(polaroid):
	polaroid_reflection.camera_to_reflect = polaroid.observer.camera


func update_size(new_size: Vector2) -> void:
	if is_inside_tree():
		for reflection_mesh in reflections.get_children():
			reflection_mesh.set_size(new_size)
		$Border.mesh.size = Vector3(new_size.x + 0.1, new_size.y + 0.1, 0.01)
		$CollisionShape3D.shape.size = Vector3(new_size.x, new_size.y, 0.1)
