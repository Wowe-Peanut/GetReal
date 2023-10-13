extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$InteractComponent.connect("on_interact", _on_lever_interact)
	
	
func _on_lever_interact(hand):
	print("Lever interact")

