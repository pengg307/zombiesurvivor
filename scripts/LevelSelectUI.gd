extends Control
class_name LevelSelectUI

var level_manager = null
var ui_manager = null

signal level_selected(level: int)
signal back_to_game

func _ready():
	visible = false
	_setup_ui()

func _setup_ui():
	# 背景
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.1, 0.1, 0.15, 0.95)
	bg.position = Vector2(0, 0)
	bg.size = Vector2(720, 1280)
	add_child(bg)
	
	# 标题
	var title = Label.new()
	title.name = "Title"
	title.text = "🎮 选择关卡"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 50)
	title.size = Vector2(720, 60)
	title.add_theme_font_size_override("font_size", 36)
	title.modulate = Color(1, 0.8, 0.2)
	add_child(title)
	
	# 关卡按钮容器
	var container = VBoxContainer.new()
	container.name = "LevelContainer"
	container.position = Vector2(100, 150)
	container.size = Vector2(520, 800)
	add_child(container)
	
	# 动态生成关卡按钮
	_generate_level_buttons(container)
	
	# 返回按钮
	var back_btn = Button.new()
	back_btn.name = "BackButton"
	back_btn.text = "← 返回游戏"
	back_btn.position = Vector2(260, 1000)
	back_btn.size = Vector2(200, 50)
	back_btn.modulate = Color(0.8, 0.8, 0.8)
	back_btn.add_theme_font_size_override("font_size", 20)
	back_btn.pressed.connect(_on_back_pressed)
	add_child(back_btn)
	
	# 难度说明
	var hint = Label.new()
	hint.name = "Hint"
	hint.text = "💡 完成当前关卡后解锁下一关"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, 1080)
	hint.size = Vector2(720, 30)
	hint.add_theme_font_size_override("font_size", 16)
	hint.modulate = Color(0.6, 0.6, 0.6)
	add_child(hint)

func _generate_level_buttons(container: VBoxContainer):
	var lm = get_tree().get_first_node_in_group("level_manager")
	if not lm:
		print("❌ 未找到 LevelManager")
		return
	
	level_manager = lm
	
	var levels = lm.get_level_names()
	
	for level_data in levels:
		var btn = _create_level_button(level_data)
		container.add_child(btn)

func _create_level_button(level_data: Dictionary) -> Button:
	var btn = Button.new()
	btn.name = "Level" + str(level_data["level"])
	btn.size_flags_horizontal = Control.SIZE_FILL
	btn.size = Vector2(520, 70)
	
	var level = level_data["level"]
	var name = level_data["name"]
	var unlocked = level_data["unlocked"]
	
	var config = get_tree().get_first_node_in_group("level_manager").get_current_config() if level == 1 else null
	
	btn.text = "🏰 第" + str(level) + "关: " + name + ("" if unlocked else " 🔒")
	
	if unlocked:
		btn.modulate = Color(1, 1, 1)
		btn.pressed.connect(func(): _on_level_selected(level))
	else:
		btn.modulate = Color(0.4, 0.4, 0.4)
		btn.disabled = true
	
	return btn

func _on_level_selected(level: int):
	print("🎯 选择关卡: " + str(level))
	level_manager.start_level(level)
	emit_signal("level_selected", level)
	visible = false

func _on_back_pressed():
	print("↩️ 返回游戏")
	emit_signal("back_to_game")
	visible = false

func show():
	visible = true

func hide_panel():
	visible = false