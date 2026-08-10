extends Node
class_name WeaponUpgradeSystem

# 武器升级树定义
const WEAPON_TREE = {
	"pistol": {
		"name": "手枪",
		"level": 1,
		"max_level": 5,
		"upgrades": {
			1: {"damage": 10, "fire_rate": 0.3, "bullet_speed": 600},
			2: {"damage": 15, "fire_rate": 0.25, "bullet_speed": 650},
			3: {"damage": 20, "fire_rate": 0.2, "bullet_speed": 700},
			4: {"damage": 28, "fire_rate": 0.15, "bullet_speed": 750},
			5: {"damage": 35, "fire_rate": 0.12, "bullet_speed": 800}
		}
	},
	"shotgun": {
		"name": "霰弹枪",
		"level": 0,
		"max_level": 3,
		"unlock_cost": 50,  # 需要50击杀解锁
		"upgrades": {
			1: {"damage": 8, "fire_rate": 0.8, "bullet_speed": 400, "bullet_count": 3},
			2: {"damage": 12, "fire_rate": 0.6, "bullet_speed": 450, "bullet_count": 5},
			3: {"damage": 18, "fire_rate": 0.5, "bullet_speed": 500, "bullet_count": 7}
		}
	},
	"rifle": {
		"name": "步枪",
		"level": 0,
		"max_level": 3,
		"unlock_cost": 100,
		"upgrades": {
			1: {"damage": 25, "fire_rate": 0.4, "bullet_speed": 900},
			2: {"damage": 35, "fire_rate": 0.3, "bullet_speed": 1000},
			3: {"damage": 50, "fire_rate": 0.2, "bullet_speed": 1100}
		}
	}
}

var current_weapons = {}
var total_kills = 0

func _ready():
	_init_weapons()

func _init_weapons():
	for weapon_key in WEAPON_TREE:
		current_weapons[weapon_key] = WEAPON_TREE[weapon_key].duplicate(true)

func add_kills(count: int):
	total_kills += count
	_check_unlocks()

func _check_unlocks():
	for weapon_key in current_weapons:
		var weapon = current_weapons[weapon_key]
		if weapon.level == 0 and weapon.has("unlock_cost"):
			if total_kills >= weapon.unlock_cost:
				weapon.level = 1
				print("🔓 解锁新武器: " + weapon.name)

func upgrade_weapon(player, weapon_key: String) -> bool:
	if not weapon_key in current_weapons:
		return false
	
	var weapon = current_weapons[weapon_key]
	if weapon.level >= weapon.max_level:
		return false
	
	weapon.level += 1
	_apply_weapon_stats(player, weapon)
	print("⬆️ 升级武器: " + weapon.name + " Lv." + str(weapon.level))
	return true

func _apply_weapon_stats(player, weapon):
	var stats = weapon.upgrades[weapon.level]
	player.damage_per_shot = stats.damage
	player.base_fire_rate = stats.fire_rate
	player.bullet_speed = stats.bullet_speed
	if stats.has("bullet_count"):
		player.bullet_count = stats.bullet_count

func get_available_upgrades(player) -> Array:
	var options = []
	for weapon_key in current_weapons:
		var weapon = current_weapons[weapon_key]
		if weapon.level == 0:
			options.append({"type": "unlock", "key": weapon_key, "name": "解锁" + weapon.name})
		elif weapon.level < weapon.max_level:
			options.append({"type": "upgrade", "key": weapon_key, "name": weapon.name + " Lv." + str(weapon.level + 1)})
	return options
