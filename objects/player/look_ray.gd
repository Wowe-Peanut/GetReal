extends RayCast3D

var targeted = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
	var object = get_collider()
	
	if object:
		if object != targeted:
			targeted = object
			object.target()
	else:
		if targeted: targeted.stop_target()
		targeted = null
