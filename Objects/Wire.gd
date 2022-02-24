extends Spatial


export(Array, Vector3) var points
export var power_wire:bool
var is_on: bool = false 
var width: float = .2
var stick_out = .1
var segment_delay = 0.05
var on_color = Color("9960cc")
var off_color = Color("727272")



func _ready():
	draw_lines()

func draw_lines():
	var last_dir = 1 
	var up = 2
	for i in range(len(points)-1):
		#Segment
		var segment = MeshInstance.new()
		var mat = SpatialMaterial.new()
		mat.albedo_color = on_color if is_on == power_wire else off_color
		mat.emission = on_color
		mat.emission_enabled = is_on == power_wire
		mat.emission_energy = 3
		segment.material_override = mat
		segment.mesh = CubeMesh.new()
		segment.translate((points[i]+points[i+1])/2)
		
		if points[i].x - points[i+1].x != 0: #Then X is changing
			segment.scale.x = .5*points[i].distance_to(points[i+1])+width
			
			if up == 1:
				up = last_dir
			
			if up == 2:
				segment.scale.z = width
				segment.scale.y = stick_out
			elif up == 3:
				segment.scale.z = stick_out
				segment.scale.y = width
				
			last_dir = 1
		elif points[i].z - points[i+1].z != 0: #Then Z is changing
			segment.scale.z = .5*points[i].distance_to(points[i+1])+width
			
			if up == 3:
				up = last_dir
			
			
			if up == 2:
				segment.scale.x = width
				segment.scale.y = stick_out
			elif up == 1:
				segment.scale.y = width
				segment.scale.x = stick_out
				
			last_dir = 3
		elif points[i].y - points[i+1].y != 0: #Then Y is changing
			segment.scale.y = .5*points[i].distance_to(points[i+1])+width
			
			if up == 2:
				up = last_dir
			
			
			if up == 3:
				segment.scale.x = width
				segment.scale.z = stick_out
			elif up == 1:
				segment.scale.z = width
				segment.scale.x = stick_out
			last_dir = 2
		add_child(segment)
		

func _on_button_triggered():
	is_on = not is_on
	for w in get_children():
		yield(get_tree().create_timer(segment_delay), "timeout")
		w.material_override.emission_enabled = is_on == power_wire
		w.material_override.albedo_color = on_color if is_on == power_wire else off_color
		
