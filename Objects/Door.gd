extends StaticBody

export var open_default: bool  = false
export var id: int = 0

onready var animation = $AnimationPlayer
onready var tween = $Tween
onready var dr = $DoorRight
onready var dl = $DoorLeft
onready var sound = $AudioStreamPlayer3D

var open: bool = false
var player_in: bool = false
var animation_time: float = 0.75

signal player_entered()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_body_entered")
	$Area.connect("body_exited", self, "_on_body_exit")
	open = open_default
	if open:
		open()
	else:
		close()

func _on_body_entered(body):
	if "Player" in body.name:
		player_in = true
		if open:
			emit_signal("player_entered")

func _on_body_exit(body):
	if "Player" in body.name:
		player_in = false

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
	#Scale.x 0.75 --> 0
	#Transform.x -0.78 -->  -1.5
	tween.stop_all()
	var length = animation_time*(dl.scale.x/0.75)
	#Door Left
	tween.interpolate_property(dl,"scale",dl.scale,Vector3(0, 2.75, 0.1),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.interpolate_property(dl,"translation",dl.translation,Vector3(-1.5,2.75,0.3),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	#Door Right
	tween.interpolate_property(dr,"scale",dr.scale,Vector3(0, 2.75, 0.1),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.interpolate_property(dr,"translation",dr.translation,Vector3(1.5,2.75,0.3),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	sound.play()
	
	if player_in:
		yield(tween,"tween_all_completed")
		emit_signal("player_entered")

	
func close():
	#Scale.x 0 --> 0.75
	#Transform.x -1.5 --> -0.78
	tween.stop_all()
	var length = animation_time*((0.75-dl.scale.x)/0.75)
	#Door Left
	tween.interpolate_property(dl,"scale",dl.scale,Vector3(0.75, 2.75, 0.1),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.interpolate_property(dl,"translation",dl.translation,Vector3(-0.78,2.75,0.3),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	#Door Right
	tween.interpolate_property(dr,"scale",dr.scale,Vector3(0.75, 2.75, 0.1),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.interpolate_property(dr,"translation",dr.translation,Vector3(0.78,2.75,0.3),length,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	sound.play()
