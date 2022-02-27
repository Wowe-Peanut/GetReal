extends Spatial

export var next_level: PackedScene



# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("Buttons").get_children():
		button.connect("triggered", self, "_on_button_triggered")
		
		for child in button.get_children():
			if "Wire" in child.name:
				button.connect("triggered", child, "_on_button_triggered")
			
	get_node("Barriers/Door").connect("player_entered", self, "_on_player_complete")
	
	setup_transparent_barriers()
	
	
func setup_transparent_barriers():
	var transparent_barriers = []
	for barrier in get_node("Barriers").get_children():
		if "transparent" in barrier and barrier.transparent:
			transparent_barriers.append(barrier)
			
	for box in get_node("Boxes").get_children():
		box.set_transparent_barriers(transparent_barriers)

func disable_boxs():
	for box in get_node("Boxes").get_children():
		box.visibility.disconnect("screen_exited", box, "_on_screen_exited")

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		disable_boxs()
		get_tree().reload_current_scene()
	
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
	disable_boxs()
	get_tree().change_scene_to(next_level)


