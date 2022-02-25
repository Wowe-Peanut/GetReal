extends StaticBody

export var open_default: bool = false
export var transparent: bool = false
export var id: int = 1
var open: bool = true
var open_time:float = 1


func _ready():
	if transparent:
		var transparent_barrier = SpatialMaterial.new()
		transparent_barrier.flags_transparent = true
		transparent_barrier.albedo_color = Color(1, 1, 1, 0.1)
		$MeshInstance.material_override = transparent_barrier
	
	open = open_default
	if open:
		open()
	else:
		close()

func power(on):
	if on:
		#Go to non-default
		if open_default and open:
			close()
			open = false
		elif (not open_default) and (not open):
			open()
			open = true
	else:
		#Go to default
		if open_default and not open:
			open()
			open = true
		elif (not open_default) and open:
			close()
			open = false
			

func open():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "scale", scale, Vector3(scale.x, 1, scale.z), open_time*(scale.y/10.0),Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Tween.start()
	
func close():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "scale", scale, Vector3(scale.x, 10, scale.z), open_time*((10.0-scale.y)/10.0), Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Tween.start()


