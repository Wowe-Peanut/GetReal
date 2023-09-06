extends Node3D

@onready var rigid_body = $RigidBody3D
@onready var kinematic_body = $CharacterBody3D
@onready var collision = $CollisionShape3D
@onready var mesh = $MeshInstance3D

@onready var current_physics = kinematic_body

# Called when the node enters the scene tree for the first time.
func _ready():
	switch_current_physics()

var counter = 0
func _physics_process(delta):
	counter += 1
	if counter > 120:
		print("switch")
		switch_current_physics()
		counter = 0



func switch_current_physics():
	var new_physics = kinematic_body if current_physics == rigid_body else rigid_body
	new_physics.global_transform = current_physics.global_transform
	current_physics.process_mode = Node.PROCESS_MODE_DISABLED
	new_physics.process_mode = Node.PROCESS_MODE_INHERIT
	collision.reparent(new_physics, false)
	mesh.reparent(new_physics, false)
	current_physics = new_physics
