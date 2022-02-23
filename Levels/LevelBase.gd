extends Spatial

export var next_level: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("Buttons").get_children():
		button.connect("triggered", self, "_on_button_triggered")
	get_node("Barriers/Door").connect("player_entered", self, "_on_player_complete")
	
	

func _on_button_triggered():
	for barrier in get_node("Barriers").get_children():
		#For each barrier, if all the connected buttons are in the correct states, change barrier from default state
		var power = true
		for button in get_node("Buttons").get_children():
			if barrier.id in button.powers:
				power = power and button.triggered
			elif barrier.id in button.unpowers:
				power = power and not button.triggered
		barrier.power(power)
	
	
		
func _on_player_complete():
	get_tree().change_scene_to(next_level)


