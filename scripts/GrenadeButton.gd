extends Control
class_name GrenadeButton

signal pressed

@export var cooldown_time: float = 2.0

var is_on_cooldown = false
var cooldown_timer = 0.0

var bg_rect: ColorRect = null
var text_label: Label = null

func _ready():
	_setup_visuals()
	size = Vector2(80, 80)
	position = Vector2(580, 1100)

func _setup_visuals():
	# 背景
	bg_rect = ColorRect.new()
	bg_rect.name = "Background"
	bg_rect.color = Color(1, 0.3, 0.3, 0.6)
	bg_rect.size = size
	bg_rect.position = Vector2(0, 0)
	add_child(bg_rect)
	
	# 边框
	var border = ColorRect.new()
	border.name = "Border"
	border.color = Color(1, 1, 1, 0.5)
	border.size = size - Vector2(4, 4)
	border.position = Vector2(2, 2)
	add_child(border)
	
	# 文字
	text_label = Label.new()
	text_label.name = "Text"
	text_label.text = "💣"
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.add_theme_font_size_override("font_size", 32)
	text_label.size = size
	text_label.position = Vector2(0, 0)
	add_child(text_label)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and get_global_rect().has_point(event.global_position):
			_on_pressed()
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_global_rect().has_point(event.position):
				_on_pressed()

func _on_pressed():
	if not is_on_cooldown:
		emit_signal("pressed")

func _process(delta):
	if is_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			is_on_cooldown = false
			cooldown_timer = 0
			_update_visuals()

func start_cooldown():
	if not is_on_cooldown:
		is_on_cooldown = true
		cooldown_timer = cooldown_time
		_update_visuals()

func _update_visuals():
	if is_on_cooldown:
		bg_rect.color = Color(0.5, 0.5, 0.5, 0.5)
		text_label.text = str(int(cooldown_timer))
	else:
		bg_rect.color = Color(1, 0.3, 0.3, 0.6)
		text_label.text = "💣"
