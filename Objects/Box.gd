extends RigidBody

onready var mesh = $MeshInstance
onready var audio = $AudioStreamPlayer3D
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
			if hidden:
				return
			var result = space_state.intersect_ray(mesh.global_transform.xform(vertex), get_viewport().get_camera().global_transform.origin, transparent_barriers)
			if result.size() <= 0 or result.collider.name == "Player":
				return
		if not hidden:
			vanish()
		
func set_transparent_barriers(barriers):
	transparent_barriers += barriers
		
func _on_screen_exited():
	if not hidden:
		vanish()

func vanish():
	hide()
	remove_child($CollisionShape)
	hidden = true
	audio.play()
	yield(audio,"finished")
	queue_free()
