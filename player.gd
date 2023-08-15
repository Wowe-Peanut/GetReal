extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 7 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1.5 # m
@export_range(0.1, 9.25, 0.05, "or_greater") var camera_sens: float = 3

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var camera: Camera3D = $PlayerCam
@onready var look_ray: RayCast3D = $PlayerCam/LookRay
@onready var observer = $PlayerCam/PlayerObserver
@onready var right_hand = $PlayerCam/RightHand
@onready var left_hand = $PlayerCam/LeftHand

func _ready() -> void:
	capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	
	if event.is_action_pressed("jump"): jumping = true
	if event.is_action_pressed("right_hand_interact"): toggle_hold_object(true)
	if event.is_action_pressed("left_hand_interact"): toggle_hold_object(false)
	if event.is_action_pressed("aim"): aim(true)
	if event.is_action_released("aim"): aim(false)
	if event.is_action_pressed("reset"): get_tree().reload_current_scene()
	if event.is_action_pressed("ui_cancel"): get_tree().quit()

func _process(delta: float) -> void:
	if mouse_captured: _rotate_camera(delta)	
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(delta: float, sens_mod: float = 1.0) -> void:
	#look_dir += Input.get_vector("look_left","look_right","look_up","look_down")
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_back")
	var _forward: Vector3 = camera.transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func toggle_hold_object(is_right_hand: bool) -> void:
	var collider = look_ray.get_collider() as Node3D
	
	right_hand.toggle_hold(collider) if is_right_hand else left_hand.toggle_hold(collider)

func aim(to_aim):
	if right_hand.has_object() and right_hand.held_object.name == "Camera":
		right_hand.toggle_aim(to_aim)
	if left_hand.has_object() and left_hand.held_object.name == "Camera":
		left_hand.toggle_aim(to_aim)
		
