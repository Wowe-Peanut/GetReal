extends Spatial


onready var door = $Door


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("Buttons").get_children():
		button.connect("triggered", self, "_on_button_triggered")
		
		
func _on_button_triggered():
	for button in get_node("Buttons").get_children():
		if !button.triggered:
			door.locked = true
			return
	door.locked = false



