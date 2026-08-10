extends Node
class_name UpgradeSystem

# 强化选项定义
const UPGRADE_OPTIONS = {
	# 伤害类
	"damage_plus_10": {"name": "伤害+10%", "type": "damage", "value": 0.1, "icon": "⚔️"},
	"damage_plus_20": {"name": "伤害+20%", "type": "damage", "value": 0.2, "icon": "⚔️"},
	"critical_chance": {"name": "暴击率+15%", "type": "critical", "value": 0.15, "icon": "💥"},
	"pierce_shot": {"name": "穿透弹", "type": "pierce", "value": 1, "icon": "🎯"},
	"extra_bullet": {"name": "子弹+1", "type": "bullet_count", "value": 1, "icon": "🔫"},
	
	# 速度类
	"fire_rate_plus": {"name": "射速+10%", "type": "fire_rate", "value": 0.1, "icon": "⚡"},
	"bullet_speed_plus": {"name": "子弹速度+15%", "type": "bullet_speed", "value": 0.15, "icon": "🚀"},
	"move_speed_plus": {"name": "移速+10%", "type": "move_speed", "value": 0.1, "icon": "👟"},
	
	# 生存类
	"max_hp_plus": {"name": "生命上限+20", "type": "max_hp", "value": 20, "icon": "❤️"},
	"regen_hp": {"name": "生命恢复+5/秒", "type": "regen", "value": 5, "icon": "💚"},
	"shield": {"name": "护盾(1次)", "type": "shield", "value": 1, "icon": "🛡️"},
	
	# 特殊类
	"exp_plus": {"name": "经验+25%", "type": "exp", "value": 0.25, "icon": "⭐"},
	"grenade_plus": {"name": "手雷+1", "type": "grenade", "value": 1, "icon": "💣"},
}

var available_options = []
var selected_options = []

func _ready():
	_populate_options()

func _populate_options():
	available_options = []
	for key in UPGRADE_OPTIONS:
		available_options.append(key)

func get_random_options(count: int = 3) -> Array:
	"""获取随机强化选项"""
	var options = []
	var temp_options = available_options.duplicate()
	
	for i in range(min(count, temp_options.size())):
		var random_index = randi() % temp_options.size()
		options.append(temp_options[random_index])
		temp_options.remove_at(random_index)
	
	return options

func apply_upgrade(player, upgrade_key: String) -> void:
	"""应用强化到玩家"""
	if not player or not upgrade_key in UPGRADE_OPTIONS:
		return
	
	var upgrade = UPGRADE_OPTIONS[upgrade_key]
	
	match upgrade.type:
		"damage":
			player.damage_per_shot *= (1.0 + upgrade.value)
		"critical":
			player.critical_chance = upgrade.value
		"pierce":
			player.pierce_shot = true
		"bullet_count":
			player.bullet_count += upgrade.value
		"fire_rate":
			player.base_fire_rate *= (1.0 - upgrade.value)
		"bullet_speed":
			player.bullet_speed *= (1.0 + upgrade.value)
		"move_speed":
			player.MOVE_SPEED *= (1.0 + upgrade.value)
		"max_hp":
			player.MAX_HEALTH += upgrade.value
			player.current_health += upgrade.value
		"regen":
			player.regen_rate = upgrade.value
		"shield":
			player.shield = upgrade.value
		"exp":
			player.exp_multiplier = 1.0 + upgrade.value
		"grenade":
			player.grenades += upgrade.value
	
	selected_options.append(upgrade_key)
	print("✅ 强化已应用: " + upgrade.name)
