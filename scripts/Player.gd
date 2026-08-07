extends CharacterBody2D

const MOVE_SPEED = 250.0
const MAX_HEALTH = 100.0
const BASE_Y = 1100.0
const FIRE_RATE_BASE = 0.3
const SHOT_RANGE = 1200.0

var current_health = MAX_HEALTH
var level = 1
var experience = 0
var kills = 0
var move_direction = Vector2.ZERO
var attack_timer = 0.0
var fire_rate = FIRE_RATE_BASE
var bullet_speed = 600.0
var kills_for_speed = 0
var sprite_node: Sprite2D = null
var walk_timer = 0.0
var triple_shot_unlocked = false
var ammo_boost_level = 0  # 弹药桶增强等级
var ammo_boost_timer = 0.0  # 增强持续时间计时器

signal kill_count_changed
signal ammo_boost_applied(level: int)

func _ready():
	# 玩家位置固定在屏幕底部中央
	position = Vector2(360, BASE_Y)
	# 设置碰撞层（layer 2 = 1<<1）
	collision_layer = 2
	collision_mask = 1  # 检测 ammo_barrels (layer 1)
	# 添加碰撞形状
	_setup_collision()
	_setup_character()
	# 添加坐标标签
	_add_position_label()
	print("✅ Player创建成功 - 位置:", position)

func _setup_collision():
	# 添加碰撞形状用于检测弹药桶
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 25.0
	shape.height = 50.0
	collision.shape = shape
	add_child(collision)

func _add_position_label():
	# 添加坐标标签显示玩家位置（放在玩家底部）
	var label = Label.new()
	label.name = "PositionLabel"
	label.text = "Player(360,1100)"
	label.add_theme_font_size_override("font_size", 14)
	label.modulate = Color(1, 1, 0.3)  # 亮黄色
	label.position = Vector2(-30, 30)  # 改为下方
	add_child(label)
	print("📍 Player坐标标签已添加")

func _setup_character():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	
	# 使用下载的玩家素材
	var texture = load("res://assets/downloads/player_back_run.png")
	if texture:
		sprite.texture = texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 256, 64)
		# 缩小到1/5
		sprite.scale = Vector2(0.5, 0.5)
		add_child(sprite)
		sprite_node = sprite
		print("🎨 玩家素材加载成功，已缩小到0.5倍")
	else:
		print("❌ 无法加载玩家素材，使用默认矩形")
		var rect = ColorRect.new()
		rect.size = Vector2(50, 70)
		rect.color = Color(0.2, 0.4, 0.8)
		sprite.add_child(rect)
		add_child(sprite)
		sprite_node = sprite

func _process(delta):
	# 更新弹药桶增强计时器
	if ammo_boost_timer > 0:
		ammo_boost_timer -= delta
		if ammo_boost_timer <= 0:
			print("⏰ 弹药桶增强效果结束")
			ammo_boost_level = 0
	
	attack_timer -= delta
	if attack_timer <= 0:
		_attack()
		attack_timer = fire_rate

func _physics_process(delta):
	walk_timer += delta
	move_direction.y = 0
	velocity.x = move_direction.x * MOVE_SPEED
	move_and_slide()
	
	# 玩家固定在屏幕底部
	position.x = clamp(position.x, 32, 688)
	position.y = BASE_Y
	
	# 更新动态坐标标签
	if has_node("PositionLabel"):
		$PositionLabel.text = "Player(" + str(int(position.x)) + ",1100)"
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_direction.x = -1
		if has_node("Sprite") and sprite_node:
			var frame = int(walk_timer * 5) % 4
			sprite_node.region_rect = Rect2(frame * 256, 0, 256, 64)
	elif Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_direction.x = 1
		if has_node("Sprite") and sprite_node:
			var frame = int(walk_timer * 5) % 4
			sprite_node.region_rect = Rect2(frame * 256, 0, 256, 64)
	else:
		move_direction.x = 0
		if has_node("Sprite") and sprite_node:
			sprite_node.region_rect = Rect2(0, 0, 256, 64)

func _attack():
	var enemies = get_tree().get_nodes_in_group("zombies")
	print("🔍 扫描敌人 - 数量:", enemies.size())
	
	if enemies.size() > 0:
		var nearest = _find_nearest_enemy(enemies)
		if nearest:
			var dist = position.distance_to(nearest.position)
			print("🎯 最近敌人距离:", int(dist), "射程:", SHOT_RANGE)
			
			if dist <= SHOT_RANGE:
				# 检查是否解锁三发子弹
				if triple_shot_unlocked:
					_spawn_triple_bullet(nearest.position)
					print("🔫 发射三发子弹！")
				else:
					_spawn_bullet(nearest.position, Vector2(0, -1))
					print("🔫 发射一发子弹！")
		else:
			print("❌ 找不到最近敌人")
	else:
		print("⚠️ 没有敌人")

func _find_nearest_enemy(enemies):
	var nearest = null
	var nearest_dist = SHOT_RANGE
	
	for enemy in enemies:
		var dist = position.distance_to(enemy.position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	
	return nearest

func _spawn_triple_bullet(target_pos: Vector2):
	# 中央子弹
	_spawn_bullet(target_pos, Vector2(0, -1))
	
	# 左子弹（向左偏2度）
	_spawn_bullet(target_pos, Vector2(-0.035, -1))
	
	# 右子弹（向右偏2度）
	_spawn_bullet(target_pos, Vector2(0.035, -1))

func _spawn_bullet(target_pos: Vector2, direction: Vector2):
	var bullet = load("res://scripts/Bullet.gd").new()
	bullet.position = position
	bullet.position.y -= 50
	bullet.direction = direction.normalized()
	bullet.damage = 10.0 + ammo_boost_level * 5  # 根据弹药桶增强伤害
	bullet.current_speed = bullet_speed
	bullet.kills_for_speed = kills
	
	get_parent().add_child(bullet)
	print("✅ 子弹发射！伤害:", bullet.damage)

func apply_ammo_boost(type: int):
	# 根据油桶类型给予不同的增强
	match type:
		0:  # 重型机枪
			ammo_boost_level = 1
			ammo_boost_timer = 15.0  # 持续15秒
			print("🎯 获得重型机枪增强！伤害+5，持续15秒")
		1:  # 加特林
			ammo_boost_level = 2
			ammo_boost_timer = 10.0  # 持续10秒
			fire_rate = 0.15  # 射速加倍
			print("🎯 获得加特林增强！射速加倍，持续10秒")
		2:  # 散弹枪
			ammo_boost_level = 3
			ammo_boost_timer = 8.0  # 持续8秒
			print("🎯 获得散弹枪增强！范围伤害，持续8秒")
	
	emit_signal("ammo_boost_applied", ammo_boost_level)

func take_damage(damage: float):
	current_health = max(0, current_health - damage)
	print("💥 玩家受伤！血量:", current_health)

func add_experience(amount: int):
	experience += amount

func add_kill():
	kills += 1
	kills_for_speed = kills
	
	# 每10个击杀增加子弹速度
	if kills % 10 == 0:
		bullet_speed += 100
		print("⚡ 子弹速度提升！当前速度:", bullet_speed)
	
	# 击杀5个后解锁三发子弹
	if kills == 5 and not triple_shot_unlocked:
		triple_shot_unlocked = true
		print("🎯 解锁三发子弹模式！")
	
	emit_signal("kill_count_changed")
	print("💀 击杀数:", kills)
