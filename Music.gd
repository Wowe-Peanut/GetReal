extends Node

onready var Permanence = load("res://assets/Noise/PermanenceFix.mp3")
var AudioPlayer: AudioStreamPlayer

func _ready():
	AudioPlayer = AudioStreamPlayer.new()
	AudioPlayer.stream = Permanence
	AudioPlayer.bus = AudioServer.get_bus_name(2)
	get_tree().root.call_deferred("add_child", AudioPlayer)
	

func play():
	AudioPlayer.play()

func stop():
	AudioPlayer.stop()
