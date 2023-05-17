extends Node

var used_layers = [1, 2, 4]

func get_next_layer() -> int:
	for i in range(100):
		var layer = pow(2, i)
		if not is_in_used_layers(layer):
			used_layers.append(layer)
			return layer
	push_error("Too many layers used")
	return -1
	
func is_in_used_layers(layer) -> bool:
	for layer_to_check in used_layers:
		if layer == layer_to_check: return true
	return false
