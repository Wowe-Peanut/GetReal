class_name HoldableBody
extends Node3D

@export var snap_velocity = 800.0
@export var let_go_distance = 1.2

@onready var kinematic = $CharacterBody3D
@onready var rigidbody = $RigidBody3D
@onready var collision = $CollisionShape3D
@onready var mesh = $MeshInstance3D


var current_physics: PhysicsBody3D
var hand: Node3D
var direction: Vector3
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
	current_physics = rigidbody
	set_physics_body(rigidbody)


func _physics_process(delta) -> void:
	if hand:
		move_hold_and_collide(delta)

		if distance > let_go_distance:
			print("too far")
			drop()


func set_physics_body(physics):
	physics.global_transform = current_physics.global_transform
	current_physics.remove_from_group("box")
	current_physics.process_mode = Node.PROCESS_MODE_DISABLED
	physics.process_mode = Node.PROCESS_MODE_INHERIT
	physics.add_to_group("box")
	collision.reparent(physics, false)
	mesh.reparent(physics, false)
	current_physics = physics


func move_hold_and_collide(delta) -> void:
	direction = global_position.direction_to(hand.global_position).normalized()
	distance = global_position.distance_to(hand.global_position)
	
	kinematic.velocity = direction * distance * delta * snap_velocity
	
	kinematic.move_and_slide()


func drop():
	hand = null
	kinematic.collision_layer += 4 # re-add to pickable objects
	rigidbody.collision_layer += 4
	print("dropped")
	emit_signal("on_dropped")


func pick_up(pickup_hand):
	hand = pickup_hand
	kinematic.collision_layer -= 4 # remove from pickable objects
	rigidbody.collision_layer -= 4
	print("picked up")
	emit_signal("on_picked_up")
