extends Observer


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
		else:
			print(observed_object.observer.seen)

func is_obscured(state: PhysicsDirectSpaceState3D, observed: RigidBody3D) -> bool:
	for vertex in remove_duplicate(observed.mesh.mesh.get_faces()):
		var result = cast_ray(state, observed, vertex, camera.global_position)
		if result.collider == self_collider:
			return false
	return true
