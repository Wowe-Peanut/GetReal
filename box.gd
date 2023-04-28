extends RigidBody3D

@onready var mesh: MeshInstance3D = $Mesh
@onready var coyote_timer: Timer = $CoyoteTimer


signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coyote_timer.timeout.connect(destroy_self)


func destroy_self() -> void:
	print("Deleting...")
	emit_signal("destroyed")
	queue_free()
