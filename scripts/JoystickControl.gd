extends Control
class_name JoystickControl

signal moved(direction: Vector2)

@export var dead_zone: float = 0.1
@export var max_radius: float = 50.0

var is_active = false
var touch_id = -1
var base_position = Vector2(0, 0)
var stick_position = Vector2(0, 0)

func _ready():
	_setup_visuals()

func _setup_visuals():
	var base = ColorRect.new()
	base.name = "Base"
	base.color = Color(0.5, 0.5, 0.5, 0.3)
	base.size = Vector2(max_radius * 2, max_radius * 2)
	base.position = Vector2(-max_radius, -max_radius)
	add_child(base)
	
	var stick = ColorRect.new()
	stick.name = "Stick"
	stick.color = Color(0.8, 0.8, 0.8, 0.5)
	stick.size = Vector2(max_radius * 0.6, max_radius * 0.6)
	stick.position = Vector2(-max_radius * 0.3, -max_radius * 0.3)
	add_child(stick)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var rect = get_global_rect()
			if rect.has_point(event.global_position):
				is_active = true
				touch_id = event.index
				base_position = event.position
				stick_position = event.position
				_update_stick_position()
		elif event.index == touch_id:
			is_active = false
			touch_id = -1
			stick_position = base_position
			_update_stick_position()
			emit_signal("moved", Vector2(0, 0))
	
	elif event is InputEventScreenDrag and is_active:
		if event.index == touch_id:
			stick_position = event.position
			_update_stick_position()

func _update_stick_position():
	var offset = stick_position - base_position
	var distance = offset.length()
	
	if distance > max_radius:
		offset = offset.normalized() * max_radius
		distance = max_radius
	
	var stick = get_node("Stick")
	if stick:
		stick.position = offset - Vector2(max_radius * 0.3, max_radius * 0.3)
	
	if distance > max_radius * dead_zone:
		var direction = offset.normalized()
		emit_signal("moved", direction)
	else:
		emit_signal("moved", Vector2(0, 0))
