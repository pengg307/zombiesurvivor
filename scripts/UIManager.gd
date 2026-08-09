extends CanvasLayer
class_name UIManager

var player = null
var spawner = null
var audio_manager = null

func _ready():
	# 杩炴帴闊抽绠＄悊鍣?	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am
	
	# 鍒濆鍖栭潰鏉垮彲瑙佹€?	if has_node("StartPanel"):
		$StartPanel.visible = true
	if has_node("UpgradePanel"):
		$UpgradePanel.visible = false
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
	if has_node("WinPanel"):
		$WinPanel.visible = false
	if has_node("BossPanel"):
		$BossPanel.visible = false
	
	# 杩炴帴鎸夐挳
	_connect_buttons()
	
	# 娣诲姞搴曢儴鐘舵€佹爮
	_add_bottom_status_bar()
	
	# 娣诲姞涓夊彂瀛愬脊鐘舵€佹樉绀?	_add_triple_shot_display()
	
	# 娣诲姞鎵嬮浄鏄剧ず
	_add_grenade_display()
	
	print("鉁?UIManager鍒濆鍖栧畬鎴?)

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
	# 璋冭瘯锛氭崟鑾锋墍鏈夐紶鏍囩偣鍑伙紙鍖呮嫭鏆傚仠鏃讹級
	if event is InputEventMouseButton and event.pressed:
		print("馃柋锔?[INPUT] 榧犳爣鐐瑰嚮: button_index=" + str(event.button_index) + " pos=" + str(event.position))
		print("  - 鏆傚仠鐘舵€? " + str(get_tree().paused))
		if has_node("WinPanel") and $WinPanel.visible:
			print("  - WinPanel 鍙锛屾鏌ユ寜閽?..")
			if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
				var btn = $WinPanel/PanelContainer/VBoxContainer/RestartButton
				print("  - 鎸夐挳浣嶇疆: " + str(btn.position) + " 澶у皬: " + str(btn.size))
				print("  - 鎸夐挳鍖哄煙: " + str(btn.get_global_rect()))
				# 妫€鏌ョ偣鍑绘槸鍚﹀湪鎸夐挳鍖哄煙鍐?				var global_pos = btn.get_global_rect().get_center()
				print("  - 鎸夐挳涓績: " + str(global_pos))

func set_player(player_node):
	player = player_node
	print("鉁?Player寮曠敤宸茶缃?)

func set_spawner(spawner_node):
	spawner = spawner_node
	print("鉁?Spawner寮曠敤宸茶缃?)

func _connect_buttons():
	print("馃敆 杩炴帴鎸夐挳淇″彿...")
	print("  - 褰撳墠鑺傜偣璺緞: " + str(get_path()))
	
	# 妫€鏌?StartPanel
	if has_node("StartPanel"):
		print("  - 鎵惧埌 StartPanel")
		if has_node("StartPanel/PanelContainer/VBoxContainer/StartButton"):
			$StartPanel/PanelContainer/VBoxContainer/StartButton.pressed.connect(_on_start_game)
			print("  鉁?StartButton 宸茶繛鎺?)
		else:
			print("  鉂?鏈壘鍒?StartButton")
	else:
		print("  鉂?鏈壘鍒?StartPanel")
	
	# 妫€鏌?GameOverPanel
	if has_node("GameOverPanel"):
		print("  - 鎵惧埌 GameOverPanel")
		if has_node("GameOverPanel/PanelContainer/VBoxContainer/RestartButton"):
			$GameOverPanel/PanelContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart_game)
			print("  鉁?GameOverPanel RestartButton 宸茶繛鎺?)
		else:
			print("  鉂?鏈壘鍒?GameOverPanel/RestartButton")
	else:
		print("  鉂?鏈壘鍒?GameOverPanel")
	
	# 妫€鏌?WinPanel
	if has_node("WinPanel"):
		print("  - 鎵惧埌 WinPanel")
		if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
			var restart_btn = $WinPanel/PanelContainer/VBoxContainer/RestartButton
			restart_btn.pressed.connect(_on_restart_game)
			# 棰濆璋冭瘯
			restart_btn.gui_input.connect(func(event): 
				if event is InputEventMouseButton and event.pressed:
					print(">>> GUI_INPUT: " + str(event))
			)
			print("  鉁?WinPanel RestartButton 宸茶繛鎺?)
			print("  - 鎸夐挳鍙: " + str(restart_btn.visible))
			print("  - 鎸夐挳浣嶇疆: " + str(restart_btn.position))
			print("  - 鎸夐挳澶у皬: " + str(restart_btn.size))
		else:
			print("  鉂?鏈壘鍒?WinPanel/RestartButton")
			print("  - WinPanel 瀛愯妭鐐?")
			for child in get_node("WinPanel").get_children():
				print("    - " + child.name + " (" + child.get_class() + ")")
		print("  - WinPanel.visible = " + str($WinPanel.visible))
	else:
		print("  鉂?鏈壘鍒?WinPanel")
	
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
		var text = "馃敨 涓夊彂瀛愬脊: " + ("宸茶В閿? if player.triple_shot_unlocked else "鏈В閿?(%d/5)" % player.kills)
		$TripleShotDisplay.text = text
		$TripleShotDisplay.modulate = Color(1, 1, 0.5) if player.triple_shot_unlocked else Color(1, 1, 1)

func _update_grenades():
	if player and has_node("GrenadeDisplay"):
		$GrenadeDisplay.text = "馃挘 鎵嬮浄: %d" % player.grenades

func _update_bottom_status():
	# 搴曢儴鐘舵€佹爮瀹炴椂鏇存柊
	if has_node("BottomStatusBar"):
		var status_text = ""
		
		# 浼ゅ
		if player:
			status_text += "鈿旓笍%.1f " % player.damage_per_shot
		
		# 灏勯€?		if player:
			status_text += "馃挩%.2fs " % player.fire_rate
		
		# 瀛愬脊閫熷害
		if player:
			status_text += "馃殌%d " % player.bullet_speed
		
		# 澧炵泭鐘舵€?		if player and player.ammo_boost_timer > 0:
			status_text += "馃洟锔?ds" % int(player.ammo_boost_timer)
		
		$BottomStatusBar/StatusLabel.text = status_text

func _update_boss_progress():
	if spawner and has_node("BossProgress"):
		var boss_required = spawner.BOSS_KILLS_REQUIRED
		var boss_current = spawner.current_kills
		$BossProgress.text = "馃懝 Boss杩涘害: %d/%d" % [boss_current, boss_required]

func _on_start_game():
	if has_node("StartPanel"):
		$StartPanel.visible = false
		print("馃幃 娓告垙寮€濮嬶紒")
		# 閫氱煡 GameManager 寮€濮嬫父鎴?		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm:
			gm._start_game()

func _on_restart_game():
	print("馃攧 [RESTART] 閲嶆柊寮€濮嬫父鎴忚鐐瑰嚮!")
	print("  - 褰撳墠鏃堕棿: " + str(Time.get_ticks_msec()))
	print("  - 鏆傚仠鐘舵€? " + str(get_tree().paused))
	print("  - 鍦烘櫙璺緞: " + str(get_path()))
	print("  - UIManager鑺傜偣: " + str(self))
	print("  - WinPanel鑺傜偣: " + str(get_node("WinPanel")))

	# 寮哄埗闅愯棌鎵€鏈夐潰鏉?	if has_node("GameOverPanel"):
		$GameOverPanel.visible = false
		print("  - GameOverPanel 宸查殣钘?)
	if has_node("WinPanel"):
		$WinPanel.visible = false
		print("  - WinPanel 宸查殣钘?)
	if has_node("StartPanel"):
		$StartPanel.visible = true
		print("  - StartPanel 宸叉樉绀?)

	# 娓呴櫎鏆傚仠鐘舵€?	get_tree().paused = false
	print("  - 鏆傚仠鐘舵€佸凡娓呴櫎")

	# 閲嶇疆娓告垙鐘舵€?	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		print("  - 鎵惧埌 GameManager锛岃皟鐢?reset_game()")
		gm.reset_game()
		print("  - reset_game() 璋冪敤瀹屾垚")
		print("鉁?[RESTART] 娓告垙宸查噸缃?)
	else:
		print("鉂?[RESTART] 鏈壘鍒?GameManager!")

func show_game_over(kills):
	if has_node("GameOverPanel"):
		$GameOverPanel.visible = true
		$GameOverPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: %d" % kills
		get_tree().paused = true
		if audio_manager and audio_manager.has_method("play_game_over"):
			audio_manager.play_game_over()

func show_win(kills):
	print("馃弳 [SHOW_WIN] 鏄剧ず鑳滃埄闈㈡澘")
	print("  - kills = " + str(kills))
	if has_node("WinPanel"):
		$WinPanel.visible = true
		$WinPanel/PanelContainer/VBoxContainer/ScoreLabel.text = "Kills: " + str(kills)
		print("  - WinPanel 宸叉樉绀猴紝visible = " + str($WinPanel.visible))
		# 寮哄埗璁╂寜閽彲瑙?		if has_node("WinPanel/PanelContainer/VBoxContainer/RestartButton"):
			$WinPanel/PanelContainer/VBoxContainer/RestartButton.visible = true
			print("  - RestartButton 宸插己鍒舵樉绀?)
		get_tree().paused = true
		print("  - 娓告垙宸叉殏鍋?)
		if audio_manager and audio_manager.has_method("play_victory"):
			audio_manager.play_victory()
	else:
		print("  鉂?鏈壘鍒?WinPanel!")

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
	# 娓呴櫎鏃ф寜閽?	for child in vbox.get_children():
		if child is Button:
			child.queue_free()
	# 娣诲姞涓変釜鍗囩骇閫夐」鎸夐挳
	var options = ["灏勯€?20%", "浼ゅ+50%", "鐢熷懡+20"]
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		btn.name = "UpgradeBtn" + str(i)
		btn.custom_minimum_size = Vector2(200, 50)
		vbox.add_child(btn)
		print("鉁?鍗囩骇鎸夐挳", i, "宸叉坊鍔? ", options[i])

func _add_bottom_status_bar():
	# 鍒涘缓搴曢儴鐘舵€佹爮瀹瑰櫒
	var container = VBoxContainer.new()
	container.name = "BottomStatusBar"
	container.position = Vector2(0, 1240)  # 灞忓箷搴曢儴锛?280-40锛?	container.size = Vector2(720, 40)
	add_child(container)
	
	# 鐘舵€佹爣绛?	var status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "鈿旓笍10.0 馃挩0.30s 馃殌600"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.modulate = Color(1, 1, 0.8)
	container.add_child(status_label)

func _add_triple_shot_display():
	var triple_label = Label.new()
	triple_label.name = "TripleShotDisplay"
	triple_label.text = "馃敨 涓夊彂瀛愬脊: 鏈В閿?(0/5)"
	triple_label.position = Vector2(600, 10)
	triple_label.modulate = Color(1, 1, 1)
	triple_label.add_theme_font_size_override("font_size", 18)
	add_child(triple_label)

func _add_grenade_display():
	var grenade_label = Label.new()
	grenade_label.name = "GrenadeDisplay"
	grenade_label.text = "馃挘 鎵嬮浄: 0"
	grenade_label.position = Vector2(600, 35)
	grenade_label.modulate = Color(1, 0.5, 0.3)
	grenade_label.add_theme_font_size_override("font_size", 18)
	add_child(grenade_label)

func _add_coordinate_markers():
	var marker_label = Label.new()
	marker_label.name = "CoordMarker"
	marker_label.text = "X鍧愭爣: 0(宸﹁竟缂? | 360(鐜╁) | 720(鍙宠竟缂? | Y=-600鐢熸垚 | Y=1100鐜╁"
	marker_label.position = Vector2(0, 0)
	marker_label.modulate = Color(1, 1, 0.5)
	marker_label.add_theme_font_size_override("font_size", 16)
	add_child(marker_label)
	
	# 娣诲姞X鍧愭爣鏁板瓧鏍囩
	var x_labels = [0, 100, 200, 300, 360, 400, 500, 600, 700, 720]
	for x in x_labels:
		var label = Label.new()
		label.name = "XLabel_" + str(x)
		label.text = str(x)
		label.position = Vector2(x - 10, 18)
		label.modulate = Color(1, 1, 1)
		label.add_theme_font_size_override("font_size", 12)
		add_child(label)
	
	# 娣诲姞Y鍧愭爣鏁板瓧鏍囩
	var y_labels = [-600, -300, 0, 300, 600, 900, 1100, 1280]
	for y in y_labels:
		var label = Label.new()
		label.name = "YLabel_" + str(y)
		label.text = str(y)
		label.position = Vector2(5, y - 6)
		label.modulate = Color(1, 1, 1)
		label.add_theme_font_size_override("font_size", 12)
		add_child(label)
