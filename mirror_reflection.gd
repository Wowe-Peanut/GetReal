@tool
extends Node3D

@export_flags_3d_render var mirror_cam_cull_mask = 3
@export_flags_3d_render var render_layer = 0
@export var disabled: bool = false:
	set(value):
		update_viewport(value)
		disabled = value

@onready var reflection_mesh: MeshInstance3D = $ReflectionMesh
@onready var view: SubViewport = $View
@onready var mirror_cam: Camera3D = $View/MirrorCam
@onready var observer: Observer = $View/MirrorCam/Observer

var camera_to_reflect: Camera3D = null
var pixels_per_unit: int = 1024
var recursion_depth: int = 0
var recursive_parent_reflection = null
var recursive_reflections_handled: Array = []
var recursive_reflection_connections: Dictionary = {}

func _ready():
	mirror_cam.cull_mask = mirror_cam_cull_mask
	reflection_mesh.layers = render_layer
	reflection_mesh.get_surface_override_material(0).set_shader_parameter("mirrorCamTex", $View.get_texture())
	update_viewport(disabled)

func render(mirror_transform: Transform3D) -> void:
	
	if disabled: return
	if camera_to_reflect == null: return
	
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
	
	mirror_cam.set_frustum(reflection_mesh.mesh.size.x, -offset, projection_pos.distance_to(main_cam_pos), 100)
	observer.update_view_cone(reflection_mesh)


func update_viewport(to_disable: bool) -> void:
	if !is_inside_tree(): return
	if to_disable:
		view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	else:
		view.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE


func set_size(new_size: Vector2) -> void:
	reflection_mesh.mesh.size = new_size
	view.size = new_size * pixels_per_unit
