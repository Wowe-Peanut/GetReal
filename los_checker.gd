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
	# get all boxes in the scene
	var boxes = get_tree().get_nodes_in_group("box")
	
	# iterate in all the boxes the player can see (even through other observers)
	for box in player_observer.observed:
		# stop coyote time if started
		if !box.coyote_timer.is_stopped():
			box.coyote_timer.stop()
		# remove box from list of all boxes in scene
		boxes.erase(box)
	
	# any remaining boxes must not be able to be seen. start coyote time for them
	for box in boxes:
		box.coyote_timer.start()
		pass
