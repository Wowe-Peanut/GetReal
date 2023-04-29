@tool
extends RigidBody3D

@export var pixels_per_unit: int = 10
@export var size: Vector2 = Vector2(1, 1):
	set(value):
		update_size(value)
		size = value

	

@onready var mesh = $Mesh
@onready var mirror_cam: Camera3D = $View/MirrorCam
@onready var mirror_origin = $MirrorOrigin
@onready var observer = $View/MirrorCam/MirrorObserver

var player_cam: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_cam = get_tree().root.get_camera_3d()

	mesh.get_surface_override_material(0).set_shader_parameter("mirrorCamTex", $View.get_texture())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if not Engine.is_editor_hint():
		render()
	
func render():
	var plane_origin = mirror_origin.global_transform.origin
	var plane_normal = mirror_origin.global_transform.basis.z.normalized()
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	var reflection_transform = mirror_origin.global_transform
	
	var main_cam_pos = player_cam.global_transform.origin
	var projection_pos = reflection_plane.project(main_cam_pos)
	
	var mirrored_cam_pos = main_cam_pos + (projection_pos - main_cam_pos) * 2.0
	
	var t = Transform3D(Basis(), mirrored_cam_pos)
	t = t.looking_at(projection_pos, reflection_transform.basis.y.normalized())
	mirror_cam.set_global_transform(t)
	
	var offset = reflection_transform.inverse() * main_cam_pos
	offset = Vector2(offset.x, offset.y)
	
	mirror_cam.set_frustum(mesh.mesh.size.x, -offset, projection_pos.distance_to(main_cam_pos), 100)
	update_view_cone()

func update_size(new_size: Vector2) -> void:
	$Mesh.mesh.size = new_size
	$Border.mesh.size = Vector3(new_size.x + 0.1, new_size.y + 0.1, 0.01)
	$CollisionShape3D.shape.size = Vector3(new_size.x, new_size.y, 0.1)
	$View.size = new_size * pixels_per_unit

func update_view_cone() -> void:
	var points: Array[Vector3] = []
	
	var mirror_corners = mesh.mesh.get_faces()
	mirror_corners.remove_at(3)
	mirror_corners.remove_at(4)
	
	for corner in mirror_corners: 
		points.append(mirror_cam.to_local(to_global(corner)))
	
	for corner in mirror_corners:
		var point = mirror_cam.to_local(to_global(corner)).normalized() * 100
		points.append(point)
		
	observer.set_points(points)
