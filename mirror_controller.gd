extends Node

var MAX_REFLECTIONS = 20
var used_layers = [1, 2, 4]

func get_next_layer() -> int:
	for i in range(MAX_REFLECTIONS):
		var layer = pow(2, i)
		if not is_in_used_layers(layer):
			used_layers.append(layer)
			return layer
	return -1
	
func is_in_used_layers(layer) -> bool:
	for layer_to_check in used_layers:
		if layer == layer_to_check: return true
	return false
