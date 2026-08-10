extends CanvasLayer
class_name UIManager

var player = null
var spawner = null
var audio_manager = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 連接音頻管理器
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am
	
	# 初始化面板可見性
	if has_node("StartPanel"):
		$StartPanel.visible = true
	if has_node("UpgradePanel"):
		$UpgradePanel.visible = false
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
	if has_node("WinPanel"):
		$WinPanel.visible = false
	if has_node("BossPanel"):
		$BossPanel.visible = false
	
	# 連接按鈕
	_connect_buttons()
	
	# 添加底部狀態欄
	_add_bottom_status_bar()
	
	# 添加三發子彈狀態顯示
	_add_triple_shot_display()
	
	# 添加手雷顯示
	_add_grenade_display()
	
	# 動態創建健康警報面板
	_create_health_alert_panel()
	
	print("✅ UIManager初始化完成")

func _process(_delta):
	if player:
		_update_health()
		_update_level()
		_update_kills()
		_update_triple_shot()
		_update_grenades()
		_update_bottom_status()
		_update_boss_progress()

func _input(event):
	# 调试：捕获所有鼠标点击（包括暂停时）
	if event is InputEventMouseButton and event.pressed:
		print("🖱️ [INPUT] 鼠标点击: button_index=" + str(event.button_index) + " pos=" + str(event.position))
		print("  - 暂停状态: " + str(get_tree().paused))
		if has_node("WinPanel") and $WinPanel.visible:
			print("  - WinPanel 可见，检查按钮...")
			if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
				var btn = $WinPanel/PanelContainer/VBoxContainer/RestartButton
				print("  - 按钮位置: " + str(btn.position) + " 大小: " + str(btn.size))
				print("  - 按钮区域: " + str(btn.get_global_rect()))
				# 检查点击是否在按钮区域内
				var global_pos = btn.get_global_rect().get_center()
				print("  - 按钮中心: " + str(global_pos))

func set_player(player_node):
	player = player_node
	print("✅ Player引用已设置")
	# 连接受伤信号
	if player.has_signal("player_damaged"):
		player.player_damaged.connect(_on_player_damaged)
		print("✅ 已连接 player_damaged 信号")

func _on_player_damaged():
	# 显示健康警报
	_show_health_alert()

func _show_health_alert():
	# 顯示健康警報
	if not has_node("HealthAlertPanel"):
		return
	var panel = $HealthAlertPanel
	# 確保面板可見
	panel.visible = true
	# 閃爍效果
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.1)
	tween.tween_property(panel, "modulate:a", 0.3, 0.1)
	tween.tween_property(panel, "modulate:a", 1.0, 0.1)
	# 恢復正常顏色
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		if has_node("HealthAlertPanel"):
			_update_health()
	)

func set_spawner(spawner_node):
	spawner = spawner_node
	print("✅ Spawner引用已设置")

func _connect_buttons():
	print("🔗 连接按钮信号...")
	print("  - 当前节点路径: " + str(get_path()))
	
	# 检查 StartPanel
	if has_node("StartPanel"):
		print("  - 找到 StartPanel")
		if has_node("StartPanel/PanelContainer/VBoxContainer/StartButton"):
			var start_btn = $StartPanel/PanelContainer/VBoxContainer/StartButton
			print("  - 按钮可见: " + str(start_btn.visible))
			print("  - 按钮位置: " + str(start_btn.position))
			print("  - 按钮大小: " + str(start_btn.size))
			start_btn.pressed.connect(_on_start_game)
			print("  ✅ StartButton 已连接")
		else:
			print("  ❌ 未找到 StartButton")
			# 尝试查找任何按钮
			var buttons = get_tree().get_nodes_in_group("")
			print("  - 尝试查找所有按钮...")
	else:
		print("  ❌ 未找到 StartPanel")
	
	# 检查 GameOverPanel
	if has_node("GameOverPanel"):
		print("  - 找到 GameOverPanel")
		if has_node("GameOverPanel/PanelContainer/VBoxContainer/RestartButton"):
			$GameOverPanel/PanelContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_game)
			print("  ✅ GameOverPanel RestartButton 已连接")
		else:
			print("  ❌ 未找到 GameOverPanel/RestartButton")
	else:
		print("  ❌ 未找到 GameOverPanel")
	
	# 检查 WinPanel
	if has_node("WinPanel"):
		print("  - 找到 WinPanel")
		if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
			var restart_btn = $WinPanel/PanelContainer/VBoxContainer/RestartButton
			restart_btn.pressed.connect(_on_restart_game)
			# 额外调试
			restart_btn.gui_input.connect(func(event): 
				if event is InputEventMouseButton and event.pressed:
					print(">>> GUI_INPUT: " + str(event))
			)
			print("  ✅ WinPanel RestartButton 已连接")
			print("  - 按钮可见: " + str(restart_btn.visible))
			print("  - 按钮位置: " + str(restart_btn.position))
			print("  - 按钮大小: " + str(restart_btn.size))
		else:
			print("  ❌ 未找到 WinPanel/RestartButton")
			print("  - WinPanel 子节点:")
			for child in get_node("WinPanel").get_children():
				print("    - " + child.name + " (" + child.get_class() + ")")
		print("  - WinPanel.visible = " + str($WinPanel.visible))
	else:
		print("  ❌ 未找到 WinPanel")
	
	_add_upgrade_buttons()

func _update_health():
	if not player:
		return
	# 更新底部警报面板
	if has_node("HealthAlertPanel"):
		var panel = $HealthAlertPanel
		var health_pct = float(player.current_health) / float(player.MAX_HEALTH) * 100
		# 更新健康条
		if has_node("HealthAlertPanel/HealthAlertContainer/HealthBarContainer/HealthBar"):
			$HealthAlertPanel/HealthAlertContainer/HealthBarContainer/HealthBar.value = player.current_health
		# 更新文字
		if has_node("HealthAlertPanel/HealthAlertContainer/HealthBarContainer/HealthTextLabel"):
			$HealthAlertPanel/HealthAlertContainer/HealthBarContainer/HealthTextLabel.text = "HP: %d/%d" % [player.current_health, player.MAX_HEALTH]
		# 根据血量改变颜色
		var bar
		if has_node("HealthAlertPanel/HealthAlertContainer/HealthBarContainer/HealthBar"):
			bar = $HealthAlertPanel/HealthAlertContainer/HealthBarContainer/HealthBar
		if bar:
			if health_pct > 60:
				bar.modulate = Color(0, 1, 0)  # 绿色
			elif health_pct > 30:
				bar.modulate = Color(1, 1, 0)  # 黄色
			else:
				bar.modulate = Color(1, 0, 0)  # 红色

func _update_level():
	if player and has_node("Panel/LevelLabel"):
		$Panel/LevelLabel.text = "Lv.%d" % player.level

func _update_kills():
	if spawner and has_node("Panel/KillLabel"):
		$Panel/KillLabel.text = "Kills: %d" % spawner.current_kills
		$Panel/ScoreLabel.text = "Score: %d" % spawner.current_kills

func _update_triple_shot():
	if player and has_node("TripleShotDisplay"):
		var text = "🔫 三发子弹: " + ("已解锁" if player.triple_shot_unlocked else "未解锁 (%d/5)" % player.kills)
		$TripleShotDisplay.text = text
		$TripleShotDisplay.modulate = Color(1, 1, 0.5) if player.triple_shot_unlocked else Color(1, 1, 1)

func _update_grenades():
	if player and has_node("GrenadeDisplay"):
		$GrenadeDisplay.text = "💣 手雷: %d" % player.grenades

func _update_bottom_status():
	# 底部状态栏实时更新
	if has_node("BottomStatusBar"):
		var status_text = ""
		
		# 伤害
		if player:
			status_text += "⚔️%.1f " % player.damage_per_shot
		
		# 射速
		if player:
			status_text += "💨%.2fs " % player.fire_rate
		
		# 子弹速度
		if player:
			status_text += "🚀%d " % player.bullet_speed
		
		# 增益状态
		if player and player.ammo_boost_timer > 0:
			status_text += "🛢️%ds" % int(player.ammo_boost_timer)
		
		$BottomStatusBar/StatusLabel.text = status_text

func _update_boss_progress():
	if spawner and has_node("BossProgress"):
		var boss_required = spawner.BOSS_KILLS_REQUIRED
		var boss_current = spawner.current_kills
		$BossProgress.text = "👹 Boss进度: %d/%d" % [boss_current, boss_required]

func _on_start_game():
	print("")
	print("========================================")
	print("🎮 [DEBUG] _on_start_game 被调用！")
	print("========================================")
	print("  - 调用时间: " + str(Time.get_ticks_msec()))
	print("  - 暂停状态: " + str(get_tree().paused))
	print("  - 场景路径: " + str(get_path()))

	if has_node("StartPanel"):
		print("  - StartPanel 存在")
		$StartPanel.visible = false
		print("  - StartPanel 已隐藏")
	else:
		print("❌ [DEBUG] StartPanel 不存在！")
		return

	if has_node("Panel"):
		$Panel.modulate = Color(1, 1, 1, 1)  # 恢复不透明
		print("  - Panel 已显示")

	if has_node("Panel/TopPanel"):
		$Panel/TopPanel.visible = true  # 显示健康条
		print("  - TopPanel 已显示")

	print("🎮 游戏开始！")
	# 通知 GameManager 开始游戏
	var gm = get_tree().get_first_node_in_group("game_manager")
	print("  - GameManager: " + str(gm))
	if gm:
		print("  - 调用 gm._start_game()")
		gm._start_game()
		print("✅ [DEBUG] gm._start_game() 已调用")
	else:
		print("❌ [DEBUG] 未找到 GameManager！")
		print("  - 尝试通过路径获取...")
		var root = get_tree().get_root()
		var game_node = root.get_node_or_null("Game")
		print("  - Game 节点: " + str(game_node))
		if game_node:
			var gm2 = game_node.get_node_or_null("GameManager")
			print("  - GameManager via path: " + str(gm2))

func _on_restart_game():
	print("🔄 [RESTART] 重新开始游戏被点击!")
	print("  - 当前时间: " + str(Time.get_ticks_msec()))
	print("  - 暂停状态: " + str(get_tree().paused))
	print("  - 场景路径: " + str(get_path()))
	print("  - UIManager节点: " + str(self))
	print("  - WinPanel节点: " + str(get_node("WinPanel")))

	# 强制隐藏所有面板
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
		print("  - GameOverPanel 已隐藏")
	if has_node("WinPanel"):
		$WinPanel.visible = false
		print("  - WinPanel 已隐藏")
	if has_node("StartPanel"):
		$StartPanel.visible = true
		print("  - StartPanel 已显示")

	# 清除暂停状态
	get_tree().paused = false
	print("  - 暂停状态已清除")

	# 重置游戏状态
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		print("  - 找到 GameManager，调用 reset_game()")
		gm.reset_game()
		print("  - reset_game() 调用完成")
		print("✅ [RESTART] 游戏已重置")
	else:
		print("❌ [RESTART] 未找到 GameManager!")

func show_game_over(kills):
	print("💀 [GAME_OVER] 游戏结束")
	# 显示分数面板，包含LOST文字
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = true
		$GameOverPanel/PanelContainer/VBoxContainer/GameOverLabel.text = "💀 LOST 💀"
		$GameOverPanel/PanelContainer/VBoxContainer/GameOverLabel.add_theme_font_size_override("font_size", 80)
		$GameOverPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: %d" % kills
		# 设置红色文字
		$GameOverPanel/PanelContainer/VBoxContainer/GameOverLabel.modulate = Color(1, 0.2, 0.2)
	get_tree().paused = true
	print("✅ 游戏结束面板已显示")

func show_win(kills):
	print("🏆 [WIN] 游戏胜利")
	# 显示分数面板，包含WON文字
	if has_node("WinPanel"):
		$WinPanel.visible = true
		$WinPanel/PanelContainer/VBoxContainer/WinLabel.text = "🏆 WON 🏆"
		$WinPanel/PanelContainer/VBoxContainer/WinLabel.add_theme_font_size_override("font_size", 80)
		$WinPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: " + str(kills)
		# 设置绿色文字
		$WinPanel/PanelContainer/VBoxContainer/WinLabel.modulate = Color(0.2, 1, 0.2)
	get_tree().paused = true
	print("✅ 胜利面板已显示")

func show_upgrade_panel():
	if has_node("UpgradePanel"):
		$UpgradePanel.visible = true
		get_tree().paused = true

func hide_upgrade_panel():
	if has_node("UpgradePanel"):
		$UpgradePanel.visible = false
		get_tree().paused = false

func _add_upgrade_buttons():
	if not has_node("UpgradePanel"):
		return
	var panel = get_node("UpgradePanel")
	if not panel or not panel.has_node("PanelContainer/VBoxContainer"):
		return
	var vbox = panel.get_node("PanelContainer/VBoxContainer")
	# 清除旧按钮
	for child in vbox.get_children():
		if child is Button:
			child.queue_free()
	# 添加三个升级选项按钮
	var options = ["射速+20%", "伤害+50%", "生命+20"]
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		btn.name = "UpgradeBtn" + str(i)
		btn.custom_minimum_size = Vector2(200, 50)
		vbox.add_child(btn)
		print("✅ 升级按钮", i, "已添加: ", options[i])

func _add_bottom_status_bar():
	# 创建底部状态栏容器
	var container = VBoxContainer.new()
	container.name = "BottomStatusBar"
	container.position = Vector2(0, 1240)  # 屏幕底部（1280-40）
	container.size = Vector2(720, 40)
	add_child(container)
	
	# 状态标签
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
	triple_label.text = "🔫 三发子弹: 未解锁 (0/5)"
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
	# 动态创建底部健康警报面板
	var panel = Panel.new()
	panel.name = "HealthAlertPanel"
	panel.visible = true  # 始终可见
	panel.layout_mode = 1  # Anchor mode
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = -120.0  # 120px 高
	panel.modulate = Color(1, 1, 1, 0.8)  # 半透明
	add_child(panel)
	
	# 容器
	var container = VBoxContainer.new()
	container.name = "HealthAlertContainer"
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.custom_minimum_size = Vector2(0, 100)
	panel.add_child(container)
	
	# 标题
	var label = Label.new()
	label.name = "HealthAlertLabel"
	label.text = "❤️ 玩家健康"
	label.add_theme_font_size_override("font_size", 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(1, 0.3, 0.3)
	container.add_child(label)
	
	# 健康条容器
	var bar_container = HBoxContainer.new()
	bar_container.name = "HealthBarContainer"
	bar_container.custom_minimum_size = Vector2(0, 50)
	bar_container.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(bar_container)
	
	# 健康文字
	var text_label = Label.new()
	text_label.name = "HealthTextLabel"
	text_label.text = "HP: 100/100"
	text_label.add_theme_font_size_override("font_size", 24)
	text_label.modulate = Color(1, 1, 1)
	bar_container.add_child(text_label)
	
	# 健康条
	var bar = ProgressBar.new()
	bar.name = "HealthBar"
	bar.value = 100.0
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.size_flags_horizontal = Control.SIZE_FILL
	bar.add_theme_constant_override("separation", 10)
	bar.modulate = Color(0, 1, 0)  # 初始绿色
	bar_container.add_child(bar)
	
	print("✅ 健康警报面板已创建")

func _add_coordinate_markers():
	var marker_label = Label.new()
	marker_label.name = "CoordMarker"
	marker_label.text = "X坐标: 0(左边缘) | 360(玩家) | 720(右边缘) | Y=-600生成 | Y=1100玩家"
	marker_label.position = Vector2(0, 0)
	marker_label.modulate = Color(1, 1, 0.5)
	marker_label.add_theme_font_size_override("font_size", 16)
	add_child(marker_label)
	
	# 添加X坐标数字标签
	var x_labels = [0, 100, 200, 300, 360, 400, 500, 600, 700, 720]
	for x in x_labels:
		var label = Label.new()
		label.name = "XLabel_" + str(x)
		label.text = str(x)
		label.position = Vector2(x - 10, 18)
		label.modulate = Color(1, 1, 1)
		label.add_theme_font_size_override("font_size", 12)
		add_child(label)
	
	# 添加Y坐标数字标签
	var y_labels = [-600, -300, 0, 300, 600, 900, 1100, 1280]
	for y in y_labels:
		var label = Label.new()
		label.name = "YLabel_" + str(y)
		label.text = str(y)
		label.position = Vector2(5, y - 6)
		label.modulate = Color(1, 1, 1)
		label.add_theme_font_size_override("font_size", 12)
		add_child(label)
