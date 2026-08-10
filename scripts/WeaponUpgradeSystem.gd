extends Node
class_name WeaponUpgradeSystem

const WEAPON_TREE = {
	"pistol": {
		"name": "手枪",
		"level": 1,
		"max_level": 5,
		"upgrades": {
			1: {"damage": 10, "fire_rate": 0.3, "bullet_speed": 600, "bullet_count": 1},
			2: {"damage": 12, "fire_rate": 0.28, "bullet_speed": 650, "bullet_count": 1},
			3: {"damage": 15, "fire_rate": 0.25, "bullet_speed": 700, "bullet_count": 2},
			4: {"damage": 18, "fire_rate": 0.22, "bullet_speed": 750, "bullet_count": 2},
			5: {"damage": 25, "fire_rate": 0.18, "bullet_speed": 800, "bullet_count": 3}
		}
	},
	"shotgun": {
		"name": "霰弹枪",
		"level": 0,
		"max_level": 5,
		"unlocked": false,
		"unlock_cost": 50,
		"upgrades": {
			1: {"damage": 8, "fire_rate": 0.6, "bullet_speed": 500, "bullet_count": 3},
			2: {"damage": 10, "fire_rate": 0.55, "bullet_speed": 550, "bullet_count": 4},
			3: {"damage": 13, "fire_rate": 0.5, "bullet_speed": 600, "bullet_count": 5},
			4: {"damage": 16, "fire_rate": 0.45, "bullet_speed": 650, "bullet_count": 6},
			5: {"damage": 20, "fire_rate": 0.4, "bullet_speed": 700, "bullet_count": 7}
		}
	},
	"rifle": {
		"name": "步枪",
		"level": 0,
		"max_level": 5,
		"unlocked": false,
		"unlock_cost": 100,
		"upgrades": {
			1: {"damage": 20, "fire_rate": 0.2, "bullet_speed": 900, "bullet_count": 1},
			2: {"damage": 25, "fire_rate": 0.18, "bullet_speed": 950, "bullet_count": 1},
			3: {"damage": 30, "fire_rate": 0.16, "bullet_speed": 1000, "bullet_count": 1},
			4: {"damage": 38, "fire_rate": 0.14, "bullet_speed": 1100, "bullet_count": 1},
			5: {"damage": 50, "fire_rate": 0.12, "bullet_speed": 1200, "bullet_count": 1}
		}
	}
}

var current_weapon = "pistol"
var weapon_stats = {}

func _ready():
	add_to_group("weapon_upgrade_system")
	_initialize_stats()
	print("⚔️ WeaponUpgradeSystem启动")

func _initialize_stats():
	for weapon_name in WEAPON_TREE:
		if WEAPON_TREE[weapon_name].unlocked or weapon_name == "pistol":
			var level = WEAPON_TREE[weapon_name].level
			if level > 0 and level in WEAPON_TREE[weapon_name].upgrades:
				weapon_stats[weapon_name] = WEAPON_TREE[weapon_name].upgrades[level].duplicate()
			else:
				weapon_stats[weapon_name] = {"damage": 10, "fire_rate": 0.3, "bullet_speed": 600, "bullet_count": 1}

func add_kills(count: int):
	# 可以添加击杀解锁武器等逻辑
	pass

func get_current_stats() -> Dictionary:
	return weapon_stats.get(current_weapon, {"damage": 10, "fire_rate": 0.3, "bullet_speed": 600, "bullet_count": 1})

func upgrade_weapon() -> bool:
	var weapon = WEAPON_TREE.get(current_weapon)
	if not weapon:
		return false
	
	var level = weapon.level
	if level >= weapon.max_level:
		print("⚠️ 武器已达最高等级")
		return false
	
	weapon.level += 1
	weapon_stats[current_weapon] = weapon.upgrades[weapon.level].duplicate()
	print("⬆️ " + weapon.name + " 升级到等级 " + str(weapon.level))
	return true

func unlock_weapon(weapon_name: String) -> bool:
	var weapon = WEAPON_TREE.get(weapon_name)
	if not weapon or weapon.unlocked:
		return false
	
	if weapon.unlock_cost <= 0:
		weapon.unlocked = true
		weapon.level = 1
		weapon_stats[weapon_name] = weapon.upgrades[1].duplicate()
		print("🔓 解锁武器: " + weapon.name)
		return true
	
	return false

func switch_weapon(weapon_name: String) -> bool:
	if not WEAPON_TREE.has(weapon_name):
		return false
	if not WEAPON_TREE[weapon_name].unlocked and weapon_name != "pistol":
		return false
	
	current_weapon = weapon_name
	print("🔄 切换武器: " + WEAPON_TREE[weapon_name].name)
	return true

func apply_to_player(player):
	var stats = get_current_stats()
	if player:
		player.damage_per_shot = stats.damage
		player.fire_rate = stats.fire_rate
		player.bullet_speed = stats.bullet_speed
		player.bullet_count = stats.bullet_count
