extends ARVRController

signal activated
signal deactivated

onready var mirror = $Mirror

func _ready():
	connect("button_pressed", self, "_on_button_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_is_active():
		if !visible:
			visible = true
			print("Activated " + name)
			emit_signal("activated")
	elif visible:
		visible = false
		print("Deactivated " + name)
		emit_signal("deactivated")
	
func _on_button_pressed(button):
	if button == 15 and mirror:
		mirror.visible = !mirror.visible
