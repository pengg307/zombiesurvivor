extends CanvasLayer
class_name UIManager

var player = null
var spawner = null
var audio_manager = null
var stats_manager = null
var settings_manager = null
var tutorial_manager = null
var game_ended = false

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
	_create_health_alert_panel()
	_add_triple_shot_display()
	_add_grenade_display()
	_add_bottom_status_bar()
	_add_mobile_controls()
	_add_settings_button()
	_add_stats_button()
	
	game_ended = false
	
	print("")
	print("✅ UIManager初始化完成")
	print("============================================================")

func _setup_audio():
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am
		print("🎵 音频管理器已连接")

func _setup_stats():
	var sm = get_tree().get_first_node_in_group("stats_manager")
	if sm:
		stats_manager = sm
		print("📊 统计管理器已连接")

func _setup_settings():
	var sm = get_tree().get_first_node_in_group("settings_manager")
	if sm:
		settings_manager = sm
		print("⚙️ 设置管理器已连接")

func _setup_tutorial():
	var tm = get_tree().get_first_node_in_group("tutorial_overlay")
	if tm:
		tutorial_manager = tm
		print("📚 教程管理器已连接")

func set_player(player_node):
	player = player_node
	print("✅ Player引用已设置")

func set_spawner(spawner_node):
	spawner = spawner_node
	print("✅ Spawner引用已设置")

func _connect_buttons():
	# 连接开始按钮
	if has_node("StartPanel/PanelContainer/VBoxContainer/StartButton"):
		var start_btn = $StartPanel/PanelContainer/VBoxContainer/StartButton
		start_btn.pressed.connect(_on_start_game)
		print("  ✅ StartButton 已连接")
	
	# 连接重新开始按钮
	if has_node("GameOverPanel/PanelContainer/VBoxContainer/RestartButton"):
		var restart_btn = $GameOverPanel/PanelContainer/VBoxContainer/RestartButton
		restart_btn.pressed.connect(_on_restart_game)
		print("  ✅ GameOver RestartButton 已连接")
	
	if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
		var restart_btn = $WinPanel/PanelContainer/VBoxContainer/RestartButton
		restart_btn.pressed.connect(_on_restart_game)
		print("  ✅ Win RestartButton 已连接")

func _on_start_game():
	if game_ended:
		return
	
	print("")
	print("========================================")
	print("🎮 [DEBUG] 游戏开始！")
	print("========================================")
	
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
	
	if has_node("Panel/TopPanel"):
		$Panel/TopPanel.visible = true
	
	# 隐藏结束面板
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
	if has_node("WinPanel"):
		$WinPanel.visible = false
	
	# 启动教程
	if tutorial_manager:
		tutorial_manager.start_tutorial()
	
	print("🎮 游戏开始！")

func show_game_over(kills):
	if game_ended:
		return
	game_ended = true
	
	print("💀 [GAME_OVER] 游戏结束")
	
	if audio_manager:
		audio_manager.play_gameover()
	
	if stats_manager:
		stats_manager.end_game(false)
	
	# 隐藏其他面板
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
	
	print("🏆 [WIN] 游戏胜利！")
	
	if audio_manager:
		audio_manager.play_victory()
	
	if stats_manager:
		stats_manager.end_game(true)
	
	# 隐藏其他面板
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
	
	if has_node("WinPanel"):
		$WinPanel.visible = true
		$WinPanel/PanelContainer/VBoxContainer/WinLabel.text = "🏆 WON 🏆"
		$WinPanel/PanelContainer/VBoxContainer/WinLabel.modulate = Color(0.2, 1, 0.2)
		$WinPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: " + str(kills)

func _on_restart_game():
	print("🔄 重新开始游戏")
	
	if audio_manager:
		audio_manager.stop_bgm()
	
	get_tree().reload_current_scene()

func show_upgrade_panel():
	if game_ended:
		return
	print("🎁 [升级] 显示升级面板")
	
	if audio_manager:
		audio_manager.play_levelup()
	
	if has_node("UpgradePanel"):
		$UpgradePanel.visible = true
		get_tree().paused = true
		_generate_upgrade_options()

func _generate_upgrade_options():
	var upgrade_sys = get_node_or_null("/root/UpgradeSystem")
	if not upgrade_sys:
		upgrade_sys = preload("res://scripts/UpgradeSystem.gd").new()
		add_child(upgrade_sys)
	
	var options = upgrade_sys.get_random_options(3)
	_show_upgrade_options(options)

func _show_upgrade_options(options):
	for child in $UpgradePanel/PanelContainer/VBoxContainer/OptionsContainer.get_children():
		child.queue_free()
	
	for option_key in options:
		var btn = Button.new()
		btn.text = get_upgrade_name(option_key)
		btn.pressed.connect(_on_upgrade_selected.bind(option_key))
		$UpgradePanel/PanelContainer/VBoxContainer/OptionsContainer.add_child(btn)

func get_upgrade_name(key):
	var upgrade_sys = get_node_or_null("/root/UpgradeSystem")
	if upgrade_sys and key in upgrade_sys.UPGRADE_OPTIONS:
		return upgrade_sys.UPGRADE_OPTIONS[key].name
	return key

func _on_upgrade_selected(option_key):
	print("🎯 [强化选择] " + get_upgrade_name(option_key))
	var upgrade_sys = get_node_or_null("/root/UpgradeSystem")
	if upgrade_sys and player:
		upgrade_sys.apply_upgrade(player, option_key)
	hide_upgrade_panel()

func hide_upgrade_panel():
	if has_node("UpgradePanel"):
		$UpgradePanel.visible = false
	get_tree().paused = false

func _add_bottom_status_bar():
	var container = VBoxContainer.new()
	container.name = "BottomStatusBar"
	container.position = Vector2(0, 1240)
	container.size = Vector2(720, 40)
	add_child(container)
	
	var status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "⚔️10.0 💨0.30s 🚀600"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.modulate = Color(1, 1, 0.8)
	container.add_child(status_label)

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

func _create_health_alert_panel():
	var panel = Panel.new()
	panel.name = "HealthAlertPanel"
	panel.visible = true
	panel.layout_mode = 1
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = -150.0
	panel.modulate = Color(1, 1, 1, 0.9)
	add_child(panel)
	
	var container = VBoxContainer.new()
	container.name = "HealthAlertContainer"
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.custom_minimum_size = Vector2(0, 120)
	panel.add_child(container)
	
	var label = Label.new()
	label.name = "HealthAlertLabel"
	label.text = "❤️ 玩家健康"
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(1, 0.3, 0.3)
	container.add_child(label)
	
	var bar_container = HBoxContainer.new()
	bar_container.name = "HealthBarContainer"
	bar_container.custom_minimum_size = Vector2(0, 60)
	bar_container.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(bar_container)
	
	var text_label = Label.new()
	text_label.name = "HealthTextLabel"
	text_label.text = "HP: 100/100"
	text_label.add_theme_font_size_override("font_size", 24)
	text_label.modulate = Color(1, 1, 1)
	bar_container.add_child(text_label)
	
	var bar = ProgressBar.new()
	bar.name = "HealthBar"
	bar.value = 100.0
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.size_flags_horizontal = Control.SIZE_FILL
	bar.add_theme_constant_override("separation", 10)
	bar.modulate = Color(0, 1, 0)
	bar_container.add_child(bar)
	
	print("✅ 健康警报面板已创建")

func _show_health_alert():
	if not has_node("HealthAlertPanel"):
		return
	if game_ended:
		return
	var panel = $HealthAlertPanel
	panel.visible = true
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.1)
	tween.tween_property(panel, "modulate:a", 0.3, 0.1)
	tween.tween_property(panel, "modulate:a", 1.0, 0.1)
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		if has_node("HealthAlertPanel") and not game_ended:
			_update_health()
	)

func _update_health():
	if not player or game_ended:
		return
	if has_node("HealthAlertPanel/HealthAlertContainer"):
		var panel = $HealthAlertPanel
		var text_label = panel.get_node("HealthAlertContainer/HealthBarContainer/HealthTextLabel")
		var bar = panel.get_node("HealthAlertContainer/HealthBarContainer/HealthBar")
		if text_label and bar:
			text_label.text = "HP: %d/%d" % [player.current_health, player.MAX_HEALTH]
			bar.value = player.current_health
			bar.max_value = player.MAX_HEALTH
			var pct = float(player.current_health) / float(player.MAX_HEALTH)
			if pct > 0.6:
				bar.modulate = Color(0, 1, 0)
			elif pct > 0.3:
				bar.modulate = Color(1, 1, 0)
			else:
				bar.modulate = Color(1, 0, 0)

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
	
	print("✅ 移动端控制已添加")

func _on_joystick_moved(direction: Vector2):
	if player and not game_ended:
		player.move_direction = direction

func _on_grenade_pressed():
	if player and not game_ended and player.grenades > 0:
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
	print("⚙️ 打开设置菜单")
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
	print("📊 打开统计面板")
	if stats_manager:
		var panel = get_node_or_null("StatsPanel")
		if panel:
			panel.show_panel()
		else:
			var stats_panel = load("res://scripts/StatsPanel.gd").new()
			stats_panel.name = "StatsPanel"
			add_child(stats_panel)
			stats_panel.show_panel()
