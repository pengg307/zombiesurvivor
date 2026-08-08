extends Node2D
class_name EnemySpawner

const SPAWN_INTERVAL = 2.0
const MAX_ENEMIES = 50
const BOSS_KILLS_REQUIRED = 5
const SQUARE_SPACING = 60.0
const SCREEN_WIDTH = 720.0
const BOSS_HEALTH = 500.0

# 5x5矩阵生成
const SPAWN_MATRIX_SIZE = 5
const SPAWN_LEFT_X = -150.0
const SPAWN_RIGHT_X = 150.0
const SPAWN_TOP_Y = -200.0

var spawn_timer = Timer.new()
var wave_active = false
var current_kills = 0
var boss_active = false
var wave_number = 1
var spawn_side = 0
var audio_manager = null
var game_manager = null
var type_log_count = {"basic": 0, "fast": 0, "boss": 0}

signal boss_spawned
signal game_over
signal game_won

func _ready():
	add_to_group("audio_manager")
	add_to_group("spawner")  # 添加spawner组
	add_child(spawn_timer)
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am
	
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		game_manager = gm
	
	print("")
	print("============================================================")
	print("🎮 EnemySpawner启动！")
	print("============================================================")
	print("📊 生成模式: 5x5矩阵")
	print("📊 僵尸类型分布:")
	print("   - basic: 65% (10血, 50速)")
	print("   - fast: 35% (8血, 70速)")
	print("👹 Boss: 击杀" + str(BOSS_KILLS_REQUIRED) + "后出现 (500血)")
	print("============================================================")
	print("")
	
	start_wave()
	spawn_timer.start()
	_spawn_matrix()

func _on_spawn_timer_timeout():
	if wave_active and current_kills < BOSS_KILLS_REQUIRED:
		_spawn_matrix()

func start_wave():
	wave_active = true
	wave_number = 1
	print("")
	print("🌊 第" + str(wave_number) + "波开始！")
	print("")

func _spawn_matrix():
	print("----------------------------------------")
	print("👾 生成5x5矩阵！")
	
	var total_zombies = SPAWN_MATRIX_SIZE * SPAWN_MATRIX_SIZE
	print("📐 矩阵大小: " + str(SPAWN_MATRIX_SIZE) + "x" + str(SPAWN_MATRIX_SIZE) + "（共" + str(total_zombies) + "个僵尸）")
	
	var start_x: float
	var start_y: float = SPAWN_TOP_Y
	var side: String
	
	if spawn_side == 0:
		start_x = SPAWN_LEFT_X
		side = "左侧"
		print("🎯 从左侧生成: x=" + str(int(start_x)) + " ~ " + str(int(start_x + (SPAWN_MATRIX_SIZE-1) * SQUARE_SPACING)))
	else:
		start_x = SPAWN_RIGHT_X
		side = "右侧"
		print("🎯 从右侧生成: x=" + str(int(start_x)) + " ~ " + str(int(start_x + (SPAWN_MATRIX_SIZE-1) * SQUARE_SPACING)))
	
	spawn_side = 1 - spawn_side
	
	var spawned_count = 0
	for row in range(SPAWN_MATRIX_SIZE):
		for col in range(SPAWN_MATRIX_SIZE):
			var zombie_scene = load("res://scripts/Zombie.gd")
			if zombie_scene:
				var zombie_type = _get_random_type()
				var zombie = zombie_scene.new()
				zombie.zombie_type = zombie_type
				var x = start_x + col * SQUARE_SPACING
				var y = start_y + row * SQUARE_SPACING
				zombie.position = Vector2(x, y)
				zombie.z_index = 100
				zombie.side = side
				add_child(zombie)
				type_log_count[zombie_type] = type_log_count.get(zombie_type, 0) + 1
				spawned_count += 1
				if spawned_count <= 3 or spawned_count == total_zombies:
					print("  ✅ 僵尸" + str(spawned_count) + ": 类型=" + zombie_type + " 位置=(" + str(int(x)) + "," + str(int(y)) + ")")
	
	print("📊 已生成: " + str(spawned_count) + "/" + str(total_zombies))
	print("📊 当前统计: basic=" + str(type_log_count.get("basic", 0)) + 
	      " fast=" + str(type_log_count.get("fast", 0)) + 
	      " boss=" + str(type_log_count.get("boss", 0)))
	print("----------------------------------------")
	print("")

func _get_random_type() -> String:
	# 已达到Boss生成条件时，强制生成Boss
	if current_kills >= BOSS_KILLS_REQUIRED and not boss_active:
		return "boss"
	
	var rand = randi() % 100
	var fast_bonus = min(20, current_kills)
	
	var basic_chance = 65 - fast_bonus
	var fast_chance = 35 + fast_bonus
	
	if rand < fast_chance:
		return "fast"
	else:
		return "basic"

func add_kill():
	current_kills += 1
	print("")
	print("💀 [击杀数] " + str(current_kills) + "/" + str(BOSS_KILLS_REQUIRED))
	
	if current_kills >= BOSS_KILLS_REQUIRED and not boss_active:
		_spawn_boss()

func _spawn_boss():
	print("")
	print("👹 Boss生成！")
	if audio_manager:
		audio_manager.play_boss_spawn()
	
	var zombie_scene = load("res://scripts/Zombie.gd")
	if zombie_scene:
		var boss = zombie_scene.new()
		boss.zombie_type = "boss"
		boss.is_boss = true
		boss.position = Vector2(0, SPAWN_TOP_Y)
		add_child(boss)
		boss_active = true
		emit_signal("boss_spawned")
		print("✅ Boss已生成！血量=" + str(BOSS_HEALTH))

func get_current_kills() -> int:
	return current_kills

func is_boss_active() -> bool:
	return boss_active

func _spawn_ammo_barrel(start_x: float) -> bool:
	if boss_active:
		return false
	print("🛢️ 生成弹药桶！")
	var barrel_scene = load("res://scripts/AmmoBarrel.gd")
	if barrel_scene:
		var barrel = barrel_scene.new()
		barrel.position = Vector2(start_x, SPAWN_TOP_Y + 100)
		barrel.barrel_type = randi() % 3
		barrel.z_index = 50
		add_child(barrel)
		print("✅ 弹药桶生成成功！类型=" + str(barrel.barrel_type))
		return true
	else:
		print("❌ 无法加载AmmoBarrel脚本！")
		return false
