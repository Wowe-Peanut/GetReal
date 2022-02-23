extends KinematicBody

const BOX = preload("res://Objects/Box.tscn")

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
	return input_dir.normalized()
	
func _process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump
	
	if Input.is_action_just_pressed("interact"):
		if is_instance_valid(held_object) and held_object:
			held_object.mode = RigidBody.MODE_RIGID
			held_object.collision_mask = 1
			held_object.held = false
			held_object = null
		else:
			if raycast.get_collider():
				held_object = raycast.get_collider()
				held_object.mode = RigidBody.MODE_KINEMATIC
				held_object.collision_mask = 0
				held_object.held = true
				
	if Input.is_action_just_pressed("use"):
		var new_box = BOX.instance()
		new_box.translate(Vector3(0, -5, 0))
		get_parent().get_node("Boxes").add_child(new_box)
		
			
	if is_instance_valid(held_object) and held_object:
		held_object.global_transform.origin = hold_position.global_transform.origin

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
