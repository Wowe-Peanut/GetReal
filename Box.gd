extends RigidBody

var held: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$VisibilityNotifier.connect("screen_exited", self, "_on_screen_exited")
	

func _physics_process(delta):
	if !held:
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(global_transform.origin, get_viewport().get_camera().global_transform.origin, [self])
		if result.size() > 0 and result.collider.name != "Player":
			queue_free()
	

func _on_screen_exited():
	queue_free()
