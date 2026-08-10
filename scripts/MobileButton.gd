extends Control
class_name MobileButton

signal pressed

@export var button_text: String = "🔥"
@export var button_color: Color = Color(1, 0.3, 0.3, 0.6)
@export var button_size: Vector2 = Vector2(80, 80)
@export var cooldown_time: float = 1.0

var is_pressed = false
var cooldown_timer = 0.0
var is_on_cooldown = false

var bg_rect: ColorRect = null
var text_label: Label = null

func _ready():
	_setup_visuals()
	size = button_size
	position = Vector2(580, 1100)

func _setup_visuals():
	bg_rect = ColorRect.new()
	bg_rect.name = "Background"
	bg_rect.color = button_color
	bg_rect.size = button_size
	bg_rect.position = Vector2(0, 0)
	add_child(bg_rect)
	
	var border = ColorRect.new()
	border.name = "Border"
	border.color = Color(1, 1, 1, 0.5)
	border.size = button_size - Vector2(4, 4)
	border.position = Vector2(2, 2)
	add_child(border)
	
	text_label = Label.new()
	text_label.name = "Text"
	text_label.text = button_text
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.add_theme_font_size_override("font_size", 32)
	text_label.size = button_size
	text_label.position = Vector2(0, 0)
	add_child(text_label)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and get_global_rect().has_point(event.global_position):
			is_pressed = true
			_on_pressed()
		elif not event.pressed and is_pressed:
			is_pressed = false
			_on_released()
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_global_rect().has_point(event.position):
				is_pressed = true
				_on_pressed()
			elif not event.pressed and is_pressed:
				is_pressed = false
				_on_released()

func _on_pressed():
	if not is_on_cooldown:
		emit_signal("pressed")

func _on_released():
	emit_signal("released")

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
		bg_rect.color = button_color.lerp(Color(0.5, 0.5, 0.5, 0.5), 0.5)
		text_label.text = str(int(cooldown_timer))
	else:
		bg_rect.color = button_color
		text_label.text = button_text
