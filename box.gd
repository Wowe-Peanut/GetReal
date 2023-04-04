extends RigidBody3D

@onready var visibility_check: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var mesh: MeshInstance3D = $Mesh
@onready var coyote_timer: Timer = $CoyoteTimer

var observers: Dictionary = {}
var to_delete: bool = false

signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coyote_timer.timeout.connect(destroy_self)
	for observer in get_tree().get_nodes_in_group("observer"):
		observers[observer.name] = observer


func _physics_process(_delta: float) -> void:
	# if off screen and ct off: start coyote timer
	if !visibility_check.is_on_screen() and coyote_timer.is_stopped():
		print("off screen")
		coyote_timer.start()
	# if on screen and ct off, and obscured, ct on
	print("check one")
	if visibility_check.is_on_screen() and is_obscured(get_world_3d().direct_space_state) and coyote_timer.is_stopped():
		print("on screen, obscured")
		coyote_timer.start()
	# if on screen and unobscured stop and ct on, don't delete ct off
	print("check two")
	if visibility_check.is_on_screen() and !is_obscured(get_world_3d().direct_space_state) and !coyote_timer.is_stopped():
		print("on screen not obscured")
		coyote_timer.stop()


func is_obscured(state: PhysicsDirectSpaceState3D) -> bool:
	for observer in observers:
		if observer == "PlayerCam":
			if is_obscured_player(state):
				return true

		if observer == "MirrorCam":
			if is_obscured_mirror(state):
				return true
				
	return false



func cast_ray(state: PhysicsDirectSpaceState3D, vertex: Vector3, observer_position: Vector3) -> Dictionary:
	# I THINK ISSUE IS HERE, corner of the box is not correct in world space
	var from = mesh.global_transform * vertex + mesh.global_position
	var query = PhysicsRayQueryParameters3D.create(from, observer_position)
	query.exclude = [self] # this should change as more types of colliders are added
	
	print(from)
	print(observer_position)
	
	return state.intersect_ray(query)


func is_obscured_player(state: PhysicsDirectSpaceState3D) -> bool:
	# for each corner of the box
	for vertex in mesh.get_mesh().get_faces():
		# cast a ray to the player cam
		var result = cast_ray(state, vertex, observers["PlayerCam"].global_position)
		# if we hit the player, we can see the box, return true
		if result and result.collider.name == "Player":
			return false
	# if all the corners are accounted for and not returned true, we can't see the box
	print("player obscured")
	return true


func is_obscured_mirror(state: PhysicsDirectSpaceState3D) -> bool:
	# if the mirror is not even facing the box, do not even check for obscurity (you can't see the box)
	if observers["MirrorCam"].global_transform.basis.z.normalized().dot(global_position) < 0:
		print("mirror can't see box") 
		return true
	# if the player is not looking at the mirror, do not even check for obscurity (you can't see the mirror, therefore box in mirror)
	if observers["PlayerCam"].global_transform.basis.z.normalized().dot(observers["MirrorCam"].global_transform.basis.z.normalized()) > 0: 
		print("player can't see mirror")
		return true
	# loop through all the corners of the box and cast a ray to the mirror cam (rotation of cam does not matter if position is correct [it is])
	for vertex in mesh.get_mesh().get_faces():
		var result = cast_ray(state, vertex, observers["MirrorCam"].global_position)
		# if we hit the mirror, immediately cast to the player to see if the player can see the reflected position of the box
		print(result)
		if result and result.collider.name == "Mirror":
			result = cast_ray(state, result.position, observers["PlayerCam"].global_position)
			# if the player can see the box corner in the mirror, we can see the box
			if result and result.collider.name == "Player":
				return false
	# if all the corners are accounted for and not returned true, we can't see the box
	print("mirror obscured")
	return true


func destroy_self() -> void:
	print("Deleting...")
	emit_signal("destroyed")
	queue_free()
