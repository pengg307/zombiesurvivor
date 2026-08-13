extends Node2D
class_name EnemySpawner

const SPAWN_INTERVAL = 2.5
# Boss 数量等于关卡号（第1关1个Boss，第2关2个Boss...）
func get_bosses_required() -> int:
	return current_level

# Boss 击杀计数
var bosses_killed_this_level = 0

func add_boss_kill():
	bosses_killed_this_level += 1
	var required = get_bosses_required()
	print("👹 Boss 击杀 " + str(bosses_killed_this_level) + "/" + str(required))
	# 重置生成标志，以便生成下一个Boss
	boss_spawned_this_game = false
	# 检查是否还需要生成更多Boss
	if bosses_killed_this_level < required:
		_spawn_boss()
const SQUARE_SPACING = 100.0
const SCREEN_WIDTH = 720.0
const SCREEN_HEIGHT = 1280.0
const BOSS_HEALTH = 500.0
const SPAWN_TOP_Y = -450.0
const SPAWN_BOTTOM_Y = -350.0
const MAX_WAVES = 10

# 道路透视参数（与Zombie.gd保持一致）
const ROAD_HALF_WIDTH_TOP = 307.0    # 顶部道路半宽
const ROAD_HALF_WIDTH_BOTTOM = 10.0  # 底部道路半宽
const PLAYER_Y_CENTER = 460.0        # 玩家Y位置

# 关卡波次配置 - 根据关卡动态调整
const BASE_WAVE_CONFIG = {
	1: {"zombies": 4, "interval": 2.5, "types": ["basic", "fast"]},
	2: {"zombies": 4, "interval": 2.3, "types": ["basic", "fast"]},
	3: {"zombies": 6, "interval": 2.0, "types": ["basic", "fast", "tank"]},
	4: {"zombies": 6, "interval": 1.8, "types": ["basic", "fast", "tank"]},
	5: {"zombies": 8, "interval": 1.5, "types": ["basic", "fast", "tank", "explorer"]},
	6: {"zombies": 8, "interval": 1.3, "types": ["basic", "fast", "tank", "explorer"]},
	7: {"zombies": 10, "interval": 1.0, "types": ["basic", "fast", "tank", "explorer"]},
	8: {"zombies": 10, "interval": 0.8, "types": ["basic", "fast", "tank", "explorer"]},
	9: {"zombies": 12, "interval": 0.7, "types": ["basic", "fast", "tank", "explorer"]},
	10: {"zombies": 12, "interval": 0.6, "types": ["basic", "fast", "tank", "explorer"]},
	# Level 2+ 额外波次
	11: {"zombies": 14, "interval": 0.6, "types": ["basic", "fast", "tank", "explorer"]},
	12: {"zombies": 14, "interval": 0.5, "types": ["basic", "fast", "tank", "explorer"]},
	13: {"zombies": 16, "interval": 0.5, "types": ["basic", "fast", "tank", "explorer"]},
	14: {"zombies": 16, "interval": 0.4, "types": ["basic", "fast", "tank", "explorer"]},
	15: {"zombies": 18, "interval": 0.4, "types": ["basic", "fast", "tank", "explorer"]},
	# Level 3+ 额外波次
	16: {"zombies": 18, "interval": 0.35, "types": ["basic", "fast", "tank", "explorer"]},
	17: {"zombies": 20, "interval": 0.35, "types": ["basic", "fast", "tank", "explorer"]},
	18: {"zombies": 20, "interval": 0.3, "types": ["basic", "fast", "tank", "explorer"]},
	19: {"zombies": 22, "interval": 0.3, "types": ["basic", "fast", "tank", "explorer"]},
	20: {"zombies": 22, "interval": 0.25, "types": ["basic", "fast", "tank", "explorer"]},
	# Level 4 额外波次
	21: {"zombies": 24, "interval": 0.25, "types": ["basic", "fast", "tank", "explorer"]},
	22: {"zombies": 24, "interval": 0.2, "types": ["basic", "fast", "tank", "explorer"]},
	23: {"zombies": 26, "interval": 0.2, "types": ["basic", "fast", "tank", "explorer"]},
	24: {"zombies": 26, "interval": 0.15, "types": ["basic", "fast", "tank", "explorer"]},
	25: {"zombies": 28, "interval": 0.15, "types": ["basic", "fast", "tank", "explorer"]}
}

const ZOMBIE_WEIGHTS = {
	"basic": 50,
	"fast": 30,
	"tank": 15,
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
var is_game_over = false
var safety_timer = 0.0
var is_safety_mode = true
const SAFETY_TIME = 3.0

# 关卡相关
var current_level = 1
var level_manager = null
	
# 延迟初始化关卡信息
func _on_level_changed(new_level: int):
	current_level = new_level
	print("📊 EnemySpawner 更新关卡到: " + str(current_level))

func _check_level_manager():
	level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		current_level = level_manager.current_level
		print("📊 EnemySpawner 延迟初始化关卡: " + str(current_level))
		level_manager.level_changed.connect(_on_level_changed)

signal boss_spawned
signal game_over_signal
signal game_won
signal wave_complete
signal level_completed

func _ready():
	add_to_group("spawner")
	add_child(spawn_timer)
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# 延迟获取 LevelManager，确保已初始化
	if not level_manager:
		level_manager = get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		current_level = level_manager.current_level
		print("📊 当前关卡: " + str(current_level))
		# 监听关卡变化
		level_manager.level_changed.connect(_on_level_changed)
	
	# 如果 LevelManager 还没就绪，延迟初始化
	if not level_manager:
		var timer = get_tree().create_timer(0.5)
		timer.timeout.connect(_check_level_manager)
	
	print("")
	print("============================================================")
	print("🎮 EnemySpawner启动！")
	print("📍 最大波次: " + str(BASE_WAVE_CONFIG.size()))
	print("👹 Boss 数量: " + str(get_bosses_required()) + " (等于关卡号)")
	print("📐 坐标系: 中心(0,0) = 屏幕(360,640)")
	print("🛣️ 道路透视: 顶部宽=" + str(ROAD_HALF_WIDTH_TOP*2) + " 底部宽=" + str(ROAD_HALF_WIDTH_BOTTOM*2))
	print("⏱️ 安全时间: " + str(SAFETY_TIME) + "秒")
	print("============================================================")

func _process(delta):
	if is_safety_mode and game_started:
		safety_timer += delta
		if safety_timer >= SAFETY_TIME:
			is_safety_mode = false
			print("✅ 安全时间结束，僵尸可以攻击了！")

# 根据Y位置计算道路半宽
func _get_road_half_width(y_pos: float) -> float:
	var t = inverse_lerp(PLAYER_Y_CENTER, SPAWN_TOP_Y, y_pos)
	t = clamp(t, 0.0, 1.0)
	return lerp(ROAD_HALF_WIDTH_BOTTOM, ROAD_HALF_WIDTH_TOP, t)

func _on_spawn_timer_timeout():
	if is_game_over:
		return
	
	var zombies = get_tree().get_nodes_in_group("zombies")
	if zombies.size() == 0:
		all_zombies_dead = true
		print("🎉 所有僵尸已清除！当前波次: " + str(wave_number))
		
		var max_waves = _get_max_waves_for_level()
		# 检查是否完成所有Boss击杀
		var bosses_required = get_bosses_required()
		if current_kills >= bosses_required:
			print("🏆 完成所有" + str(wave_number) + "波！")
			stop()
			if bosses_killed_this_level >= bosses_required:
				_trigger_win()
			return
	
	if wave_number >= _get_max_waves_for_level():
		print("⏹️ 已达到最大波次，停止生成")
		spawn_timer.stop()
		return
	
	var config = BASE_WAVE_CONFIG[min(wave_number + 1, BASE_WAVE_CONFIG.size())]
	if config:
		spawn_timer.wait_time = config.interval * _get_spawn_interval_mult()
		_start_next_wave()

func _start_next_wave():
	wave_number += 1
	wave_active = true
	all_zombies_dead = false
	
	var config = BASE_WAVE_CONFIG[min(wave_number, BASE_WAVE_CONFIG.size())]
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
		# 只有 Zombie.gd 有 zombie_type 变量
		if zombie_type == "boss":
			zombie.is_boss = true
		if zombie_type == "fast":
			zombie.zombie_type = "fast"
		
		# 生成Y位置
		var y_pos = randf_range(SPAWN_TOP_Y, SPAWN_BOTTOM_Y)
		
		# 根据Y位置计算道路宽度，限制生成X在道路范围内
		var half_width = _get_road_half_width(y_pos)
		var x_pos = _get_spawn_x(index, zombies_in_wave, half_width)
		
		zombie.position = Vector2(x_pos, y_pos)
		add_child(zombie)
		
		var screen_x = x_pos + SCREEN_WIDTH / 2.0
		var screen_y = y_pos + SCREEN_HEIGHT / 2.0
		zombie_count += 1
		print("  ✅ 生成" + zombie_type + " #" + str(zombie_count) + " 世界=(" + str(int(x_pos)) + "," + str(int(y_pos)) + ") 屏幕=(" + str(int(screen_x)) + "," + str(int(screen_y)) + ") 道路半宽=" + str(int(half_width)))
	else:
		print("  ❌ 加载僵尸场景失败")

func _get_spawn_x(index, total_count, half_width):
	# 在道路宽度内均匀分布僵尸
	var spacing = (half_width * 2) / (total_count + 1)
	var x = -half_width + (index + 1) * spacing
	return clamp(x, -half_width, half_width)

func add_kill():
	if is_game_over:
		return
	current_kills += 1
	var bosses_required = get_bosses_required()
	print("📊 击杀数: " + str(current_kills) + "/" + str(bosses_required))

	if current_kills >= bosses_required and not boss_spawned_this_game:
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
		# Boss生成在道路中央
		boss.position = Vector2(0, -500)
		add_child(boss)
		print("👹 Boss已生成！位置=(0, -500)")
		emit_signal("boss_spawned")

func _trigger_win():
	if is_game_over:
		return
	is_game_over = true
	print("🏆 玩家胜利！")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.emit_signal("game_won")
	emit_signal("game_won")
	# 触发关卡完成（只在这里触发，避免重复）
	trigger_level_complete()

func start():
	print("🎮 [EnemySpawner] 开始生成！")
	game_started = true
	all_zombies_dead = false
	is_game_over = false
	safety_timer = 0.0
	is_safety_mode = true
	spawn_timer.start()
	print("⏰ Timer已启动，间隔=" + str(spawn_timer.wait_time) + "s")
	print("⏱️ 安全时间: " + str(SAFETY_TIME) + "秒")

func stop():
	print("⏹️ 生成器停止！")
	spawn_timer.stop()
	game_started = false

# 获取当前关卡的最大波次
func _get_max_waves_for_level() -> int:
	var lm = get_tree().get_first_node_in_group("level_manager")
	if not lm:
		return BASE_WAVE_CONFIG.size()
	return lm.get_current_config().max_waves

# 获取关卡生成间隔倍率
func _get_spawn_interval_mult() -> float:
	var lm = get_tree().get_first_node_in_group("level_manager")
	if not lm:
		return 1.0
	return lm.get_current_config().spawn_interval_mult

# 触发关卡完成
func trigger_level_complete():
	# 从 LevelManager 获取正确的关卡号
	var lm = get_tree().get_first_node_in_group("level_manager")
	var level_num = lm.current_level if lm else current_level
	print("🏆 [触发] 关卡 " + str(level_num) + " 完成！")
	if is_game_over:
		print("  ⚠️ 游戏已结束，跳过重复触发")
		return
	is_game_over = true
	if lm:
		lm.complete_level()
		# 自动进入下一关
		if lm.has_next_level():
			var next_level = lm.get_next_level()
			print("  ⏭️ 3秒后自动进入第 " + str(next_level) + " 关")
			var timer = get_tree().create_timer(3.0)
			timer.timeout.connect(_auto_advance_to_next_level.bind(next_level))
	emit_signal("level_completed", level_num)

func _auto_advance_to_next_level(next_level: int):
	print("  🚀 自动进入第 " + str(next_level) + " 关")
	var lm = get_tree().get_first_node_in_group("level_manager")
	if lm:
		lm.start_level(next_level)
		# 重启游戏
		get_tree().reload_current_scene()