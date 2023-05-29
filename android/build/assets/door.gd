@tool
extends StaticBody3D

@onready var detection = $DetectionArea

@export var closed: bool = true
var connections = []
var required_states = []

var buttons = []
var current_state = []

# Called when the node enters the scene tree for the first time.
func _ready():
	detection.connect("body_entered", _on_body_entered)
	
	for i in range(len(connections)):
		var button = get_node(connections[i])
		var required_state = required_states[i]
		buttons.append(button)
		button.connect("powered_changed", _on_button_powered_changed)
		current_state.append(required_state == button.powered)
		
	
	update_state()

func close():
	if closed: return
	
	print("closing")
	closed = true
	#play animation


func open():
	if !closed: return
	
	print("opening")
	closed = false
	#play animation
	

func update_state():
	if current_state.all(func(state): return state):
		open()
	else:
		close()
	
func _on_button_powered_changed(button, power):
	var index = buttons.find(button)
	var required_state = required_states[index]
	current_state[index] = required_state == power
	update_state()


func _on_body_entered(body):
	if closed:
		print("Door locked")
		return
	
	if body.name == "Player":
		print("Finished Level!")



func _get_property_list():
	var properties = []

	properties.append({
		"name": "connection_count",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_ARRAY | PROPERTY_USAGE_DEFAULT,
		"class_name": "Connections,connection_",
		"hint": PROPERTY_HINT_NONE
	})
	
	for i in connections.size():
		properties.append({
			"name": "connection_%d/button" % i,
			"type": TYPE_NODE_PATH
		})
		properties.append({
			"name": "connection_%d/required_state" % i,
			"type": TYPE_BOOL
		})
	
	return properties


func _get(property):
	if property == "connection_count":
		return connections.size()
	if property.begins_with("connection_"):
		var parts = property.trim_prefix("connection_").split("/")
		var i = parts[0].to_int()
		if parts[1] == "button":
			return connections[i]
		else:
			return required_states[i]


func _set(property, value):
	if property == "connection_count":
		if value != null:
			connections.resize(value)
			required_states.resize(value)
			for index in range(len(connections)):
				if not connections[index] is NodePath:
					connections[index] = NodePath()
				if not required_states[index] is bool:
					required_states[index] = false
			notify_property_list_changed()
	elif property.begins_with("connection_"):
		var parts = property.trim_prefix("connection_").split("/")
		var i = parts[0].to_int()
		if parts[1] == "button":
			if value is NodePath:
				connections[i] = value
		else:
			if value is bool:
				required_states[i] = value
