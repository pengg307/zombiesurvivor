extends Control
class_name VirtualJoystick

signal moved(direction: Vector2)

@export var dead_zone: float = 0.1
@export var max_radius: float = 50.0

var is_active = false
var touch_id = -1
var base_position = Vector2(0, 0)
var stick_position = Vector2(0, 0)
var base_circle: Circle2D = null
var stick_circle: Circle2D = null

func _ready():
	_setup_visuals()

func _setup_visuals():
	# 创建底座
	var base = ColorRect.new()
	base.name = "Base"
	base.color = Color(0.5, 0.5, 0.5, 0.3)
	base.size = Vector2(max_radius * 2, max_radius * 2)
	base.position = Vector2(-max_radius, -max_radius)
	add_child(base)
	
	# 创建摇杆头
	var stick = ColorRect.new()
	stick.name = "Stick"
	stick.color = Color(0.8, 0.8, 0.8, 0.5)
	stick.size = Vector2(max_radius * 0.6, max_radius * 0.6)
	stick.position = Vector2(-max_radius * 0.3, -max_radius * 0.3)
	add_child(stick)
	
	base_circle = base
	stick_circle = stick

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# 检查是否触摸到摇杆区域
			var rect = Rect2(position, size)
			if rect.has_point(event.position):
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
	
	stick_circle.position = offset - Vector2(max_radius * 0.3, max_radius * 0.3)
	
	# 计算方向
	if distance > max_radius * dead_zone:
		var direction = offset.normalized()
		emit_signal("moved", direction)
	else:
		emit_signal("moved", Vector2(0, 0))

func set_position(pos: Vector2):
	position = pos

func set_size(size: Vector2):
	size = size
	base_circle.size = size
	stick_circle.size = Vector2(size.x * 0.6, size.y * 0.6)
