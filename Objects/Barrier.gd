extends StaticBody

onready var animation = $AnimationPlayer

export var open_default: bool = false
export var transparent: bool = false
export var id: int = 1
var open: bool = true

func _ready():
	
	if transparent:
		var transparent_barrier = SpatialMaterial.new()
		transparent_barrier.flags_transparent = true
		transparent_barrier.albedo_color = Color(1, 1, 1, 0.1)
		$MeshInstance.material_override = transparent_barrier
	
	open = open_default
	if open:
		animation.play("open")
	else:
		animation.play("close")

func power(on):
	if on:
		#Go to non-default
		if open_default and open:
			animation.play("close")
			open = false
		elif (not open_default) and (not open):
			animation.play("open")
			open = true
	else:
		#Go to default
		if open_default and not open:
			animation.play("open")
			open = true
		elif (not open_default) and open:
			animation.play("close")
			open = false
	



