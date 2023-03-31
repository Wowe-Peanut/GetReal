extends RigidBody3D

@onready var visibility_check: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var mesh: MeshInstance3D = $Mesh
@onready var coyote_timer: Timer = $CoyoteTimer

var observers: Array[Node] = []
var to_delete: bool = false

signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coyote_timer.timeout.connect(destroy_self)
	observers = get_tree().get_nodes_in_group("observer")
	
func _physics_process(_delta: float) -> void:
	# if off screen and ct off: start coyote timer
	if !visibility_check.is_on_screen() and coyote_timer.is_stopped():
		coyote_timer.start()
	# if on screen and ct off, and obscured, ct on
	if visibility_check.is_on_screen() and is_obscured(get_world_3d().direct_space_state, get_viewport().get_camera_3d()) and coyote_timer.is_stopped():
		coyote_timer.start()
	# if on screen and unobscured stop and ct on, don't delete ct off
	if visibility_check.is_on_screen() and !is_obscured(get_world_3d().direct_space_state, get_viewport().get_camera_3d()) and !coyote_timer.is_stopped():
		coyote_timer.stop()
	
func is_obscured(state: PhysicsDirectSpaceState3D, observer: Camera3D) -> bool:
	#for observer in observers:
	for vertex in mesh.get_mesh().get_faces():
		var from = mesh.global_transform.basis * vertex + mesh.global_position
		var query = PhysicsRayQueryParameters3D.create(from, observer.global_position)
		query.exclude = [self] # this should change as more types of colliders are added
		var result = state.intersect_ray(query)
		if result and result.collider.name == "Player":
			return false
	return true

func destroy_self() -> void:
	print("Deleting...")
	emit_signal("destroyed")
	queue_free()
