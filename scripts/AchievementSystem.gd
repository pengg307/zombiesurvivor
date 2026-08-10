extends Control
class_name AchievementSystem

var achievements = {}
var total_unlocked = 0

const ACHIEVEMENTS = {
	"first_kill": {"name": "首次击杀", "description": "击杀第一个僵尸", "icon": "🎯", "requirement": 1},
	"ten_kills": {"name": "初出茅庐", "description": "击杀10个僵尸", "icon": "💀", "requirement": 10},
	"five Waves": {"name": "survivor", "description": "存活5波", "icon": "🌊", "requirement": 5},
	"boss_killer": {"name": "Boss杀手", "description": "击杀Boss", "icon": "👹", "requirement": 1},
	"century": {"name": "世纪杀手", "description": "击杀100个僵尸", "icon": "☠️", "requirement": 100},
	"speed_demon": {"name": "速度恶魔", "description": "子弹速度达到2000", "icon": "⚡", "requirement": 2000}
}

func _ready():
	_load_achievements()

func _load_achievements():
	# 从本地存储加载
	var config = ConfigFile.new()
	var err = config.load("user://achievements.cfg")
	if err == OK:
		for key in ACHIEVEMENTS:
			if config.get_value("achievements", key, false):
				achievements[key] = true
				total_unlocked += 1

func check_achievement(type: String, value: int = 0):
	if type in achievements:
		return
	
	var achievement = ACHIEVEMENTS.get(type)
	if not achievement:
		return
	
	var unlocked = false
	match type:
		"first_kill", "ten_kills", "century":
			unlocked = value >= achievement.requirement
		"five_waves":
			unlocked = value >= achievement.requirement
		"boss_killer":
			unlocked = value >= 1
		"speed_demon":
			unlocked = value >= achievement.requirement
	
	if unlocked:
		_achieve(type)

func _achieve(achievement_key):
	achievements[achievement_key] = true
	total_unlocked += 1
	_save_achievements()
	
	var achievement = ACHIEVEMENTS[achievement_key]
	print("🏆 成就解锁: " + achievement.icon + " " + achievement.name)
	print("   " + achievement.description)

func _save_achievements():
	var config = ConfigFile.new()
	for key in achievements:
		config.set_value("achievements", key, true)
	config.save("user://achievements.cfg")

func get_unlocked_count() -> int:
	return total_unlocked

func get_total_count() -> int:
	return ACHIEVEMENTS.size()

func get_achievement_list() -> Array:
	var list = []
	for key in ACHIEVEMENTS:
		list.append({
			"key": key,
			"name": ACHIEVEMENTS[key].name,
			"description": ACHIEVEMENTS[key].description,
			"icon": ACHIEVEMENTS[key].icon,
			"unlocked": key in achievements
		})
	return list
