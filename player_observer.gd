extends Observer

var observed: Array = []

func _physics_process(_delta) -> void:
	var boxes = get_tree().get_nodes_in_group("box")
	observed.clear()
	
	var state = get_world_3d().direct_space_state
	
	# sort the seen array to put all observers last so the player observer does not override through-observer schenannigans
	seen.sort_custom(func(a, b): return a.is_in_group("box") and not b.is_in_group("box"))
	#print("seen: ", seen)
	
	for observed_object in seen:
		if observed_object.is_in_group("box"):
			var obscured = is_obscured(state, observed_object)
			modify_observed(observed_object, obscured, true)
		else:
			is_observer_obscured(state, observed_object.observer)
	
	#print("observed: ", observed)
	
	# iterate in all the boxes the player can see (even through other observers)
	for box in observed:
		# stop coyote time if started
		if !box.coyote_timer.is_stopped():
			box.coyote_timer.stop()
		# remove box from list of all boxes in scene
		boxes.erase(box)

	# any remaining boxes must not be able to be seen. start coyote time for them
	for box in boxes:
		if box.coyote_timer.is_stopped(): box.coyote_timer.start()
		pass

func is_obscured(state: PhysicsDirectSpaceState3D, box: RigidBody3D) -> bool:
	for vertex in remove_duplicate(box.mesh.mesh.get_faces()):
		# cast a ray from the box to the player cam
		var result = cast_ray(state, box.global_transform * vertex, camera.global_position, [box])
		# if we hit the player, we can see that corner of the box
		if result.collider == self_collider:
			return false
	return true
		
func is_observer_obscured(state: PhysicsDirectSpaceState3D, observer: Observer) -> void:
	for observed_object in observer.seen:
		if observed_object.is_in_group("box"):
			var obscured = is_obscured_through_observer(state, observer, observed_object)
			modify_observed(observed_object, obscured, false)

func is_obscured_through_observer(state: PhysicsDirectSpaceState3D, observer: Observer, box: RigidBody3D) -> bool:
	
	var corners_on_screen = []
	var corners_obscured = []
	
	for vertex in remove_duplicate(box.mesh.mesh.get_faces()):
		# cast a ray from the box to the observer
		var result = cast_ray(state, box.global_transform * vertex, observer.camera.global_position, [box])
		# check if the corner is even on screen (for very large mirrors)
		corners_on_screen.append(is_corner_observed(state, observer, result.position))
		if result and result.collider == observer.self_collider:
			# if we hit the observer, then cast another ray from the observer to the player cam
			result = cast_ray(state, result.position, camera.global_position, [observer.self_collider])
			# if we hit the player, we can see that corner of the box in the observer
			if result.collider == self_collider:
				corners_obscured.append(false)
	# if all corners are off screen, obscured
	if corners_on_screen.all(func(a): return !a): 
		return true
	# if all corners obscured, obscured
	elif corners_obscured.all(func(a): return a): 
		return true
	# otherwise, we can see the box!
	else:
		return false
	
func is_corner_observed(state: PhysicsDirectSpaceState3D, observer: Observer, point_position: Vector3) -> bool:
	var point_query = PhysicsPointQueryParameters3D.new()
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	point_query.position = point_position
	point_query.exclude = [observer.get_rid()]
	var result = state.intersect_point(point_query)
	return not result.is_empty()

func modify_observed(observed_object: RigidBody3D, obscured: bool, direct_player) -> void:
	if not obscured and not observed.has(observed_object):
		observed.append(observed_object)

func _on_body_exited(body) -> void:
	if body in observed:
		observed.erase(body)
	super(body)
