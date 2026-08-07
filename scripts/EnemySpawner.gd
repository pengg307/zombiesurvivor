extends Node2D
class_name EnemySpawner

const SPAWN_INTERVAL = 3.0
const MAX_ENEMIES = 25
const BOSS_KILLS_REQUIRED = 20  # 提前到20击杀就生成Boss
const FAR_Y = -300.0
const SQUARE_SPACING = 60.0
const SCREEN_WIDTH = 720.0
const BOSS_HEALTH = 250.0

var spawn_timer = Timer.new()
var wave_active = false
var current_kills = 0
var boss_active = false
var wave_number = 1
var square_size_options = [2, 3, 4, 5]
var spawn_left = true  # 强制交替左右生成

func _ready():
	add_child(spawn_timer)
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	print("🎮 EnemySpawner启动！")
	start_wave()
	spawn_timer.start()
	
	# 立即生成第一个方阵（随机选择左右）
	spawn_left = randi() % 2 == 0  # 随机选择左侧或右侧
	spawn_square()

func _on_spawn_timer_timeout():
	if wave_active and current_kills < BOSS_KILLS_REQUIRED:
		spawn_square()
		print("⏰ Timer触发，生成方阵")

func start_wave():
	wave_active = true
	wave_number = 1
	print("🌊 第1波开始！")

func spawn_square():
	print("👾 生成方阵！")
	# 只生成1个僵尸
	var size = 1
	var count = 1
	
	print("📐 方阵大小:", size, "x", size, "（共", count, "个僵尸）")
	
	# 计算方阵宽度
	var square_width = (size - 1) * SQUARE_SPACING
	
	# 强制交替左右生成
	var start_x: float
	var start_y: float = -600.0  # Y从-600开始（更远处）
	var side: String
	var target_x: float  # 目标X坐标（玩家位置）
	
	if spawn_left:
		# 左侧生成：X=-100, Y=-200
		start_x = -100.0
		start_y = -200.0
		side = "左侧"
		print("🎯 左侧生成: start_x=" + str(int(start_x)) + ", start_y=" + str(int(start_y)))
	else:
		# 右侧生成：X=100, Y=-200
		start_x = 100.0
		start_y = -200.0
		side = "右侧"
		print("🎯 右侧生成: start_x=" + str(int(start_x)) + ", start_y=" + str(int(start_y)))
	
	# 切换下次生成方向
	spawn_left = !spawn_left
	
	# 生成方阵中的每个僵尸
	for row in range(size):
		for col in range(size):
			var zombie_scene = load("res://scripts/Zombie.gd")
			if zombie_scene:
				var zombie = zombie_scene.new()
				zombie.zombie_type = _get_random_type()
				
				# 方阵位置计算
				var x = start_x + col * SQUARE_SPACING
				var y = start_y + row * SQUARE_SPACING
				zombie.position = Vector2(x, y)
				# 设置目标X坐标（斜向移动）
				zombie.target_x = target_x
				# 设置z_index，确保僵尸渲染在油桶前面
				zombie.z_index = 100
				zombie.side = side  # 设置side属性用于日志
			
				add_child(zombie)  # 直接添加，不使用call_deferred
				print("✅ Zombie spawned at: " + str(int(zombie.position.x)) + ", " + str(int(zombie.position.y)) + " (" + side + ")")
	
	print("✅ 方阵生成完成！位置:", start_x, start_y, "（", side, "）")
	
	# 每生成一个方阵，有50%概率生成一个弹药桶
	if randf() < 0.5:
		_spawn_ammo_barrel(start_x, side)

func _get_random_square_size() -> int:
	return square_size_options[randi() % square_size_options.size()]

func _get_random_type() -> String:
	var rand = randi() % 100
	if rand < 60:
		return "basic"
	elif rand < 85:
		return "fast"
	else:
		return "tank"

func add_kill():
	current_kills += 1
	print("💀 击杀数:", current_kills, "/", BOSS_KILLS_REQUIRED)
	
	if current_kills >= BOSS_KILLS_REQUIRED and not boss_active:
		spawn_boss()

func spawn_boss():
	print("👹 Boss生成！")
	var zombie_scene = load("res://scripts/Zombie.gd")
	if zombie_scene:
		var boss = zombie_scene.new()
		boss.zombie_type = "boss"
		# Boss从中间生成
		boss.position = Vector2(360, FAR_Y + 50)
		call_deferred("add_child", boss)
		boss_active = true
		print("✅ Boss已生成！血量:", BOSS_HEALTH)

func get_current_kills() -> int:
	return current_kills

func is_boss_active() -> bool:
	return boss_active

func _draw_spawn_marker(x: float, y: float, color: Color, label: String):
	# 绘制生成点标记（调试用）- 在屏幕顶部显示
	var marker = ColorRect.new()
	marker.name = "SpawnMarker"
	marker.color = color
	marker.size = Vector2(40, 40)  # 增大到40x40
	# 根据生成侧调整标记位置
	var screen_x: float
	if x < 0:
		# 左侧生成：标记在屏幕左侧（X=50~100）
		screen_x = x + 360.0
	else:
		# 右侧生成：标记在屏幕右侧（X=460~500）
		# 需要加上360偏移
		screen_x = x + 360.0
	marker.position = Vector2(screen_x - 20, 50)  # Y=50在屏幕顶部可见
	marker.z_index = 200
	add_child(marker)
	print("🎨 生成点标记已添加: " + label + " 颜色=" + str(color) + ", 屏幕位置=(" + str(int(screen_x)) + ", 50)")

func _spawn_ammo_barrel(start_x: float, _side: String):
	print("🛢️ 生成弹药桶！")
	var barrel_scene = load("res://scripts/AmmoBarrel.gd")
	if barrel_scene:
		var barrel = barrel_scene.new()
		# 弹药桶在僵尸方阵下方生成，开始滚动
		barrel.position = Vector2(start_x + 100, FAR_Y + 100)
		barrel.barrel_type = randi() % 3  # 随机三种类型
		barrel.z_index = 50  # 油桶在僵尸后面
		call_deferred("add_child", barrel)
		print("✅ 弹药桶已生成，类型:", barrel.barrel_type)
