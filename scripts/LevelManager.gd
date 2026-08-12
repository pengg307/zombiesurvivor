extends Node
class_name LevelManager

# 关卡配置
const LEVEL_CONFIG = {
	1: {
		"name": "新手村",
		"max_waves": 10,
		"boss_health_mult": 1.0,
		"zombie_health_mult": 1.0,
		"zombie_speed_mult": 1.0,
		"spawn_interval_mult": 1.0,
		"description": "10波僵尸，基础难度"
	},
	2: {
		"name": "危险地带",
		"max_waves": 15,
		"boss_health_mult": 1.5,
		"zombie_health_mult": 1.2,
		"zombie_speed_mult": 1.1,
		"spawn_interval_mult": 0.9,
		"description": "15波僵尸，敌人更强更快"
	},
	3: {
		"name": "死亡沙漠",
		"max_waves": 20,
		"boss_health_mult": 2.0,
		"zombie_health_mult": 1.5,
		"zombie_speed_mult": 1.2,
		"spawn_interval_mult": 0.8,
		"description": "20波僵尸，Boss血量翻倍"
	},
	4: {
		"name": "地狱挑战",
		"max_waves": 25,
		"boss_health_mult": 3.0,
		"zombie_health_mult": 2.0,
		"zombie_speed_mult": 1.3,
		"spawn_interval_mult": 0.7,
		"description": "25波僵尸，终极挑战"
	}
}

var current_level = 1
var max_unlocked_level = 1
var total_kills = 0
var total_damage_dealt = 0.0

signal level_started(level: int)
signal level_completed(level: int)
signal level_changed(new_level: int)

func _ready():
	add_to_group("level_manager")
	print("📊 LevelManager 初始化完成")
	print("   最高解锁关卡: " + str(max_unlocked_level))

func get_current_config() -> Dictionary:
	return LEVEL_CONFIG.get(current_level, LEVEL_CONFIG[1])

func has_next_level() -> bool:
	return current_level < LEVEL_CONFIG.size()

func get_next_level() -> int:
	return current_level + 1

func can_enter_level(level: int) -> bool:
	return level <= max_unlocked_level and level in LEVEL_CONFIG

func start_level(level: int):
	if not can_enter_level(level):
		print("❌ 无法进入关卡 " + str(level) + " (未解锁)")
		return
	
	current_level = level
	max_unlocked_level = max(max_unlocked_level, level)
	
	print("🎮 开始第 " + str(level) + " 关: " + LEVEL_CONFIG[level]["name"])
	print("   " + LEVEL_CONFIG[level]["description"])
	
	emit_signal("level_started", level)
	emit_signal("level_changed", level)

func complete_level():
	print("🏆 关卡 " + str(current_level) + " 完成！")
	emit_signal("level_completed", current_level)
	
	# 解锁下一关
	if has_next_level():
		var next = get_next_level()
		max_unlocked_level = max(max_unlocked_level, next)
		print("   解锁第 " + str(next) + " 关！")

func add_kill():
	total_kills += 1

func add_damage(damage: float):
	total_damage_dealt += damage

func get_level_names() -> Array:
	var names = []
	for level in LEVEL_CONFIG:
		names.append({
			"level": level,
			"name": LEVEL_CONFIG[level]["name"],
			"unlocked": level <= max_unlocked_level
		})
	return names

func reset_progress():
	total_kills = 0
	total_damage_dealt = 0.0
	max_unlocked_level = 1
	current_level = 1
	print("🔄 游戏进度已重置")