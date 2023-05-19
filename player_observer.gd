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
			modify_observed(observed_object, obscured)
		elif observed_object.is_in_group("mirror"):
			check_obscurity_through_reflection(state, observed_object.player_reflection, self)
	
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
		
func check_obscurity_through_reflection(state: PhysicsDirectSpaceState3D, reflection, higher_level_observer) -> void:
	#print(observer.name + " seen: ", observer.seen)
	reflection.observer.seen.sort_custom(func(a, b): return a.is_in_group("box") and not b.is_in_group("box"))
	for observed_object in reflection.observer.seen:
		if observed_object.is_in_group("box"):
			
			if observed.has(observed_object): continue
			
			var obscured = is_obscured_through_observer(state, reflection.observer, observed_object, higher_level_observer)
			modify_observed(observed_object, obscured)
		elif observed_object.is_in_group("mirror"):
			if reflection.observer.recursive_reflection_connections.is_empty(): continue
			check_obscurity_through_reflection(state, reflection.observer.recursive_reflection_connections[observed_object], reflection.observer)

func is_obscured_through_observer(state: PhysicsDirectSpaceState3D, observer: Observer, box: RigidBody3D, higher_level_observer) -> bool:
	
	var corners_on_screen = []
	var corners_obscured = []
	
	for vertex in remove_duplicate(box.mesh.mesh.get_faces()):
		# cast a ray from the box to the observer
		var result = cast_ray(state, box.global_transform * vertex, observer.camera.global_position, [box])
		if !result.is_empty():
			# check if the corner is even on screen (for very large mirrors)
			corners_on_screen.append(is_corner_observed(state, observer, result.position, higher_level_observer))
			if result.collider == observer.self_collider:
				# if we hit the observer, then cast another ray from the observer to the player cam
				result = cast_ray(state, result.position, camera.global_position, [observer.self_collider])
				# if we hit the player, we can see that corner of the box in the observer
				if result.collider == self_collider:
					corners_obscured.append(false)
				else:
					print("didn't hit self collider: ", result.collider)
		else:
			print("result empty")
	# if all corners are off screen, obscured
	if corners_on_screen.all(func(a): return !a):
		print("all corners off screen") 
		return true
	# if all corners obscured, obscured
	elif corners_obscured.all(func(a): return a): 
		print("all corners obscured", corners_obscured)
		return true
	# otherwise, we can see the box!
	else:
		return false
	
func is_corner_observed(state: PhysicsDirectSpaceState3D, mirror_observer: Observer, point_position: Vector3, higher_level_observer) -> bool:
	var point_query = PhysicsPointQueryParameters3D.new()
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	point_query.position = point_position
	#exclude the mirror's observer because the player's was the only other one in the scene
	#whatever is not excluded should be the next observer (lower recursion level) in the recursion (highest is player observer)
	var all_observers = get_tree().get_nodes_in_group("observer")
	all_observers.erase(higher_level_observer)
	var observer_exclude = []
	for observer in all_observers:
		observer_exclude.append(observer.get_rid())
	point_query.exclude = observer_exclude
	var result = state.intersect_point(point_query)
	return not result.is_empty()

func modify_observed(observed_object: RigidBody3D, obscured: bool) -> void:
	if not obscured and not observed.has(observed_object):
		observed.append(observed_object)

func _on_body_exited(body) -> void:
	if body in observed:
		observed.erase(body)
	super(body)
