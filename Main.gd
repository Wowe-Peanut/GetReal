extends Spatial


var connections = [[],[],[],[],[]] #Godot stupid with 2d arrays

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("Buttons").get_children():
		button.connect("triggered", self, "_on_button_triggered")
	
	for barrier in get_node("Barriers").get_children():
		connections[barrier.connection].append(barrier)
	
		
		
func _on_button_triggered():
	#Connect buttons
	for i in range(len(connections)):
		var button_count = 0
		var change = true
		for button in get_node("Buttons").get_children():
			if button.connection == i:
				change = change and (button.triggered == button.unlocks)
				button_count += 1
		if button_count > 0:
			for c in connections[i]:
				if c.locked:
					c.unlock()
				else:
					c.lock()
		
	


