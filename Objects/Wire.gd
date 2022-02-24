extends Spatial


export(Array, Vector3) var points
export var power_wire:bool
var is_on: bool = false 
var width: float = .2
var on_color = Color("9960cc")
var off_color = Color("727272")


func _ready():
	draw_lines()

func draw_lines():
	#Corner
	for i in range(len(points)-1):
		var corner = MeshInstance.new()
		var mat = SpatialMaterial.new()
		mat.albedo_color = on_color if is_on == power_wire else off_color
		mat.emission = on_color
		mat.emission_enabled = is_on == power_wire
		mat.emission_energy = 3
		corner.material_override = mat
		corner.mesh = PlaneMesh.new()
		corner.translate(points[i])
		corner.scale = Vector3(width, width, width)
		add_child(corner)
		
		#Segment
		var segment = MeshInstance.new()
		mat = SpatialMaterial.new()
		mat.albedo_color = on_color if is_on == power_wire else off_color
		mat.emission = on_color
		mat.emission_enabled = is_on == power_wire
		mat.emission_energy = 3
		segment.material_override = mat
		segment.mesh = PlaneMesh.new()
		segment.translate((points[i]+points[i+1])/2)
	
		if points[i].x - points[i+1].x == 0: #Then Z is changing
			segment.scale.z = .5*points[i].distance_to(points[i+1])-width
			segment.scale.x = width
		else: #Else X is changing
			segment.scale.x = .5*points[i].distance_to(points[i+1])-width
			segment.scale.z = width
		add_child(segment)

func _on_button_triggered():
	is_on = not is_on
	for w in get_children():
		w.material_override.emission_enabled = is_on == power_wire
		w.material_override.albedo_color = on_color if is_on == power_wire else off_color
