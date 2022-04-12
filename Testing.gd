extends Spatial


onready var surface = $MirrorSurface
onready var viewport1 = $MirrorSurface/Viewport
onready var viewport2 = $MirrorSurface/Viewport2


# Called when the node enters the scene tree for the first time.
func _ready():
	surface.mesh.material.set_shader_param("cam1", viewport1.get_texture())
	surface.mesh.material.set_shader_param("cam2", viewport2.get_texture())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
