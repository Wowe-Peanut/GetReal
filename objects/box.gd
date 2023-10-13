extends HoldableBody

@export var type: BoxType = BoxType.DEFAULT
@export var sticky: bool = false

@onready var mesh: MeshInstance3D = $Mesh
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var interact_component = $InteractComponent


enum BoxType {
	DEFAULT,
	PERSISTANT,
	INVERSE
}

signal destroyed

var disabled: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == BoxType.PERSISTANT: disabled = true
	
	interact_component.connect("on_interact", _on_box_interact)
	coyote_timer.timeout.connect(destroy_self)


func drop():
	disable(false)
	interact_component.disable(false)
	super()

func pick_up(pickup_hand):
	disable(true)
	interact_component.disable(true)
	super(pickup_hand)


func disable(to_disable: bool) -> void:
	if type == BoxType.PERSISTANT or type == BoxType.INVERSE:
		return
		
	disabled = to_disable


func is_seen():
	if disabled: return
	
	match(type):
		BoxType.DEFAULT:
			stop_coyote_timer()
		BoxType.INVERSE:
			mesh.visible = false


func not_seen():
	if disabled: return
	
	match(type):
		BoxType.DEFAULT:
			start_coyote_timer()
		BoxType.INVERSE:
			mesh.visible = true


func _on_box_interact(pickup_hand):
	if hand: return
	
	pickup_hand.held_object = self
	connect("on_dropped", pickup_hand._on_dropped)
	pick_up(pickup_hand)


func start_coyote_timer() -> void:
	if coyote_timer.is_stopped():
		print("starting coyote_timer")
		coyote_timer.start()


func stop_coyote_timer():
	if not coyote_timer.is_stopped():
		print("stopping coyote_timer")
		coyote_timer.stop()


func destroy_self() -> void:
	print("Deleting...")
	emit_signal("destroyed")
	queue_free()
