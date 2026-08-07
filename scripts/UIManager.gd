extends CanvasLayer
class_name UIManager

var player = null
var spawner = null

func _ready():
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
	if has_node("StartPanel/PanelContainer/VBoxContainer/StartButton"):
		$StartPanel/PanelContainer/VBoxContainer/StartButton.pressed.connect(_on_start_game)
	
	if has_node("GameOverPanel/PanelContainer/VBoxContainer/RestartButton"):
		$GameOverPanel/PanelContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_game)
	
	if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
		$WinPanel/PanelContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_game)
	
	# 添加坐标参考线
	_add_coordinate_markers()
	
	# 添加三发子弹状态显示
	_add_triple_shot_display()
	
	print("✅ UIManager初始化完成")

func _process(_delta):
	if player:
		_update_health()
		_update_level()
		_update_kills()
		_update_triple_shot()

func set_player(player_node):
	player = player_node
	print("✅ Player引用已设置")

func set_spawner(spawner_node):
	spawner = spawner_node
	print("✅ Spawner引用已设置")

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
		var text = "🔫 三发子弹: " + ("已解锁" if player.triple_shot_unlocked else "未解锁 (" + str(player.kills) + "/5)")
		$TripleShotDisplay.text = text
		if player.triple_shot_unlocked:
			$TripleShotDisplay.modulate = Color(1, 1, 0.5)
		else:
			$TripleShotDisplay.modulate = Color(1, 1, 1)

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

func show_win(kills):
	if has_node("WinPanel"):
		$WinPanel.visible = true
		$WinPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: %d" % kills
		get_tree().paused = true

func _add_coordinate_markers():
	# 在屏幕顶部添加X坐标参考
	var marker_label = Label.new()
	marker_label.name = "CoordMarker"
	marker_label.text = "X坐标: 0(左边缘) | 360(玩家) | 720(右边缘) | Y=-600生成 | Y=1100玩家"
	marker_label.position = Vector2(0, 0)
	marker_label.modulate = Color(1, 1, 0.5)
	marker_label.add_theme_font_size_override("font_size", 16)
	add_child(marker_label)
	
	# 添加X坐标数字标签（顶部）
	var x_labels = [0, 100, 200, 300, 360, 400, 500, 600, 700, 720]
	for x in x_labels:
		var label = Label.new()
		label.name = "XLabel_" + str(x)
		label.text = str(x)
		label.position = Vector2(x - 10, 18)
		label.modulate = Color(1, 1, 1)
		label.add_theme_font_size_override("font_size", 12)
		add_child(label)
	
	# 添加Y坐标数字标签（左侧）
	var y_labels = [-600, -300, 0, 300, 600, 900, 1100, 1280]
	for y in y_labels:
		var label = Label.new()
		label.name = "YLabel_" + str(y)
		label.text = str(y)
		label.position = Vector2(5, y - 6)
		label.modulate = Color(1, 1, 1)
		label.add_theme_font_size_override("font_size", 12)
		add_child(label)
	
	# 添加垂直参考线（用Line2D）
	# 红色线：X=360（玩家位置）
	var ref_line = Line2D.new()
	ref_line.name = "RefLine"
	ref_line.width = 3.0
	ref_line.default_color = Color(1, 0, 0, 0.7)
	ref_line.add_point(Vector2(360, 0))
	ref_line.add_point(Vector2(360, 1280))
	add_child(ref_line)
	
	# 添加X=0参考线（绿色）
	var ref_line_0 = Line2D.new()
	ref_line_0.name = "RefLine0"
	ref_line_0.width = 2.0
	ref_line_0.default_color = Color(0, 1, 0, 0.5)
	ref_line_0.add_point(Vector2(0, 0))
	ref_line_0.add_point(Vector2(0, 1280))
	add_child(ref_line_0)
	
	# 添加X=720参考线（蓝色）
	var ref_line_720 = Line2D.new()
	ref_line_720.name = "RefLine720"
	ref_line_720.width = 2.0
	ref_line_720.default_color = Color(0, 0, 1, 0.5)
	ref_line_720.add_point(Vector2(720, 0))
	ref_line_720.add_point(Vector2(720, 1280))
	add_child(ref_line_720)
	
	# 添加Y=-600参考线（黄色，在屏幕上方外）
	var ref_line_y600 = Line2D.new()
	ref_line_y600.name = "RefLineY600"
	ref_line_y600.width = 2.0
	ref_line_y600.default_color = Color(1, 1, 0, 0.5)
	ref_line_y600.add_point(Vector2(0, -600))
	ref_line_y600.add_point(Vector2(720, -600))
	add_child(ref_line_y600)
	
	# 添加Y=1100参考线（紫色）
	var ref_line_y1100 = Line2D.new()
	ref_line_y1100.name = "RefLineY1100"
	ref_line_y1100.width = 2.0
	ref_line_y1100.default_color = Color(1, 0, 1, 0.5)
	ref_line_y1100.add_point(Vector2(0, 1100))
	ref_line_y1100.add_point(Vector2(720, 1100))
	add_child(ref_line_y1100)

func _add_triple_shot_display():
	# 添加三发子弹状态显示
	var triple_label = Label.new()
	triple_label.name = "TripleShotDisplay"
	triple_label.text = "🔫 三发子弹: 未解锁 (0/5)"
	triple_label.position = Vector2(600, 10)
	triple_label.modulate = Color(1, 1, 1)
	triple_label.add_theme_font_size_override("font_size", 18)
	add_child(triple_label)
