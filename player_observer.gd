extends Observer

var observed: Array = []

func _physics_process(_delta) -> void:
	var boxes = get_tree().get_nodes_in_group("box")
	
	var state = get_world_3d().direct_space_state
	
	seen.sort_custom(func(a, b): return a.is_in_group("box") and not b.is_in_group("box"))
	print("seen: ", seen)
	
	for observed_object in seen:
		if observed_object.is_in_group("box"):
			var obscured = is_obscured(state, observed_object)
			modify_observed(observed_object, obscured, true)
		else:
			is_observer_obscured(state, observed_object.observer)
			
	#when observer checks before the player, the player unable to see the box overrides the observer check
	
	print("observed: ", observed)
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

func modify_observed(observed_object: RigidBody3D, obscured: bool, direct_player) -> void:
	if obscured:
		#print("direct player ", direct_player)
		observed.erase(observed_object)
	elif not observed.has(observed_object):
		observed.append(observed_object)

func _on_body_exited(body) -> void:
	if body in observed:
		observed.erase(body)
	super(body)
