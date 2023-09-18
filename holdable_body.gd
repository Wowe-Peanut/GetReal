class_name HoldableBody
extends RigidBody3D

@export var snap_velocity = 70.0
@export var throw_velocity = 15.0
@export var let_go_distance = 1.5


var hand: Node3D
var displacement: Vector3
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
	
	global_rotation = hand.global_rotation
	
	# translational spring movement
	displacement = hand_transform.origin - current_transform.origin
	#var force = hookes_law(linear_spring_stiffness, displacement, linear_spring_damping, linear_velocity)
	
	var velocity = displacement * displacement.length() * snap_velocity
	
	var collision = move_and_collide(velocity * delta, true)
	if collision:
		velocity = velocity.slide(collision.get_normal())
		
	move_and_collide(velocity * delta)
	

	distance = displacement.length()


func drop():
	hand = null
	collision_layer += 4 # re-add to pickable objects
	gravity_scale = 1
	apply_central_impulse(displacement * throw_velocity)
	print("dropped")
	emit_signal("on_dropped")


func pick_up(pickup_hand):
	hand = pickup_hand
	if hand.global_position.distance_to(global_position) > let_go_distance: 
		drop()
		return
	collision_layer -= 4 # remove from pickable objects
	gravity_scale = 0
	print("picked up")
	emit_signal("on_picked_up")
