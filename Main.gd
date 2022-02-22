extends Spatial


onready var door = $Barriers/Door


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("Buttons").get_children():
		button.connect("triggered", self, "_on_button_triggered")
		
		
func _on_button_triggered():
	var unlock = true
	for button in get_node("Buttons").get_children():
		if button.connection == 0:
			unlock = unlock and (button.triggered == button.opens)
	
	if unlock:
		door.open()
	else:
		door.close()



