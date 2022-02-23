extends Spatial


export(Array, Vector3) var points
export var power_wire:bool
var is_on: bool 
var width: float = .5

func _ready():
	draw_lines()

func draw_lines():
	for i in range(1, len(points)):
		var segment = MeshInstance.new()
		segment.mesh = PlaneMesh.new()
		var midpoint = (points[i]+points[i-1])/2
		segment.translate(midpoint)
		if midpoint.x-points[i].x == 0:
			segment.scale.x = points[i].distance_to(midpoint)
		else:
			pass
		
		
		add_child(segment)

func on():
	pass

func off():
	pass
