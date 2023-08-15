extends RigidBody3D

@onready var mesh: MeshInstance3D = $Mesh
@onready var coyote_timer: Timer = $CoyoteTimer

@export var disabled: bool = false

signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coyote_timer.timeout.connect(destroy_self)


func start_coyote_timer() -> void:
	if not disabled and coyote_timer.is_stopped():
		coyote_timer.start()
		print("starting coyote_timer")


func stop_coyote_timer():
	if not coyote_timer.is_stopped():
		coyote_timer.stop()
		print("stopping coyote_timer")


func destroy_self() -> void:
	print("Deleting...")
	emit_signal("destroyed")
	queue_free()
