extends HoldableBody

@export var type: BoxType = BoxType.DEFAULT
@export var sticky: bool = false

@onready var mesh: MeshInstance3D = $Mesh
@onready var coyote_timer: Timer = $CoyoteTimer

@onready var sticky_check = $RayCast3D


enum BoxType {
	DEFAULT,
	PERSISTANT,
	INVERSE
}

signal destroyed

var disabled: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if type == BoxType.PERSISTANT: disabled = true
	
	coyote_timer.timeout.connect(destroy_self)
	
	print(get_groups())
	

func _physics_process(delta):
	if sticky_check.is_colliding():
		print(sticky_check.get_collider())
		emit_signal("to_drop")
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		freeze = true
		look_at(sticky_check.get_collision_point())



func disable(to_disable: bool) -> void:
	if type == BoxType.PERSISTANT or type == BoxType.INVERSE:
		return
		
	disabled = to_disable


func is_seen():
	if disabled: return
	
	match(type):
		BoxType.DEFAULT:
			stop_coyote_timer()
		BoxType.INVERSE:
			mesh.visible = false
			remove_from_group("holdable")
			print("disabled")


func not_seen():
	if disabled: return
	
	match(type):
		BoxType.DEFAULT:
			start_coyote_timer()
		BoxType.INVERSE:
			mesh.visible = true
			add_to_group("holdable")
			print("not disabled")


func start_coyote_timer() -> void:
	if coyote_timer.is_stopped():
		print("starting coyote_timer")
		coyote_timer.start()


func stop_coyote_timer():
	if not coyote_timer.is_stopped():
		print("stopping coyote_timer")
		coyote_timer.stop()


func destroy_self() -> void:
	print("Deleting...")
	emit_signal("destroyed")
	queue_free()
