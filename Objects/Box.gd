extends RigidBody

onready var mesh = $MeshInstance
var held: bool = false
var hidden = false

var transparent_barriers = [self]

# Called when the node enters the scene tree for the first time.
func _ready():
	$VisibilityNotifier.connect("screen_exited", self, "_on_screen_exited")
	
func _physics_process(_delta):
	if !held:
		#Raycasts from all vertices 
		var space_state = get_world().direct_space_state
		for vertex in mesh.get_mesh().get_faces():
			var result = space_state.intersect_ray(mesh.global_transform.xform(vertex), get_viewport().get_camera().global_transform.origin, transparent_barriers)
			if result.size() <= 0 or result.collider.name == "Player":
				return
		queue_free()
		
func set_transparent_barriers(barriers):
	transparent_barriers += barriers
		
func _on_screen_exited():
	queue_free()

