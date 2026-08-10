extends CharacterBody2D
class_name Zombie

const BASE_HEALTH = 10.0
const BASE_SPEED = 50.0
const FAST_HEALTH = 8.0
const FAST_SPEED = 70.0
const BOSS_HEALTH = 500.0
const BOSS_SPEED = 30.0
const DAMAGE_PER_SECOND = 5.0
const EXPERIENCE_REWARD = 10
const SAFE_DISTANCE = 200.0  # 安全距离（像素）

@export var is_boss: bool = false
var zombie_type = "basic"
var current_health: float
var base_speed: float
var dead = false
var damage_timer = 0.0
var sprite_node: Sprite2D = null
var frame_count = 0
var current_frame = 0
var boss_anim_timer = 0.0
var spawn_screen_pos = Vector2(0, 0)  # 屏幕坐标

signal zombie_reached_player
signal zombie_spawned

func _ready():
	add_to_group("zombies")
	
	_setup_sprite()
	_setup_collision()
	
	# 记录生成时的屏幕位置
	spawn_screen_pos = _to_screen_position()
	
	# 初始化健康值
	if is_boss or zombie_type == "boss":
		current_health = BOSS_HEALTH
		base_speed = BOSS_SPEED
		print("")
		print("👹 Boss已创建！生命值=" + str(current_health) + " 速度=" + str(base_speed))
	else:
		if zombie_type == "fast":
			current_health = FAST_HEALTH
			base_speed = FAST_SPEED
		else:
			current_health = BASE_HEALTH
			base_speed = BASE_SPEED
	
	print("")
	print("============================================================")
	print("✅ Zombie创建: 类型=" + zombie_type + " 健康=" + str(int(current_health)) + " 速度=" + str(int(base_speed)))
	print("   中心坐标=(" + str(int(position.x)) + ", " + str(int(position.y)) + ")")
	print("   屏幕坐标=(" + str(int(spawn_screen_pos.x)) + ", " + str(int(spawn_screen_pos.y)) + ")")
	print("============================================================")
	
	emit_signal("zombie_spawned")

func _setup_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = true
	sprite.z_index = 10
	
	if is_boss or zombie_type == "boss":
		var boss_texture = load("res://assets/downloads/biggerboss.png")
		if boss_texture:
			sprite.texture = boss_texture
			sprite.region_enabled = true
			sprite.region_rect = Rect2(0, 0, 167, 374)
			sprite.scale = Vector2(2.0, 2.0)
			print("🎨 Boss素材加载成功")
		else:
			_setup_fallback_sprite(Color(1, 0, 0), Vector2(2, 2))
	else:
		_setup_fallback_sprite(Color(0, 0.5, 0), Vector2(1, 1))
	
	add_child(sprite)
	sprite_node = sprite

func _setup_fallback_sprite(color: Color, scale: Vector2):
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = true
	sprite.z_index = 10
	var rect = ColorRect.new()
	rect.size = Vector2(64, 64)
	rect.color = color
	sprite.add_child(rect)
	sprite.scale = scale
	add_child(sprite)
	sprite_node = sprite

func _setup_collision():
	var area = Area2D.new()
	area.name = "ZombieArea"
	area.collision_layer = 2
	area.collision_mask = 1
	area.monitoring = true
	area.body_entered.connect(_on_player_detected)
	area.body_exited.connect(_on_player_exited)
	add_child(area)
	
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape"
	var shape = CircleShape2D.new()
	shape.radius = 40.0  # 增大碰撞半径
	collision.shape = shape
	area.add_child(collision)
	
	print("✅ 碰撞体创建成功 (半径=40, 层=" + str(area.collision_layer) + ", 掩码=" + str(area.collision_mask) + ")")

func _to_screen_position() -> Vector2:
	return position + Vector2(360, 640)

func _to_center_position(screen_pos: Vector2) -> Vector2:
	return screen_pos - Vector2(360, 640)

func _on_player_detected(body):
	if body.is_in_group("player") and not dead:
		var player_pos = _to_screen_position() if body.is_in_group("zombies") else body.position
		var dist = position.distance_to(body.position)
		print("💥 Zombie 碰到玩家！类型=" + zombie_type + " 距离=" + str(int(dist)))
		print("   Zombie屏幕位置=(" + str(int(spawn_screen_pos.x)) + ", " + str(int(spawn_screen_pos.y)) + ")")
		print("   玩家屏幕位置=(" + str(int(player_pos.x)) + ", " + str(int(player_pos.y)) + ")")
		
		if not dead:
			dead = true
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.take_damage(999)
			emit_signal("zombie_reached_player")

func _on_player_exited(body):
	if body.is_in_group("player"):
		print("🔓 玩家离开碰撞区域")

func _physics_process(delta):
	if dead:
		return
	
	frame_count += 1
	
	var player_node = get_tree().get_first_node_in_group("player")
	
	if player_node:
		# 计算目标位置
		var target_center_pos = _to_center_position(player_node.position)
		
		var dx = target_center_pos.x - position.x
		var dy = target_center_pos.y - position.y
		var move_dir = Vector2(dx, dy).normalized()
		position += move_dir * base_speed * delta
		
		# 更新屏幕位置
		spawn_screen_pos = _to_screen_position()
		
		# 动画
		var anim_speed = 5 if (!is_boss and zombie_type != "boss") else 8
		if frame_count % anim_speed == 0 and sprite_node and sprite_node.texture and sprite_node.region_enabled and zombie_type != "boss":
			current_frame = (current_frame + 1) % 4
			sprite_node.region_rect = Rect2(current_frame * 64, 0, 64, 64)
		
		# Boss 动画
		if (is_boss or zombie_type == "boss") and sprite_node:
			boss_anim_timer += delta
			var pulse = 1.0 + 0.1 * sin(boss_anim_timer * 3.0)
			sprite_node.scale = Vector2(2.0, 2.0) * pulse
			if frame_count % 8 == 0:
				var frame = (current_frame % 4) * 167
				sprite_node.region_rect = Rect2(frame, 0, 167, 374)
	
	# Boss 伤害检测
	if (is_boss or zombie_type == "boss") and player_node:
		damage_timer += delta
		if damage_timer >= 1.0:
			damage_timer = 0.0
			var player_health = player_node.current_health if player_node.has_method("take_damage") else 100
			if player_health > 0:
				player_node.take_damage(DAMAGE_PER_SECOND)
				print("💥 Boss攻击玩家！伤害=" + str(DAMAGE_PER_SECOND))

func take_damage(damage: float):
	if dead:
		return
	
	current_health -= damage
	print("💥 Zombie受伤: 类型=" + zombie_type + " 健康=" + str(int(current_health)) + "/" + str(int(get_max_health())))
	
	if current_health <= 0:
		_die()

func get_max_health() -> float:
	if is_boss or zombie_type == "boss":
		return BOSS_HEALTH
	elif zombie_type == "fast":
		return FAST_HEALTH
	else:
		return BASE_HEALTH

func _die():
	if dead:
		return
	dead = true
	
	var player = get_tree().get_first_node_in_group("player")
	var spawner = get_tree().get_first_node_in_group("spawner")
	var audio = get_tree().get_first_node_in_group("audio_manager")
	var stats_mgr = get_tree().get_first_node_in_group("stats_manager")
	
	if audio:
		audio.play_explode()
	
	if player:
		player.add_experience(EXPERIENCE_REWARD)
		player.add_kill()
		print("💀 Zombie死亡: 类型=" + zombie_type + " 玩家击杀数=" + str(player.kills))
	
	if spawner:
		spawner.add_kill()
		print("📊 Spawner击杀数: " + str(spawner.current_kills) + "/" + str(spawner.BOSS_KILLS_REQUIRED))
	
	if is_boss or zombie_type == "boss":
		emit_signal("boss_died")
		if player:
			player.emit_signal("game_won")
		if stats_mgr:
			stats_mgr.add_kill(true)
	
	if stats_mgr:
		stats_mgr.add_kill(false)
	
	print("💀 Zombie死亡！获得经验:" + str(EXPERIENCE_REWARD))
	queue_free()
