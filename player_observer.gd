extends Observer

var observed: Array = []

func _physics_process(_delta) -> void:
	var state = get_world_3d().direct_space_state
	for observed_object in seen:
		if observed_object.is_in_group("box"):
			var obscured = is_obscured(state, observed_object)
			modify_observed(observed_object, obscured)
		else:
			check_observer(state, observed_object.observer)

func modify_observed(observed_object: RigidBody3D, obscured: bool) -> void:
	if obscured:
		var observed_len = len(observed)
		observed.erase(observed_object)
		if len(observed) != observed_len:
			LosChecker.emit_signal("observer_state_changed")
	elif not observed.has(observed_object):
		observed.append(observed_object)
		LosChecker.emit_signal("observer_state_changed")


func is_obscured(state: PhysicsDirectSpaceState3D, box: RigidBody3D) -> bool:
	for vertex in remove_duplicate(box.mesh.mesh.get_faces()):
		# cast a ray from the box to the player cam
		var result = cast_ray(state, box.global_transform * vertex, camera.global_position, [box])
		# if we hit the player, we can see that corner of the box
		if result.collider == self_collider:
			return false
	return true

func check_observer(state: PhysicsDirectSpaceState3D, observer: Observer) -> void:
	for observed_object in observer.seen:
		if observed_object.is_in_group("box"):
			var obscured = is_obscured_through_observer(state, observer, observed_object)
			modify_observed(observed_object, obscured)


func is_obscured_through_observer(state: PhysicsDirectSpaceState3D, observer: Observer, box: RigidBody3D) -> bool:
	for vertex in remove_duplicate(box.mesh.mesh.get_faces()):
		# cast a ray from the box to the observer
		var result = cast_ray(state, box.global_transform * vertex, observer.camera.global_position, [box])
		if result and result.collider == observer.self_collider:
			# if we hit the observer, then cast another ray from the observer to the player cam
			result = cast_ray(state, result.position, camera.global_position, [observer.self_collider])
			# if we hit the player, we can see that corner of the box in the observer
			if result.collider == self_collider:
				return false
	return true

func _on_body_exited(body) -> void:
	if body in observed:
		observed.erase(body)
	super(body)
