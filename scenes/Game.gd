extends Node2D

# 主场景脚本
func _ready() -> void:
	# 获取节点
	var player = $Player
	var spawner = $EnemySpawner
	var ui = $UI
	
	# 连接信号
	player.health_changed.connect(_on_health_changed)
	player.level_up.connect(_on_level_up)
	
	# 设置UI
	ui.set_player(player)
	ui.set_spawner(spawner)
	
	# 开始游戏
	spawner.start_wave()
	ui.hide_start_screen()

func _on_health_changed(current: float, max_hp: float) -> void:
	pass

func _on_level_up(level: int) -> void:
	pass

func _input(event: InputEvent) -> void:
	# ESC暂停
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
