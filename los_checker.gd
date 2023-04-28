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
	print("state_changed")
	var boxes = get_tree().get_nodes_in_group("box")
	
	
	print("seen: ", player_observer.seen)
	print("observed: ", player_observer.observed)
	for box in player_observer.observed:
		if !box.coyote_timer.is_stopped():
			box.coyote_timer.stop()
		boxes.erase(box)
		
	for box in boxes:
		box.coyote_timer.start()
		pass
	




""" ALGORITHM

What we can detect: when an observers state changes (when what it can see changes)

if player changed: deal with immeditely (1)
else: update observer

(1): 
	if new box in view_cone: check obscured
	if new observer: check check line of sight from observer to player
		if los: (2)
		else: end
(2):
	check los from all seen in observer to player


"""
