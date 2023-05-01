extends Node

var observers: Array[Node3D] = []
var lines: Array = []

var player_observer

signal observer_state_changed()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	player_observer = get_tree().get_nodes_in_group("player_observer")[0]
	print(player_observer)
	
	connect("observer_state_changed", _on_observer_state_changed)

func _on_observer_state_changed():
	pass
