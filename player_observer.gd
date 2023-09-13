extends Observer

var observed: Array = []

func _physics_process(_delta) -> void:
	var boxes = get_tree().get_nodes_in_group("box")
	observed.clear()
	
	var state = get_world_3d().direct_space_state
	
	# sort the seen array to put all observers last so the player observer does not override through-observer schenannigans
	sort_seen()
	#print("seen: ", seen)
	
	for observed_object in seen:
		if observed_object.is_in_group("box"):
			var obscured = is_obscured(state, observed_object)
			modify_observed(observed_object, obscured)
		elif observed_object.is_in_group("mirror"):
			check_obscurity_through_reflection(state, observed_object.player_reflection)
	
	# iterate in all the boxes the player can see (even through other observers)
	for box in observed:
		# stop coyote time if started
		box.is_seen()
		# remove box from list of all boxes in scene
		boxes.erase(box)

	# any remaining boxes must not be able to be seen. start coyote time for them
	for box in boxes:
		box.not_seen()

func is_obscured(state: PhysicsDirectSpaceState3D, box: RigidBody3D) -> bool:
	for vertex in remove_duplicates(box.mesh.mesh.get_faces()):
		# cast a ray from the box to the player cam
		var result = cast_ray(state, box.global_transform * vertex, camera.global_position, [box])
		# if we hit nothing, the corner of the box is in the player (perhaps while holding it), count it as seen
		if result.size() == 0:
			return false
		# if we hit the player, we can see that corner of the box
		if result.collider == self_collider:
			return false
	return true
		
func check_obscurity_through_reflection(state: PhysicsDirectSpaceState3D, reflection) -> void:
	#print(observer.name + " seen: ", observer.seen)
	# sort boxes before any other seen objecets
	reflection.observer.sort_seen()
	
	for observed_object in reflection.observer.seen:
		# if we see a box, deal with the box
		if observed_object.is_in_group("box"):
			
			# if we already observe the box, no reason to check again, go to the next object
			if observed.has(observed_object): continue
			
			#get all the corners of the box
			var corners = convert_box_corners_to_global(remove_duplicates(observed_object.mesh.mesh.get_faces()), observed_object)
			# recursively check through all reflections to the player observer if the box can be seen
			var obscured = is_obscured_through_observer(state, observed_object, corners, reflection)
			modify_observed(observed_object, obscured)
		# if we see a mirror, continue the obscurity checks to the appropriate reflection
		elif observed_object.is_in_group("mirror"):
			# if the required connections between reflections is not set up, do not check obscurity until they are (sometimes it's a frame late)
			if reflection.recursive_reflection_connections.is_empty(): continue
			if !reflection.recursive_reflection_connections.has(observed_object): continue
			# recursively check other reflections
			check_obscurity_through_reflection(state, reflection.recursive_reflection_connections[observed_object])

func is_obscured_through_observer(state: PhysicsDirectSpaceState3D, box: RigidBody3D, corners: Array, reflection) -> bool:
	
	var reflected_corners_positions = []
	
	# for the first reflection, the exact corners of the box need to be projected onto the mirror surface.
	# if any corners of the box are obscured, ignore those corners in later checks, as the LOS is broken
	for corner in corners:
		var result = cast_ray(state, corner, reflection.observer.camera.global_position, [box])
		if result.is_empty():
			continue
		if result.collider == reflection.observer.self_collider:
			reflected_corners_positions.append(result.position)
	
	# recursively project the points from reflection to reflection until we reach the player
	while(true):
		reflected_corners_positions = recursively_reflect_corners(state, reflection, reflected_corners_positions)
		reflection = reflection.recursive_parent_reflection
		if reflection == self_collider:
			break
	
	# return if any points successfully reached the player: true if obscured, false if visible
	return reflected_corners_positions.is_empty()
	
func recursively_reflect_corners(state: PhysicsDirectSpaceState3D, reflection, reflected_corner_positions):
	var corners = []
	
	# from the projected points on the mirror, make sure the observer that caused the reflection can even see the points in their viewcone
	# then, take those points and make sure they aren't obscured 
	for corner in reflected_corner_positions:
		if !is_corner_observed(state, corner, reflection.recursive_parent_reflection.observer):
			continue
		var result = cast_ray(state, corner, reflection.recursive_parent_reflection.observer.camera.global_position, [reflection.observer.self_collider])
		if result.is_empty():
			continue
		if result.collider != reflection.recursive_parent_reflection.observer.self_collider:
			continue
		corners.append(result.position)
	return corners
	
	
func convert_box_corners_to_global(corners: Array, box: RigidBody3D):
	var global_corners = []
	for corner in corners:
		global_corners.append(box.global_transform * corner)
	return global_corners


func is_corner_observed(state: PhysicsDirectSpaceState3D, point_position: Vector3, higher_level_observer: Observer) -> bool:
	var point_query = PhysicsPointQueryParameters3D.new()
	point_query.collide_with_areas = true
	point_query.collide_with_bodies = false
	point_query.collision_mask = 256
	point_query.position = point_position
	
	# make sure only the observer looking at the point is the observer being checked.
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
