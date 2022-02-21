extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_area_entered")


func _on_area_entered(body):
	if body.name == "Box":
		print("triggered")
