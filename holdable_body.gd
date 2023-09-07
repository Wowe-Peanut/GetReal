class_name HoldableBody
extends RigidBody3D

@export var snap_velocity = 40.0
@export var let_go_distance = 1.2

var linear_spring_stiffness = 10000.0
var linear_spring_damping = 800.0

var angular_spring_stiffness = 1200.0
var angular_spring_damping = 110.0


var hand: Node3D
var distance: float


var holdable: bool = true:
	set(value):
		if value:
			add_to_group("holdable")
		else:
			remove_from_group("holdable")
		holdable = value

signal on_picked_up
signal on_dropped

func _ready():
	add_to_group("holdable")

func _physics_process(delta) -> void:
	if hand:
		move_hold_and_collide(delta)

		if distance > let_go_distance:
			print("too far")
			drop()


func move_hold_and_collide(delta) -> void:
	
	

	var hand_transform: Transform3D = hand.global_transform
	var current_transform: Transform3D = global_transform
	
	# translational spring movement
	var displacement = hand_transform.origin - current_transform.origin
	var force = hookes_law(linear_spring_stiffness, displacement, linear_spring_damping, linear_velocity)
	
	apply_central_force(force * delta)

	# rotational spring movement (i don't understand basises)
	var rotation_difference = hand_transform.basis * current_transform.basis.inverse()
	var torque = hookes_law(angular_spring_stiffness, rotation_difference.get_euler(), angular_spring_damping, angular_velocity)
	
	apply_torque(torque * delta)

	distance = displacement.length()


func hookes_law(k: float, x: Vector3, damping: float, curr_velocity: Vector3):
	return (k * x) - (damping * curr_velocity)


func drop():
	hand = null
	collision_layer += 4 # re-add to pickable objects
	gravity_scale = 1
	print("dropped")
	emit_signal("on_dropped")


func pick_up(pickup_hand):
	hand = pickup_hand
	collision_layer -= 4 # remove from pickable objects
	gravity_scale = 0
	print("picked up")
	emit_signal("on_picked_up")
