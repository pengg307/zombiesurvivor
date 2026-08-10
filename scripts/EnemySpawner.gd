extends Node2D
class_name EnemySpawner

const SPAWN_INTERVAL = 2.5
const BOSS_KILLS_REQUIRED = 5
const SQUARE_SPACING = 80.0
const SCREEN_WIDTH = 720.0
const BOSS_HEALTH = 500.0

# 2x2 matrix spawn
const SPAWN_MATRIX_SIZE = 2
const SPAWN_LEFT_X = -80.0
const SPAWN_RIGHT_X = 80.0
const SPAWN_TOP_Y = -100.0

var spawn_timer = Timer.new()
var wave_active = false
var current_kills = 0
var boss_active = false
var boss_spawned_this_game = false  # Boss只能生成一次
var wave_number = 0
var spawn_side = 0
var zombies_in_wave = 0
var audio_manager = null
var game_manager = null

signal boss_spawned
signal game_over
signal game_won
signal wave_complete

func _ready():
	add_to_group("audio_manager")
	add_to_group("spawner")
	add_child(spawn_timer)
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	# 不自动启动，等待 GameManager._start_game() 调用
	
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
	print("📊 生成模式: " + str(SPAWN_MATRIX_SIZE) + "x" + str(SPAWN_MATRIX_SIZE) + "矩阵")
	print("📊 僵尸类型分布:")
	print("   - basic: 65% (10血, 50速)")
	print("   - fast: 35% (8血, 70速)")
	print("👹 Boss: 击杀" + str(BOSS_KILLS_REQUIRED) + "后出现 (500血，只出现一次)")
	print("============================================================")
	print("")
	# 不自动开始，等待玩家点击"开始游戏"

func _on_spawn_timer_timeout():
	_start_next_wave()

func _start_next_wave():
	wave_number += 1
	wave_active = true
	zombies_in_wave = SPAWN_MATRIX_SIZE * SPAWN_MATRIX_SIZE
	
	print("")
	print("🌊 第" + str(wave_number) + "波开始！")
	if boss_active:
		print("👹 Boss已在场！生成普通僵尸支援！")
	else:
		print("📐 生成" + str(zombies_in_wave) + "个僵尸（5x5矩阵）")
	print("")
	
	_spawn_matrix()

func _spawn_matrix():
	print("----------------------------------------")
	
	var start_x: float
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
			var zombie_scene = load("res://scenes/Zombie.tscn")
			if zombie_scene:
				var zombie_type = _get_random_type()
				var zombie = zombie_scene.instantiate()
				zombie.zombie_type = zombie_type
				var x = start_x + col * SQUARE_SPACING
				var y = SPAWN_TOP_Y + row * SQUARE_SPACING
				zombie.position = Vector2(x, y)
				zombie.z_index = 100
				zombie.side = side
				add_child(zombie)
				spawned_count += 1
	
	print("✅ 已生成" + str(spawned_count) + "个僵尸")
	print("----------------------------------------")
	print("")
	
	# 每3波生成一个弹药桶
	if wave_number % 3 == 0 and not boss_active:
		_spawn_ammo_barrel(start_x)

func _get_random_type() -> String:
	# Boss只在击杀数达到要求时生成，且只生成一次
	if current_kills >= BOSS_KILLS_REQUIRED and not boss_active and not boss_spawned_this_game:
		return "boss"
	
	# 普通僵尸类型
	var rand = randi() % 100
	if rand < 65:
		return "basic"
	else:
		return "fast"

func add_kill():
	current_kills += 1
	zombies_in_wave = max(0, zombies_in_wave - 1)
	
	print("")
	print("💀 [击杀数] " + str(current_kills) + "/" + str(BOSS_KILLS_REQUIRED))
	print("📊 本波剩余: " + str(zombies_in_wave))
	
	# Boss生成条件（只生成一次）
	if current_kills >= BOSS_KILLS_REQUIRED and not boss_active and not boss_spawned_this_game:
		boss_spawned_this_game = true
		_spawn_boss()
	
	# 波次完成检测
	if zombies_in_wave <= 0 and not boss_active:
		print("")
		print("✅ 第" + str(wave_number) + "波完成！")
		print("📋 等待下一波生成...")
		print("")

func _spawn_boss():
	print("")
	print("👹 Boss生成！")
	# 不播放音效，避免错误
	# if audio_manager:
	# 	audio_manager.play_boss_spawn()
	
	var zombie_scene = load("res://scenes/Zombie.tscn")
	if zombie_scene:
		var boss = zombie_scene.instantiate()
		boss.zombie_type = "boss"
		boss.is_boss = true
		boss.position = Vector2(0, SPAWN_TOP_Y)
		add_child(boss)
		boss_active = true
		print("✅ Boss已生成！血量=" + str(BOSS_HEALTH))
		print("")

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
