extends Control
class_name TutorialOverlay

var tutorial_step = 0
var tutorial_active = true

const TUTORIAL_STEPS = [
	{"tip": "🎮 虚拟摇杆控制移动", "x": 150, "y": 1000},
	{"tip": "🔫 自动射击，瞄准最近敌人", "x": 580, "y": 100},
	{"tip": "💣 点击手雷按钮使用炸弹", "x": 580, "y": 1100},
	{"tip": "⬆️ 每10击杀获得强化", "x": 100, "y": 100},
	{"tip": "💀 击杀Boss即可获胜", "x": 360, "y": 640}
]

func _ready():
	hide()

func start_tutorial():
	if not _has_seen_tutorial():
		tutorial_active = true
		tutorial_step = 0
		_show_step()
		print("📚 启动新手引导")
	else:
		print("📚 教程已看过，跳过")

func _show_step():
	hide_all_highlights()
	
	if tutorial_step >= TUTORIAL_STEPS.size():
		_end_tutorial()
		return
	
	var step = TUTORIAL_STEPS[tutorial_step]
	_show_highlight(step)

func _show_highlight(step):
	# 创建提示气泡
	var bubble = ColorRect.new()
	bubble.name = "HighlightBubble"
	bubble.color = Color(0, 0, 0, 0.7)
	bubble.position = Vector2(step.x - 100, step.y - 30)
	bubble.size = Vector2(200, 60)
	bubble.z_index = 100
	add_child(bubble)
	
	# 创建提示文字
	var label = Label.new()
	label.name = "HighlightText"
	label.text = step["tip"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.modulate = Color(1, 1, 1)
	label.position = Vector2(step.x - 100, step.y - 30)
	label.size = Vector2(200, 60)
	label.z_index = 101
	add_child(label)
	
	# 3秒后自动下一步
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(_on_timer_timeout.bind(bubble, label))
	
	# 点击跳过
	var skip = Button.new()
	skip.name = "SkipButton"
	skip.text = "跳过"
	skip.position = Vector2(get_viewport().get_visible_rect().size.x - 100, 10)
	skip.z_index = 102
	skip.pressed.connect(_on_skip)
	add_child(skip)

func _on_timer_timeout(bubble, label):
	bubble.queue_free()
	label.queue_free()
	tutorial_step += 1
	_show_step()

func _on_skip():
	_end_tutorial()

func _end_tutorial():
	hide_all_highlights()
	_save_tutorial_seen()
	print("📚 新手引导完成")
	visible = false

func hide_all_highlights():
	for child in get_children():
		if child.name in ["HighlightBubble", "HighlightText", "SkipButton"]:
			child.queue_free()

func _has_seen_tutorial() -> bool:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK and config.get_value("tutorial", "seen", false):
		return true
	return false

func _save_tutorial_seen():
	var config = ConfigFile.new()
	config.set_value("tutorial", "seen", true)
	config.save("user://settings.cfg")
	print("💾 教程标记为已看过")

func show_next_step():
	if tutorial_active:
		_show_step()
