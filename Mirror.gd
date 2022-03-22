extends MeshInstance

const NEAR = 0
const FAR = 1
const LEFT = 2
const TOP = 3
const RIGHT = 4
const BOTTOM = 5

export(Vector2) var size = Vector2(1, 1) setget set_mirror_size
export(int) var pixels_per_unit = 200

onready var mirror_viewport = $Viewport
onready var mirror_origin = $MirrorOrigin

var far_clip_plane_distance = 100.0

var main_cam = null
var mirror_cam = null
var view_cone_shape = null

func _ready():
	init_cam()
	
func _process(_delta):
	var plane_origin = mirror_origin.global_transform.origin
	var plane_normal = mirror_origin.global_transform.basis.z.normalized()
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	var reflection_transform = mirror_origin.global_transform
	
	var main_cam_pos = main_cam.global_transform.origin
	var projection_pos = reflection_plane.project(main_cam_pos)
	
	var mirrored_cam_pos = main_cam_pos + (projection_pos - main_cam_pos) * 2.0
	
	var t = Transform(Basis(), mirrored_cam_pos)
	t = t.looking_at(projection_pos, reflection_transform.basis.y.normalized())
	mirror_cam.set_global_transform(t)
	
	var offset = reflection_transform.xform_inv(main_cam_pos)
	offset = Vector2(offset.x, offset.y)
	
	mirror_cam.set_frustum(mesh.size.x, -offset, projection_pos.distance_to(main_cam_pos), far_clip_plane_distance)
	update_view_cone(mirrored_cam_pos)
	
func update_view_cone(mirror_cam_pos):
	var view_cone_collision_shape = []
	var vertices = mesh.get_faces()
	vertices.remove(3)
	vertices.remove(3)
	for vertex in vertices:
		view_cone_collision_shape.append(mirror_cam.to_local(global_transform.xform(vertex)))
	for vertex in vertices:
		var direction = mirror_cam.to_local(to_global(vertex))
		direction *= far_clip_plane_distance
		view_cone_collision_shape.append(direction)
	view_cone_shape.shape.points = PoolVector3Array(view_cone_collision_shape)
	
func set_mirror_size(new_size):
	size = new_size
	mesh.size = new_size
	init_cam()

func init_cam():
	if !is_inside_tree():
		return
		
	main_cam = get_tree().root.get_camera()
	
	if mirror_cam:
		mirror_cam.queue_free()
		
	mirror_cam = Camera.new()
	mirror_cam.name = "MirrorCam"
	mirror_viewport.add_child(mirror_cam)
	mirror_cam.keep_aspect = Camera.KEEP_WIDTH
	mirror_cam.current = true
	
	var view_cone = Area.new()
	var view_cone_collision = CollisionShape.new()
	view_cone_collision.shape = ConvexPolygonShape.new()
	view_cone.add_child(view_cone_collision)
	mirror_cam.add_child(view_cone)
	view_cone_shape = view_cone_collision
	
	
	mirror_viewport.size = mesh.size * pixels_per_unit
	
	get_surface_material(0).albedo_texture = mirror_viewport.get_texture()
