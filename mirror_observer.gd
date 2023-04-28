extends Observer

func check_corner_obscured(state: PhysicsDirectSpaceState3D, box: RigidBody3D, vertex: Vector3) -> Dictionary:
	return cast_ray(state, box, vertex, camera.global_position)
