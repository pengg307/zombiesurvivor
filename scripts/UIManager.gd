extends CanvasLayer
class_name UIManager

var player = null
var spawner = null
var audio_manager = null

func _ready():
	# 连接音频管理器
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am
	
	# 初始化面板可见性
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
	
	# 连接按钮
	_connect_buttons()
	
	# 添加坐标参考线
	_add_coordinate_markers()
	
	# 添加三发子弹状态显示
	_add_triple_shot_display()
	
	# 添加手雷显示
	_add_grenade_display()
	
	# 添加新的状态显示
	_add_status_displays()
	
	print("✅ UIManager初始化完成")

func _process(_delta):
	if player:
		_update_health()
		_update_level()
		_update_kills()
		_update_triple_shot()
		_update_grenades()
		_update_status()
		_update_boss_progress()

func set_player(player_node):
	player = player_node
	print("✅ Player引用已设置")

func set_spawner(spawner_node):
	spawner = spawner_node
	print("✅ Spawner引用已设置")

func _connect_buttons():
	if has_node("StartPanel/PanelContainer/VBoxContainer/StartButton"):
		$StartPanel/PanelContainer/VBoxContainer/StartButton.pressed.connect(_on_start_game)
	if has_node("GameOverPanel/PanelContainer/VBoxContainer/RestartButton"):
		$GameOverPanel/PanelContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_game)
	if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
		$WinPanel/PanelContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_game)
	_add_upgrade_buttons()

func _update_health():
	if player and has_node("Panel/HealthBarContainer/HealthBar"):
		var health_pct = float(player.current_health) / float(player.MAX_HEALTH) * 100
		$Panel/HealthBarContainer/HealthBar.value = health_pct
		$Panel/HealthBarContainer/HealthLabel.text = "HP: %d/%d" % [player.current_health, player.MAX_HEALTH]

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

func _update_status():
	if player:
		if has_node("DamageDisplay"):
			$DamageDisplay.text = "⚔️ 伤害: %.1f" % player.damage_per_shot
		if has_node("SpeedDisplay"):
			$SpeedDisplay.text = "💨 射速: %.2fs" % player.fire_rate
		if has_node("BulletSpeedDisplay"):
			$BulletSpeedDisplay.text = "🚀 子弹速度: %d" % player.bullet_speed
		if player.ammo_boost_timer > 0:
			if has_node("AmmoBoostDisplay"):
				$AmmoBoostDisplay.text = "🛢️ 增益: %ds" % int(player.ammo_boost_timer)
				$AmmoBoostDisplay.visible = true
		if has_node("AmmoBoostDisplay"):
			$AmmoBoostDisplay.visible = player.ammo_boost_timer > 0

func _update_boss_progress():
	if spawner and has_node("BossProgress"):
		var boss_required = spawner.BOSS_KILLS_REQUIRED
		var boss_current = spawner.current_kills
		$BossProgress.text = "👹 Boss进度: %d/%d" % [boss_current, boss_required]

func _on_start_game():
	if has_node("StartPanel"):
		$StartPanel.visible = false
		print("🎮 游戏开始！")

func _on_restart_game():
	get_tree().reload_current_scene()

func show_game_over(kills):
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = true
		$GameOverPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: %d" % kills
		get_tree().paused = true
		if audio_manager:
			audio_manager.play_game_over()

func show_win(kills):
	if has_node("WinPanel"):
		$WinPanel.visible = true
		$WinPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: %d" % kills
		get_tree().paused = true
		if audio_manager:
			audio_manager.play_victory()

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

func _add_status_displays():
	# 添加伤害显示
	var damage_label = Label.new()
	damage_label.name = "DamageDisplay"
	damage_label.text = "⚔️ 伤害: 10.0"
	damage_label.position = Vector2(600, 60)
	damage_label.modulate = Color(1, 0.3, 0.3)
	damage_label.add_theme_font_size_override("font_size", 16)
	add_child(damage_label)
	
	# 添加射速显示
	var speed_label = Label.new()
	speed_label.name = "SpeedDisplay"
	speed_label.text = "💨 射速: 0.30s"
	speed_label.position = Vector2(600, 80)
	speed_label.modulate = Color(0.3, 1, 0.3)
	speed_label.add_theme_font_size_override("font_size", 16)
	add_child(speed_label)
	
	# 添加子弹速度显示
	var bullet_speed_label = Label.new()
	bullet_speed_label.name = "BulletSpeedDisplay"
	bullet_speed_label.text = "🚀 子弹速度: 600"
	bullet_speed_label.position = Vector2(600, 100)
	bullet_speed_label.modulate = Color(0.3, 0.3, 1)
	bullet_speed_label.add_theme_font_size_override("font_size", 16)
	add_child(bullet_speed_label)
	
	# 添加增益计时器显示
	var ammo_boost_label = Label.new()
	ammo_boost_label.name = "AmmoBoostDisplay"
	ammo_boost_label.text = "🛢️ 增益: 0s"
	ammo_boost_label.position = Vector2(600, 120)
	ammo_boost_label.modulate = Color(1, 1, 0.3)
	ammo_boost_label.add_theme_font_size_override("font_size", 16)
	ammo_boost_label.visible = false
	add_child(ammo_boost_label)
	
	# 添加Boss进度显示
	var boss_progress_label = Label.new()
	boss_progress_label.name = "BossProgress"
	boss_progress_label.text = "👹 Boss进度: 0/10"
	boss_progress_label.position = Vector2(600, 140)
	boss_progress_label.modulate = Color(1, 0.5, 0.5)
	boss_progress_label.add_theme_font_size_override("font_size", 16)
	add_child(boss_progress_label)
