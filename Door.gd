extends StaticBody


var locked: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if !locked and body.name == "Player":
		print("Player in door!")
