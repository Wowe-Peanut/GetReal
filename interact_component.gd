extends Node


signal on_targeted
signal on_stop_targeted


func target():
	print("targeted: ", self.name)
	emit_signal("on_targeted")
	

func stop_target():
	print("stop targeted: ", self.name)
	emit_signal("on_stop_targeted")
