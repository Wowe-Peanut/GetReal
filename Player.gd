extends KinematicBody


onready var camera = $Camera
onready var raycast = $Camera/RayCast
onready var hold_position = $Camera/HoldPosition
var mouse_sensitivity = 0.002 
var gravity = -30
var max_speed = 8
var jump = 15
var velocity = Vector3()

var held_object: Object = null


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera.rotation.x = clamp($Camera.rotation.x, -1.2, 1.2)
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y += jump

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += global_transform.basis.x
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	input_dir = input_dir.normalized()
	return input_dir
	
func _physics_process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed
	
	if Input.is_action_just_pressed("interact"):
		if held_object:
			held_object.mode = RigidBody.MODE_RIGID
			held_object.collision_mask = 1
			held_object = null
		else:
			if raycast.get_collider():
				print("WOW")
				held_object = raycast.get_collider()
				held_object.mode = RigidBody.MODE_KINEMATIC
				held_object.collision_mask = 0
			
	if held_object:
		held_object.global_transform.origin = hold_position.global_transform.origin

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
