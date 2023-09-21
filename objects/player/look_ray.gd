extends RayCast3D

var targeted = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	var object = get_collider()
	
	if object and object.is_in_group("interactable"):
		print(object)
		targeted = object
