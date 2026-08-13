extends CanvasLayer
class_name UIManager

var player = null
var spawner = null
var audio_manager = null
var stats_manager = null
var settings_manager = null
var tutorial_manager = null
var game_ended = false
var game_started = false
var level_manager = null

# 底部健康条节点
var health_bar_fg = null
var health_label = null

# 关卡信息
var current_level_label = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("")
	print("============================================================")
	print("🎮 UIManager启动！")
	print("============================================================")
	
	_setup_audio()
	_setup_stats()
	_setup_settings()
	_setup_tutorial()
	_connect_buttons()
	_create_bottom_health_bar()
	_add_triple_shot_display()
	_add_grenade_display()
	_add_mobile_controls()
	_add_settings_button()
	_add_stats_button()
	_add_level_button()
	_setup_level_display()
	
	game_ended = false
	game_started = false
	
	print("")
	print("✅ UIManager初始化完成")
	print("============================================================")
	
	# Headless 模式下自动开始游戏（用于测试）
	if DisplayServer.get_name() == "headless":
		call_deferred("_on_start_game")

func _process(delta):
	# 每帧更新健康条
	if player and not game_ended and game_started:
		_update_health()

func _unhandled_input(event):
	# 支持用 空格 / 回车 触发 开始/重新开始 按钮
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if has_node("StartPanel") and $StartPanel.visible:
				get_viewport().set_input_as_handled()
				_on_start_game()
			elif has_node("GameOverPanel") and $GameOverPanel.visible:
				get_viewport().set_input_as_handled()
				_on_restart_game()
			elif has_node("WinPanel") and $WinPanel.visible:
				get_viewport().set_input_as_handled()
				_on_next_level_prompt()

func _setup_audio():
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am

func _setup_stats():
	var sm = get_tree().get_first_node_in_group("stats_manager")
	if sm:
		stats_manager = sm

func _setup_settings():
	var sm = get_tree().get_first_node_in_group("settings_manager")
	if sm:
		settings_manager = sm

func _setup_tutorial():
	var tm = get_tree().get_first_node_in_group("tutorial_overlay")
	if tm:
		tutorial_manager = tm

func set_player(player_node):
	player = player_node
	print("✅ Player引用已设置")

func set_spawner(spawner_node):
	spawner = spawner_node
	print("✅ Spawner引用已设置")

func _connect_buttons():
	if has_node("StartPanel/PanelContainer/VBoxContainer/StartButton"):
		var start_btn = $StartPanel/PanelContainer/VBoxContainer/StartButton
		start_btn.pressed.connect(_on_start_game)
		print("  ✅ StartButton 已连接")
	
	if has_node("GameOverPanel/PanelContainer/VBoxContainer/RestartButton"):
		var restart_btn = $GameOverPanel/PanelContainer/VBoxContainer/RestartButton
		restart_btn.pressed.connect(_on_restart_game)
		print("  ✅ GameOver RestartButton 已连接")
	
	if has_node("WinPanel/PanelContainer/VBoxContainer/NextLevelButton"):
		var next_btn = $WinPanel/PanelContainer/VBoxContainer/NextLevelButton
		next_btn.pressed.connect(_on_next_level_pressed)
		print("  ✅ Win NextLevelButton 已连接")
	
	if has_node("WinPanel/PanelContainer/VBoxContainer/MenuButton"):
		var menu_btn = $WinPanel/PanelContainer/VBoxContainer/MenuButton
		menu_btn.pressed.connect(_on_menu_pressed)
		print("  ✅ Win MenuButton 已连接")

func _on_start_game():
	if game_started or game_ended:
		return
	
	print("")
	print("========================================")
	print("🎮 游戏开始！")
	print("========================================")
	
	game_started = true
	game_ended = false
	
	if audio_manager:
		audio_manager.play_levelup()
	
	if stats_manager:
		stats_manager.start_game()
	
	if spawner:
		spawner.start()
	
	if has_node("Panel"):
		$Panel.modulate = Color(1, 1, 1, 1)
	
	if has_node("StartPanel"):
		$StartPanel.visible = false
		print("  ✅ StartPanel 已隐藏")
	
	if has_node("Panel/TopPanel"):
		$Panel/TopPanel.visible = true
		print("  ✅ TopPanel 已显示")
	
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
	if has_node("WinPanel"):
		$WinPanel.visible = false
	
	if tutorial_manager:
		tutorial_manager.start_tutorial()
	
	print("🎮 游戏开始！")

func show_game_over(kills):
	if game_ended:
		return
	game_ended = true
	game_started = false
	
	print("💀 [GAME_OVER] 游戏结束")
	
	if audio_manager:
		audio_manager.play_gameover()
	
	if stats_manager:
		stats_manager.end_game(false)
	
	if has_node("WinPanel"):
		$WinPanel.visible = false
	
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = true
		$GameOverPanel/PanelContainer/VBoxContainer/GameOverLabel.text = "💀 LOST 💀"
		$GameOverPanel/PanelContainer/VBoxContainer/GameOverLabel.modulate = Color(1, 0.2, 0.2)
		$GameOverPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: " + str(kills)

func show_win(kills):
	if game_ended:
		return
	game_ended = true
	game_started = false
	
	print("🏆 [WIN] 游戏胜利！")
	print("  WinPanel.visible = true (将显示)")
	
	if audio_manager:
		audio_manager.play_victory()
	
	if stats_manager:
		stats_manager.end_game(true)
	
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
	
	if has_node("WinPanel"):
		$WinPanel.visible = true
		$WinPanel/PanelContainer/VBoxContainer/WinLabel.text = "🏆 WON 🏆"
		$WinPanel/PanelContainer/VBoxContainer/WinLabel.modulate = Color(0.2, 1, 0.2)
		$WinPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: " + str(kills)
		$WinPanel/PanelContainer/VBoxContainer/LevelLabel.text = "Level " + str(spawner.current_level if spawner else 1)
		print("  ✅ WinPanel 已显示，关卡: " + str(spawner.current_level if spawner else 1))

func _on_restart_game():
	print("🔄 重新开始游戏")
	
	if audio_manager:
		audio_manager.stop_bgm()
	
	get_tree().reload_current_scene()

func _on_next_level_prompt():
	# 空格键显示下一关提示
	if has_node("WinPanel") and $WinPanel.visible:
		print("🎯 按空格键继续到下一关")

func _on_next_level_pressed():
	print("🚀 进入下一关！")
	if spawner:
		var lm = get_tree().get_first_node_in_group("level_manager")
		if lm and lm.has_next_level():
			lm.start_level(lm.get_next_level())
			_on_restart_game()

func _on_menu_pressed():
	print("📋 返回主菜单")
	# TODO: 显示关卡选择界面
	if has_node("LevelSelectUI"):
		$LevelSelectUI.show()

func _add_level_button():
	var btn = Button.new()
	btn.name = "LevelButton"
	btn.text = "🎮 关卡"
	btn.size = Vector2(80, 40)
	btn.position = Vector2(620, 10)
	btn.z_index = 50
	btn.modulate = Color(1, 1, 1, 0.8)
	btn.add_theme_font_size_override("font_size", 16)
	btn.pressed.connect(_on_menu_pressed)
	add_child(btn)
	print("  ✅ LevelButton 已添加")

func _setup_level_display():
	level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		print("📊 当前关卡: " + str(level_manager.current_level))

func _create_bottom_health_bar():
	# 底部健康条容器 - 长条形，占据整个屏幕宽度
	var container = Panel.new()
	container.name = "BottomHealthBar"
	container.position = Vector2(0, 1220)  # 底部，留20px边距
	container.size = Vector2(720, 60)
	container.modulate = Color(0.1, 0.1, 0.1, 0.9)
	add_child(container)
	
	# 健康条背景
	var bg = ColorRect.new()
	bg.name = "HealthBarBg"
	bg.size = Vector2(700, 40)
	bg.position = Vector2(10, 10)
	bg.color = Color(0.3, 0.1, 0.1)
	container.add_child(bg)
	
	# 健康条前景
	var fg = ColorRect.new()
	fg.name = "HealthBarFg"
	fg.size = Vector2(700, 40)
	fg.position = Vector2(10, 10)
	fg.color = Color(0, 0.8, 0)
	container.add_child(fg)
	health_bar_fg = fg
	
	# 健康文字 - 大字体，居中显示
	var label = Label.new()
	label.name = "HealthLabel"
	label.text = "HP: 100/100"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.position = Vector2(0, 0)
	label.size = Vector2(720, 60)
	container.add_child(label)
	health_label = label
	
	print("✅ 底部健康条已创建 (720x60, 位置: 0,1220)")

func _update_health():
	if not player or game_ended:
		return
	
	if has_node("BottomHealthBar"):
		var container = $BottomHealthBar
		var fg = container.get_node("HealthBarFg")
		var label = container.get_node("HealthLabel")
		
		if fg and label:
			var max_hp = player.MAX_HEALTH
			var current_hp = player.current_health
			var pct = current_hp / max_hp
			
			# 更新宽度
			fg.size.x = 700 * pct
			fg.position.x = 10 + (700 * (1 - pct))
			
			# 更新文字
			label.text = "HP: %d/%d" % [int(current_hp), int(max_hp)]
			
			# 更新颜色
			if pct > 0.6:
				fg.color = Color(0, 0.8, 0)
			elif pct > 0.3:
				fg.color = Color(1, 0.8, 0)
			else:
				fg.color = Color(1, 0.2, 0.2)

func _add_triple_shot_display():
	var triple_label = Label.new()
	triple_label.name = "TripleShotDisplay"
	triple_label.text = "🔫 三发子弹: 未解锁"
	triple_label.position = Vector2(600, 10)
	triple_label.modulate = Color(1, 1, 1)
	triple_label.add_theme_font_size_override("font_size", 18)
	add_child(triple_label)

func _add_grenade_display():
	var grenade_label = Label.new()
	grenade_label.name = "GrenadeDisplay"
	grenade_label.text = "💣 手雷: 0"
	grenade_label.position = Vector2(600, 35)
	grenade_label.modulate = Color(1, 0.5, 0.3)
	grenade_label.add_theme_font_size_override("font_size", 18)
	add_child(grenade_label)

func _add_mobile_controls():
	var joystick = load("res://scripts/JoystickControl.gd").new()
	joystick.name = "Joystick"
	joystick.set_position(Vector2(100, 1000))
	add_child(joystick)
	joystick.moved.connect(_on_joystick_moved)
	
	var grenade_btn = load("res://scripts/MobileButton.gd").new()
	grenade_btn.name = "GrenadeButton"
	grenade_btn.set_position(Vector2(580, 1100))
	grenade_btn.button_text = "💣"
	grenade_btn.cooldown_time = 2.0
	add_child(grenade_btn)
	grenade_btn.pressed.connect(_on_grenade_pressed)

func _on_joystick_moved(direction: Vector2):
	if player and not game_ended and game_started:
		player.move_direction = direction

func _on_grenade_pressed():
	if player and not game_ended and game_started and player.grenades > 0:
		player._throw_grenade()

func _add_settings_button():
	var btn = Button.new()
	btn.name = "SettingsButton"
	btn.text = "⚙️"
	btn.size = Vector2(50, 50)
	btn.position = Vector2(660, 570)
	btn.z_index = 50
	btn.modulate = Color(1, 1, 1, 0.7)
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(_on_settings_pressed)
	add_child(btn)

func _on_settings_pressed():
	if settings_manager:
		settings_manager._save_settings()

func _add_stats_button():
	var btn = Button.new()
	btn.name = "StatsButton"
	btn.text = "📊"
	btn.size = Vector2(50, 50)
	btn.position = Vector2(660, 520)
	btn.z_index = 50
	btn.modulate = Color(1, 1, 1, 0.7)
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(_on_stats_pressed)
	add_child(btn)

func _on_stats_pressed():
	if stats_manager:
		var panel = get_node_or_null("StatsPanel")
		if panel:
			panel.show_panel()
		else:
			var stats_panel = load("res://scripts/StatsPanel.gd").new()
			stats_panel.name = "StatsPanel"
			add_child(stats_panel)
			stats_panel.show_panel()