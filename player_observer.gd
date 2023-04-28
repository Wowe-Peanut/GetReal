extends Observer

var observed: Array = []

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
			check_observer(state, observed_object.observer)

func is_obscured(state: PhysicsDirectSpaceState3D, observed: RigidBody3D) -> bool:
	for vertex in remove_duplicate(observed.mesh.mesh.get_faces()):
		var result = cast_ray(state, observed, vertex, camera.global_position)
		if result.collider == self_collider:
			return false
	return true

func check_observer(state: PhysicsDirectSpaceState3D, observer: Observer) -> void:
	#print(observer.seen)
	for observed_object in observer.seen:
		if observed_object.is_in_group("box"):
			var obscured = is_obscured_through_observer(state, observer, observed_object)
			if obscured:
				var len = len(observed)
				observed.erase(observed_object)
				if len(observed) != len:
					LosChecker.emit_signal("observer_state_changed")
			elif not observed.has(observed_object):
				observed.append(observed_object)
				LosChecker.emit_signal("observer_state_changed")


func is_obscured_through_observer(state: PhysicsDirectSpaceState3D, observer: Observer, observed_object: RigidBody3D) -> bool:
	for vertex in remove_duplicate(observed_object.mesh.mesh.get_faces()):
		var result = observer.check_corner_obscured(state, observed_object, vertex)
		if result and result.collider == observer.self_collider:
			var query = PhysicsRayQueryParameters3D.create(result.position, camera.global_position)
			query.exclude = [observer.self_collider] # this should change as more types of colliders are added
			result = state.intersect_ray(query)
			if result.collider == self_collider:
				return false
	return true

func _on_body_exited(body) -> void:
	if body in observed:
		observed.erase(body)
	super(body)
