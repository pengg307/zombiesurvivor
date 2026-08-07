extends Node2D
class_name Weapon

# 武器基类
signal fired(bullet_scene: PackedScene, position: Vector2, direction: Vector2)

var weapon_type: String = "pistol"
var damage: float = 10.0
var fire_rate: float = 0.5
var range: float = 400.0
var bullet_speed: float = 500.0
var bullet_scene: PackedScene

var current_cooldown: float = 0.0

func _init(type: String, level: float = 1.0):
	weapon_type = type
	_setup_weapon(level)

func _setup_weapon(level: float) -> void:
	match weapon_type:
		"pistol":
			damage = 15.0 * level
			fire_rate = 0.5
			bullet_speed = 400.0
		"shotgun":
			damage = 10.0 * level
			fire_rate = 1.0
			bullet_speed = 350.0
		"rifle":
			damage = 25.0 * level
			fire_rate = 0.3
			bullet_speed = 600.0
		"laser":
			damage = 5.0 * level
			fire_rate = 0.1
			bullet_speed = 800.0

func attack() -> void:
	if current_cooldown > 0:
		return
	
	# 寻找最近敌人
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		var direction = (nearest_enemy.position - position).normalized()
		_spawn_bullet(direction)
		current_cooldown = fire_rate

func _spawn_bullet(direction: Vector2) -> void:
	# 创建子弹节点
	var bullet = Node2D.new()
	bullet.position = position
	bullet.name = "Bullet"
	
	# 发射信号
	emit_signal("fired", bullet, position, direction)

func find_nearest_enemy() -> Node2D:
	var nearest = null
	var nearest_distance = range
	
	# 查找场景中的所有僵尸
	var zombies = get_tree().get_nodes_in_group("zombies")
	for zombie in zombies:
		var distance = position.distance_to(zombie.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = zombie
	
	return nearest

func upgrade(level: int) -> void:
	match weapon_type:
		"pistol":
			damage = 15.0 * (1 + level * 0.2)
			fire_rate = max(0.2, 0.5 - level * 0.02)
		"shotgun":
			damage = 10.0 * (1 + level * 0.25)
			fire_rate = max(0.5, 1.0 - level * 0.03)
		"rifle":
			damage = 25.0 * (1 + level * 0.15)
			fire_rate = max(0.15, 0.3 - level * 0.01)
		"laser":
			damage = 5.0 * (1 + level * 0.3)
			fire_rate = max(0.05, 0.1 - level * 0.005)

func _process(delta: float) -> void:
	if current_cooldown > 0:
		current_cooldown -= delta
