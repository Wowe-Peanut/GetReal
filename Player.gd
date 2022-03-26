extends KinematicBody


onready var camera = $ARVRCamera
var mouse_sensitivity = 0.002 
var gravity = -30
var max_speed = 2
var jump = 10
var velocity = Vector3()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
	
func get_input():
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
	
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
	return input_dir.normalized()
	
func _process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
