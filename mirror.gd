@tool
extends RigidBody3D

var reflection = preload("res://mirror_reflection.tscn")

@export var pixels_per_unit: int = 10
@export var size: Vector2 = Vector2(1, 1):
	set(value):
		update_size(value)
		size = value

@onready var mirror_transform: Transform3D = $MirrorOrigin.global_transform
@onready var reflections = $Reflections
@onready var observer: Observer = $Reflections/PlayerReflectionMesh.observer

var player_cam: Camera3D
var other_mirror_reflections: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Reflections/PlayerReflectionMesh.camera_to_reflect = get_tree().root.get_camera_3d()
	
	for reflection_mesh in reflections.get_children():
		reflection_mesh.observer.self_collider = self
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if not Engine.is_editor_hint():
		for reflection_mesh in reflections.get_children():
			reflection_mesh.render(mirror_transform)
			
			
		
		for seen_object in observer.seen:
			if seen_object.is_in_group("mirror"):
				# if dealt with: return
				if seen_object in other_mirror_reflections: 
					return
				else:
				#	add a new reflection
					var render_layer = MirrorController.get_next_layer()
					observer.camera.cull_mask += render_layer
					seen_object.add_reflection(observer.camera, render_layer)
					other_mirror_reflections.append(seen_object)
					pass
				
				#if any left over, delete reflection
				


func add_reflection(camera, render_layer) -> void:
	var new_reflection = reflection.instantiate()
	new_reflection.render_layer = render_layer
	new_reflection.mirror_cam_cull_mask = 1
	reflections.add_child(new_reflection)
	new_reflection.observer.self_collider = self
	new_reflection.camera_to_reflect = camera
	new_reflection.set_size(size)
	new_reflection.translate(Vector3(0, 0, 0.01))


func update_size(new_size: Vector2) -> void:
	if is_inside_tree():
		for reflection_mesh in reflections.get_children():
			reflection_mesh.set_size(new_size)
		$Border.mesh.size = Vector3(new_size.x + 0.1, new_size.y + 0.1, 0.01)
		$CollisionShape3D.shape.size = Vector3(new_size.x, new_size.y, 0.1)
