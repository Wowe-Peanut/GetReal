@tool
extends MeshInstance3D

@export_flags_3d_render var mirror_cam_cull_mask = 0
@export_flags_3d_render var render_layer = 0

@onready var view: SubViewport = $View
@onready var mirror_cam: Camera3D = $View/MirrorCam
@onready var observer: Observer = $View/MirrorCam/MirrorObserver

var camera_to_reflect: Camera3D = null

func _ready():
	mirror_cam.cull_mask = mirror_cam_cull_mask
	layers = render_layer
	get_surface_override_material(0).set_shader_parameter("mirrorCamTex", $View.get_texture())

func render(mirror_transform: Transform3D) -> void:
	
	if camera_to_reflect == null:
		return
	
	var plane_origin = mirror_transform.origin
	var plane_normal = mirror_transform.basis.z.normalized()
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	var reflection_transform = mirror_transform
	
	var main_cam_pos = camera_to_reflect.global_transform.origin
	var projection_pos = reflection_plane.project(main_cam_pos)
	
	var mirrored_cam_pos = main_cam_pos + (projection_pos - main_cam_pos) * 2.0
	
	var t = Transform3D(Basis(), mirrored_cam_pos)
	t = t.looking_at(projection_pos, reflection_transform.basis.y.normalized())
	mirror_cam.set_global_transform(t)
	
	var offset = reflection_transform.inverse() * main_cam_pos
	offset = Vector2(offset.x, offset.y)
	
	mirror_cam.set_frustum(mesh.size.x, -offset, projection_pos.distance_to(main_cam_pos), 100)
	update_view_cone()

func update_view_cone() -> void:
	var points: Array[Vector3] = []
	
	var mirror_corners = mesh.get_faces()
	mirror_corners.remove_at(3)
	mirror_corners.remove_at(4)
	
	for corner in mirror_corners: 
		points.append(mirror_cam.to_local(to_global(corner)))
	
	for corner in mirror_corners:
		var point = mirror_cam.to_local(to_global(corner)).normalized() * 100
		points.append(point)
		
	observer.set_points(points)


func set_size(new_size) -> void:
	mesh.size = new_size
	view.size = new_size * get_parent().get_parent().pixels_per_unit
