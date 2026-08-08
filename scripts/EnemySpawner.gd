extends Node2D
class_name EnemySpawner

const SPAWN_INTERVAL = 3.0
const MAX_ENEMIES = 25
const BOSS_KILLS_REQUIRED = 10
const SQUARE_SPACING = 60.0
const SCREEN_WIDTH = 720.0
const BOSS_HEALTH = 500.0

# 修改：僵尸生成位置更靠近中间（道路中央）
const SPAWN_LEFT_X = -50.0   # 屏幕x=310，更靠近中间
const SPAWN_RIGHT_X = 50.0    # 屏幕x=410，更靠近中间
const SPAWN_Y = -200.0

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
	print("📊 僵尸生成位置 (已调整):")
	print("   - 左侧: 中心x=-50 → 屏幕x=310")
	print("   - 右侧: 中心x=50 → 屏幕x=410")
	print("   - 道路中央: 屏幕x=360")
	print("   - 距离中央: 50像素（更靠近中间）")
	print("📊 僵尸类型分布:")
	print("   - basic: 65% (绿色基础僵尸, 10血, 50速)")
	print("   - fast: 25% (紫色快速僵尸, 8血, 70速)")
	print("   - boss: 击杀10后出现 (红色大僵尸, 250血)")
	print("🛢️ 弹药桶: 50%概率生成，被击中爆炸")
	print("============================================================")
	print("")
	
	start_wave()
	spawn_timer.start()
	_spawn_square()

func _on_spawn_timer_timeout():
	if wave_active and current_kills < BOSS_KILLS_REQUIRED:
		_spawn_square()

func start_wave():
	wave_active = true
	wave_number = 1
	print("")
	print("🌊 第" + str(wave_number) + "波开始！")
	print("")

func _spawn_square():
	print("----------------------------------------")
	print("👾 生成方阵！")
	var size = 1
	var count = 1
	print("📐 方阵大小: " + str(size) + "x" + str(size) + "（共" + str(count) + "个僵尸）")
	
	var start_x: float
	var start_y: float = SPAWN_Y
	var side: String
	var target_x: float = 0.0
	
	if spawn_side == 0:
		start_x = SPAWN_LEFT_X
		side = "左侧"
		print("🎯 左侧生成: x=" + str(int(start_x)) + " → 屏幕x=" + str(int(start_x + 360)))
	else:
		start_x = SPAWN_RIGHT_X
		side = "右侧"
		print("🎯 右侧生成: x=" + str(int(start_x)) + " → 屏幕x=" + str(int(start_x + 360)))
	
	spawn_side = 1 - spawn_side
	
	for row in range(size):
		for col in range(size):
			var zombie_scene = load("res://scripts/Zombie.gd")
			if zombie_scene:
				var zombie_type = _get_random_type()
				var zombie = zombie_scene.new()
				zombie.zombie_type = zombie_type
				var x = start_x + col * SQUARE_SPACING
				var y = start_y + row * SQUARE_SPACING
				zombie.position = Vector2(x, y)
				zombie.target_x = target_x
				zombie.z_index = 100
				zombie.side = side
				add_child(zombie)
				type_log_count[zombie_type] = type_log_count.get(zombie_type, 0) + 1
				print("✅ Zombie创建: 类型=" + zombie_type + " 位置=(centered " + str(int(x)) + "," + str(int(y)) + ") 屏幕=( " + str(int(x + 360)) + "," + str(int(y + 640)) + ")")
	
	print("📊 当前统计: basic=" + str(type_log_count.get("basic", 0)) + 
	      " fast=" + str(type_log_count.get("fast", 0)) + 
	      " boss=" + str(type_log_count.get("boss", 0)))
	
	var barrel_spawned = false
	if randf() < 0.5:
		barrel_spawned = _spawn_ammo_barrel(start_x)
		if barrel_spawned:
			print("🛢️ 弹药桶生成成功！")
	
	print("----------------------------------------")
	print("")

func _get_random_type() -> String:
	var rand = randi() % 100
	var fast_bonus = min(15, current_kills)
	
	var basic_chance = 75 - fast_bonus
	var fast_chance = 25 + fast_bonus
	
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
		boss.position = Vector2(0, SPAWN_Y + 50)
		add_child(boss)
		boss_active = true
		emit_signal("boss_spawned")
		print("✅ Boss已生成！血量=" + str(BOSS_HEALTH))

func get_current_kills() -> int:
	return current_kills

func is_boss_active() -> bool:
	return boss_active

func _spawn_ammo_barrel(start_x: float) -> bool:
	print("🛢️ 生成弹药桶！")
	var barrel_scene = load("res://scripts/AmmoBarrel.gd")
	if barrel_scene:
		var barrel = barrel_scene.new()
		barrel.position = Vector2(start_x, SPAWN_Y + 80)
		barrel.barrel_type = randi() % 3
		barrel.z_index = 50
		add_child(barrel)
		print("✅ 弹药桶生成成功！类型=" + str(barrel.barrel_type) + 
		      " (" + _get_barrel_name(barrel.barrel_type) + ")")
		return true
	else:
		print("❌ 无法加载AmmoBarrel脚本！")
		return false

func _get_barrel_name(type: int) -> String:
	match type:
		0: return "重型机枪(+伤害)"
		1: return "加特林(加速)"
		2: return "散弹枪(范围)"
	return "未知"
