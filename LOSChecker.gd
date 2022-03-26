extends Spatial

var view_cones = []
var headset_view_cone: Area = null

var checked_view_cones = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for view_cone in get_tree().get_nodes_in_group("view_cones"):
		view_cones.append(view_cone)
		if view_cone.name == "HeadsetViewcone":
			headset_view_cone = view_cone
			
	#wait for scene tree to settle before visibility checks, or else boxes disappear too fast
	set_physics_process(false)
	for i in range(30):
		yield(get_tree(), "idle_frame")
	set_physics_process(true)
	
func _physics_process(delta):
	checked_view_cones.clear()
	for box in get_tree().get_nodes_in_group("boxes"):
		checked_view_cones.append(headset_view_cone)
		#check if box can be seen immediately
		if headset_view_cone in box.seen_by and box.unobscured[box.seen_by.find(headset_view_cone)]:
			#box is seen by player cam, return
			return
		else:
			#for each mirror currently seen, check mirror visibility for box and other mirrors
			for mirror in headset_view_cone.get_overlapping_areas():
				mirror = mirror.get_parent()
				var mirror_view_cone = mirror.get_node("Viewport/MirrorCam").get_child(0)
				#if mirror obscured, skip it, no LOS
				if get_world().direct_space_state.intersect_ray(headset_view_cone.global_transform.origin, mirror.get_node("MirrorOrigin").global_transform.origin, [headset_view_cone]).size() > 0:
					continue
				else:
					checked_view_cones.append(mirror_view_cone)
					#the player can see this mirror, have it check for the box
					if mirror_view_cone in box.seen_by and box.unobscured[box.seen_by.find(mirror_view_cone)]:
						#mirror can see box, return
						return
					else:
						#mirror cannot see box, have it check other mirrors.
						if recursively_check_box_los(mirror_view_cone, box, get_world().direct_space_state):
							return
		#box cannot be seen at all, delete
		box.disappear()
	
func recursively_check_box_los(view_cone, box, space_state) -> bool:
	for mirror in view_cone.get_overlapping_areas():
		mirror = mirror.get_parent()
		var mirror_view_cone = mirror.get_node("Viewport/MirrorCam").get_child(0)
		if space_state.intersect_ray(view_cone.get_node("../../../MirrorOrigin").global_transform.origin, mirror.get_node("MirrorOrigin").global_transform.origin, [view_cone]).size() > 0:
			continue
		else:
			checked_view_cones.append(view_cone)
			if mirror_view_cone in box.seen_by and box.unobscured[box.seen_by.find(mirror_view_cone)]:
				return true
			elif not mirror_view_cone in checked_view_cones:
				return recursively_check_box_los(mirror_view_cone, box, space_state)
	#not sure about this, but whatever
	return false
