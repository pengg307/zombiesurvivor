extends Node2D
class_name EnemySpawner

const SPAWN_INTERVAL = 2.5
const BOSS_KILLS_REQUIRED = 5
const SQUARE_SPACING = 80.0
const SCREEN_WIDTH = 720.0
const BOSS_HEALTH = 500.0
const SPAWN_TOP_Y = -450.0
const SPAWN_BOTTOM_Y = -350.0
const SPAWN_LEFT_X = -360.0
const SPAWN_RIGHT_X = 360.0
const MAX_WAVES = 10

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
var all_zombies_dead = false
var zombie_count = 0
var game_over = false
var safety_timer = 0.0
var is_safety_mode = true
const SAFETY_TIME = 3.0

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
	print("📍 最大波次: " + str(MAX_WAVES))
	print("👹 Boss: 击杀" + str(BOSS_KILLS_REQUIRED) + "后出现")
	print("📐 坐标系: 中心(0,0) = 屏幕(360,640)")
	print("⏱️ 安全时间: " + str(SAFETY_TIME) + "秒")
	print("============================================================")

func _process(delta):
	# 安全时间计时
	if is_safety_mode and game_started:
		safety_timer += delta
		if safety_timer >= SAFETY_TIME:
			is_safety_mode = false
			print("✅ 安全时间结束，僵尸可以攻击了！")

func _on_spawn_timer_timeout():
	# 检查游戏是否结束
	if game_over:
		return
	
	# 检查是否还有僵尸存活
	var zombies = get_tree().get_nodes_in_group("zombies")
	if zombies.size() == 0:
		all_zombies_dead = true
		print("🎉 所有僵尸已清除！当前波次: " + str(wave_number))
		
		# 检查是否达到最大波次
		if wave_number >= MAX_WAVES and not boss_spawned_this_game:
			print("🏆 完成所有" + str(MAX_WAVES) + "波！")
			stop()
			# 检查是否需要生成Boss
			if current_kills >= BOSS_KILLS_REQUIRED:
				_spawn_boss()
			else:
				# 玩家已清除所有僵尸，胜利
				_trigger_win()
			return
	
	# 检查是否还有更多波次
	if wave_number >= MAX_WAVES:
		print("⏹️ 已达到最大波次，停止生成")
		spawn_timer.stop()
		return
	
	var config = WAVE_CONFIG[min(wave_number + 1, WAVE_CONFIG.size())]
	if config:
		spawn_timer.wait_time = config.interval
		_start_next_wave()

func _start_next_wave():
	wave_number += 1
	wave_active = true
	all_zombies_dead = false
	
	var config = WAVE_CONFIG[min(wave_number, WAVE_CONFIG.size())]
	zombies_in_wave = config.zombies
	zombie_count = 0
	
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
		
		var x_pos = _get_spawn_x(index)
		var y_pos = randf_range(SPAWN_TOP_Y, SPAWN_BOTTOM_Y)
		
		zombie.position = Vector2(x_pos, y_pos)
		add_child(zombie)
		
		# 转换为屏幕坐标显示
		var screen_x = x_pos + SCREEN_WIDTH / 2.0
		var screen_y = y_pos + 640.0
		zombie_count += 1
		print("  ✅ 生成" + zombie_type + " #" + str(zombie_count) + " 屏幕=(" + str(int(screen_x)) + "," + str(int(screen_y)) + ")")
	else:
		print("  ❌ 加载僵尸场景失败")

func _get_spawn_x(index):
	# 交替从左右两侧生成
	if spawn_side == 0:
		return SPAWN_LEFT_X + index * SQUARE_SPACING
	else:
		return SPAWN_RIGHT_X + index * SQUARE_SPACING

func add_kill():
	if game_over:
		return
	current_kills += 1
	print("📊 击杀数: " + str(current_kills) + "/" + str(BOSS_KILLS_REQUIRED))
	
	if current_kills >= BOSS_KILLS_REQUIRED and not boss_spawned_this_game:
		_spawn_boss()

func _spawn_boss():
	boss_active = true
	boss_spawned_this_game = true
	print("")
	print("👹 ========================================")
	print("👹 Boss即将出现！")
	print("👹 ========================================")
	
	var boss_scene = load("res://scripts/Zombie.gd")
	if boss_scene:
		var boss = boss_scene.new()
		boss.is_boss = true
		boss.zombie_type = "boss"
		# Boss 从上方生成，距离玩家足够远
		boss.position = Vector2(0, SPAWN_TOP_Y - 100)
		add_child(boss)
		print("👹 Boss已生成！")
		emit_signal("boss_spawned")

func _trigger_win():
	if game_over:
		return
	game_over = true
	print("🏆 玩家胜利！")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.emit_signal("game_won")
	emit_signal("game_won")

func start():
	print("🎮 [EnemySpawner] 开始生成！")
	game_started = true
	all_zombies_dead = false
	game_over = false
	safety_timer = 0.0
	is_safety_mode = true
	spawn_timer.start()
	print("⏰ Timer已启动，间隔=" + str(spawn_timer.wait_time) + "s")
	print("⏱️ 安全时间: " + str(SAFETY_TIME) + "秒")

func stop():
	print("⏹️ 生成器停止！")
	spawn_timer.stop()
	game_started = false
