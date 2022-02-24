extends CenterContainer


onready var resume = $Panel/Align/Resume
onready var quit = $Panel/Align/Quit

# Called when the node enters the scene tree for the first time.
func _ready():
	resume.connect("pressed", self, "_on_resume_pressed")
	quit.connect("pressed", self, "_on_quit_pressed")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if !get_tree().paused:
			pause()
		else:
			unpause()
		get_tree().paused = !get_tree().paused
		print(get_tree().paused)
		
func pause():
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for button in get_node("Panel/Align").get_children():
		button.mouse_filter = MOUSE_FILTER_PASS

func unpause():
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for button in get_node("Panel/Align").get_children():
		button.mouse_filter = MOUSE_FILTER_IGNORE

func _on_resume_pressed():
	unpause()
	
func _on_quit_pressed():
	get_tree().quit()
