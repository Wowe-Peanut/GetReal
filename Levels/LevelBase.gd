extends Spatial

export var next_level: PackedScene

var connections = [[],[],[],[],[]] #Godot stupid with 2d arrays

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("Buttons").get_children():
		button.connect("triggered", self, "_on_button_triggered")
	
	for barrier in get_node("Barriers").get_children():
		connections[barrier.connection].append(barrier)
		
	get_node("Barriers/Door").connect("player_entered", self, "_on_player_complete")
	
		
		
func _on_button_triggered():
	#Connect buttons
	for i in range(len(connections)):
		var button_count = 0
		var unlock = true
		for button in get_node("Buttons").get_children():
			if button.connection == i:
				unlock = unlock and (button.triggered == button.unlocks)
				button_count += 1
		if button_count > 0:
			if unlock:
				for c in connections[i]:
					c.unlock()
			else:
				for c in connections[i]:
					c.lock()
		
func _on_player_complete():
	get_tree().change_scene_to(next_level)


