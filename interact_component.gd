extends Area3D

@export var mesh: GeometryInstance3D

signal on_targeted
signal on_stop_targeted
signal on_interact(hand)


var disabled: bool = false

func disable(to_disable):
	disabled = to_disable

func target():
	if disabled: return
	#print("targeted: ", self.name)
	emit_signal("on_targeted")


func stop_target():
	if disabled: return
	#print("stop targeted: ", self.name)
	emit_signal("on_stop_targeted")


func interact(hand):
	emit_signal("on_interact", hand)
