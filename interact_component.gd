extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().add_to_group("interactable")
	
	print(get_parent().get_groups())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
