extends Node2D
class_name EnemySpawner

const SPAWN_INTERVAL = 2.5
const BOSS_KILLS_REQUIRED = 5
const SQUARE_SPACING = 80.0
const SCREEN_WIDTH = 720.0
const BOSS_HEALTH = 500.0
const SPAWN_TOP_Y = -450.0  # 更远的生成位置
const SPAWN_BOTTOM_Y = -350.0
const SPAWN_LEFT_X = -360.0
const SPAWN_RIGHT_X = 360.0

const WAVE_CONFIG = {
	1: {"zombies": 4, "interval": 2.5, "types": ["basic", "fast"]},
	2: {"zombies": 4, "interval": 2.3, "types": ["basic", "fast"]},
	3: {"zombies": 6, "interval": 2.0, "types": ["basic", "fast", "tank"]},
	4: {"zombies": 6, "interval": 1.8, "types": ["basic", "fast", "tank"]},
	5: {"zombies": 8, "interval": 1.5, "types": ["basic", "fast", "tank", "explorer"]},
	6: {"zombies": 8, "interval": 1.3, "types": ["basic", "fast", "tank", "explorer"]},
	7: {"zombies": 10, "interval": 1.0, "types": ["basic", "fast", "tank", "explorer"]},
	8: {"zombies": 10, "interval": 0.8, "types": ["basic", "fast", "tank", "explorer"]},
	9: {"zombies": 12, "interval": 0.7, "types": ["basic", "fast", "tank", "explorer"]},
	10: {"zombies": 12, "interval": 0.6, "types": ["basic", "fast", "tank", "explorer"]}
}

const ZOMBIE_WEIGHTS = {
	"basic": 65,
	"fast": 35,
	"tank": 10,
	"explorer": 5
}

var spawn_timer = Timer.new()
var wave_active = false
var current_kills = 0
var boss_active = false
var boss_spawned_this_game = false
var wave_number = 0
var spawn_side = 0
var zombies_in_wave = 0
var game_started = false

signal boss_spawned
signal game_over
signal game_won
signal wave_complete

func _ready():
	add_to_group("spawner")
	add_child(spawn_timer)
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	print("")
	print("============================================================")
	print("🎮 EnemySpawner启动！")
	print("============================================================")
	print("📍 生成范围: X=" + str(SPAWN_LEFT_X) + "~" + str(SPAWN_RIGHT_X) + " Y=" + str(SPAWN_TOP_Y) + "~" + str(SPAWN_BOTTOM_Y))
	print("👹 Boss: 击杀" + str(BOSS_KILLS_REQUIRED) + "后出现")
	print("============================================================")

func _on_spawn_timer_timeout():
	var config = WAVE_CONFIG[min(wave_number + 1, WAVE_CONFIG.size())]
	if config:
		spawn_timer.wait_time = config.interval
		_start_next_wave()

func _start_next_wave():
	wave_number += 1
	wave_active = true
	
	var config = WAVE_CONFIG[min(wave_number, WAVE_CONFIG.size())]
	zombies_in_wave = config.zombies
	
	print("")
	print("🌊 第" + str(wave_number) + "波开始！生成" + str(zombies_in_wave) + "个僵尸")
	
	_spawn_matrix(config)

func _spawn_matrix(config):
	for i in range(zombies_in_wave):
		_spawn_zombie(i, config)
	spawn_side = 1 - spawn_side

func _spawn_zombie(index, config):
	var zombie_scene
	var zombie_type
	
	var rand_val = randi() % 100
	var cumulative = 0
	var available_types = config.types if config else ["basic", "fast"]
	
	for type_name in available_types:
		cumulative += ZOMBIE_WEIGHTS.get(type_name, 0)
		if rand_val < cumulative:
			zombie_type = type_name
			break
		else:
			zombie_type = "basic"
	
	match zombie_type:
		"basic":
			zombie_scene = load("res://scripts/Zombie.gd")
		"fast":
			zombie_scene = load("res://scripts/Zombie.gd")
		"tank":
			zombie_scene = load("res://scripts/TankZombie.gd")
		"explorer":
			zombie_scene = load("res://scripts/ExplorerZombie.gd")
		_:
			zombie_scene = load("res://scripts/Zombie.gd")
	
	if zombie_scene:
		var zombie = zombie_scene.new()
		zombie.zombie_type = zombie_type
		
		# 使用正确的中心坐标系统生成僵尸
		var x_pos = SPAWN_LEFT_X + index * SQUARE_SPACING if spawn_side == 0 else SPAWN_RIGHT_X + index * SQUARE_SPACING
		var y_pos = randf_range(SPAWN_TOP_Y, SPAWN_BOTTOM_Y)
		
		zombie.position = Vector2(x_pos, y_pos)
		add_child(zombie)
		
		# 计算屏幕位置用于调试
		var screen_x = x_pos + 360
		var screen_y = y_pos + 640
		print("  ✅ 生成" + zombie_type + "僵尸 #" + str(index + 1) + " 中心=(" + str(int(x_pos)) + "," + str(int(y_pos)) + ") 屏幕=(" + str(int(screen_x)) + "," + str(int(screen_y)) + ")")
	else:
		print("  ❌ 加载僵尸场景失败")

func add_kill():
	current_kills += 1
	print("📊 击杀数: " + str(current_kills) + "/" + str(BOSS_KILLS_REQUIRED))
	
	if current_kills >= BOSS_KILLS_REQUIRED and not boss_spawned_this_game:
		_spawn_boss()

func _spawn_boss():
	boss_active = true
	boss_spawned_this_game = true
	print("")
	print("👹 Boss即将出现！")
	
	var boss_scene = load("res://scripts/Zombie.gd")
	if boss_scene:
		var boss = boss_scene.new()
		boss.is_boss = true
		boss.zombie_type = "boss"
		boss.position = Vector2(0, SPAWN_TOP_Y - 100)
		add_child(boss)
		print("👹 Boss已生成！")
		emit_signal("boss_spawned")

func start():
	print("🎮 [EnemySpawner] 开始生成！")
	game_started = true
	spawn_timer.start()

func stop():
	print("⏹️ 生成器停止！")
	spawn_timer.stop()
	game_started = false
