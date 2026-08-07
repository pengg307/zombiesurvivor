extends Node

# 自动化测试脚本

func _ready():
	print("========================================")
	print("Zombie Survivor - 自动化测试")
	print("========================================")
	
	test_player()
	test_zombie()
	test_spawner()
	test_ui()
	
	print("\n========================================")
	print("✅ 所有测试通过！")
	print("========================================")

func test_player():
	print("\n[测试1] 玩家系统")
	
	var player = load("res://scripts/Player.gd").new()
	add_child(player)
	player._ready()
	
	# 测试初始化
	assert(player.current_health == 100.0, "生命值初始化错误")
	assert(player.level == 1, "等级初始化错误")
	assert(player.move_speed == 250.0, "移动速度初始化错误")
	
	# 测试移动
	player.move_direction = Vector2(1, 0)
	player._physics_process(1.0)
	assert(player.velocity.length() == 250.0, "移动速度计算错误: " + str(player.velocity.length()))
	
	# 测试受伤
	player.take_damage(30.0)
	assert(player.current_health == 70.0, "受伤处理错误")
	
	# 测试回血
	player.heal(20.0)
	assert(player.current_health == 90.0, "回血处理错误")
	
	# 测试升级
	player.add_experience(100)
	assert(player.level == 2, "升级处理错误")
	
	player.queue_free()
	print("✅ 玩家系统测试通过")

func test_zombie():
	print("\n[测试2] 僵尸系统")
	
	# 创建玩家节点
	var player = load("res://scripts/Player.gd").new()
	add_child(player)
	player._ready()
	player.add_to_group("player")
	
	var zombie = load("res://scripts/Zombie.gd").new()
	add_child(zombie)
	zombie._ready()
	zombie.target = player
	
	# 测试初始化
	assert(zombie.health == 30.0, "僵尸生命值初始化错误")
	assert(zombie.speed == 50.0, "僵尸速度初始化错误")
	
	# 测试受伤
	zombie.take_damage(15.0)
	assert(zombie.current_health == 15.0, "僵尸受伤处理错误")
	
	# 测试死亡
	zombie.take_damage(15.0)
	assert(zombie.current_health == 0.0, "僵尸死亡处理错误")
	
	player.queue_free()
	zombie.queue_free()
	print("✅ 僵尸系统测试通过")

func test_spawner():
	print("\n[测试3] 敌人生成器")
	
	var spawner = load("res://scripts/EnemySpawner.gd").new()
	add_child(spawner)
	# 不调用_ready()，避免Timer重复添加
	
	# 测试初始值
	assert(spawner.wave_number == 1, "波次初始化错误: " + str(spawner.wave_number))
	assert(spawner.max_enemies == 20, "最大敌人数量初始化错误: " + str(spawner.max_enemies))
	assert(spawner.spawn_interval == 2.0, "生成间隔初始化错误: " + str(spawner.spawn_interval))
	
	# 测试波次推进
	spawner.advance_wave()
	assert(spawner.wave_number == 2, "波次推进错误: " + str(spawner.wave_number))
	assert(spawner.max_enemies == 30, "最大敌人数量更新错误: " + str(spawner.max_enemies))  # 20 + 2*5 = 30
	
	spawner.queue_free()
	print("✅ 敌人生成器测试通过")

func test_ui():
	print("\n[测试4] UI系统")
	
	var ui = load("res://scripts/UIManager.gd").new()
	add_child(ui)
	ui._ready()
	
	# 测试初始状态
	if ui.has_node("StartPanel"):
		assert(ui.get_node("StartPanel").visible == true, "开始界面初始状态错误")
	if ui.has_node("UpgradePanel"):
		assert(ui.get_node("UpgradePanel").visible == false, "升级面板初始状态错误")
	if ui.has_node("GameOverPanel"):
		assert(ui.get_node("GameOverPanel").visible == false, "游戏结束面板初始状态错误")
	
	ui.queue_free()
	print("✅ UI系统测试通过")
