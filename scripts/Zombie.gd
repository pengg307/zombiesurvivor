extends CharacterBody2D
class_name Zombie

const BASE_HEALTH = 10.0
const BASE_SPEED = 50.0
const FAST_HEALTH = 8.0
const FAST_SPEED = 70.0
const BOSS_HEALTH = 500.0
const BOSS_SPEED = 30.0
const DAMAGE = 10.0
const COLLISION_RADIUS = 50.0
const EXPERIENCE_REWARD = 10
const SAFETY_TIME = 2.0  # 安全时间（秒）

var zombie_type = "basic"
var is_boss = false
var current_health = BASE_HEALTH
var speed = BASE_SPEED
var dead = false
var can_attack = false
var player_node = null
var player_area = null
var bullet_area = null
var sprite: Sprite2D
var health_bar_fg: ColorRect
var zombie_kills = 0  # 该僵尸击杀数

signal zombie_died
signal boss_died
signal zombie_reached_player

func _ready():
	add_to_group("zombies")
	_setup_sprite()
	_setup_collision()
	_setup_health_bar()
	
	current_health = get_max_health()
	speed = get_speed()
	
	print("✅ Zombie创建: 类型=" + zombie_type + " 健康=" + str(int(current_health)))

func _setup_sprite():
	if zombie_type == "boss" or is_boss:
		# Boss使用bigboss.png
		sprite = Sprite2D.new()
		var boss_texture = load("res://assets/downloads/bigboss.png")
		if boss_texture:
			sprite.texture = boss_texture
			sprite.scale = Vector2(2, 2)
		add_child(sprite)
		position = Vector2(0, -300)
	else:
		# 普通僵尸使用zombie_front_4frames_game.png
		sprite = Sprite2D.new()
		var texture = load("res://assets/downloads/zombie_front_4frames_game.png")
		if texture:
			sprite.texture = texture
			sprite.scale = Vector2(2, 2)
			sprite.centered = true
		add_child(sprite)

func _setup_collision():
	# 创建碰撞体 - 使用更加可靠的检测方法
	player_area = Area2D.new()
	player_area.name = "PlayerArea"
	player_area.collision_layer = 2  # 检测玩家
	player_area.collision_mask = 1
	player_area.body_entered.connect(_on_player_detected)
	add_child(player_area)
	
	var player_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = COLLISION_RADIUS
	player_shape.shape = circle
	player_area.add_child(player_shape)
	
	# 创建子弹检测区域
	bullet_area = Area2D.new()
	bullet_area.name = "BulletArea"
	bullet_area.collision_layer = 0  # 不检测任何层
	bullet_area.collision_mask = 4   # 检测子弹层
	bullet_area.area_entered.connect(_on_bullet_area_entered)
	add_child(bullet_area)
	
	var bullet_shape = CollisionShape2D.new()
	var circle2 = CircleShape2D.new()
	circle2.radius = 20
	bullet_shape.shape = circle2
	bullet_area.add_child(bullet_shape)
	
	print("  ✅ 碰撞体创建成功 (检测玩家层=2, 子弹层=4)")

func _on_player_detected(body):
	# 只有当僵尸还活着且可以攻击时才检测
	if body.is_in_group("player") and not dead and can_attack:
		var player_pos = body.position + Vector2(360, 640)  # 转换为世界坐标
		var dist = position.distance_to(player_pos)
		if dist <= COLLISION_RADIUS:
			# 立即禁用碰撞，防止多次触发
			_disable_collision()
			dead = true  # 僵尸碰到玩家后也标记为死亡
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.take_damage(999)
			print("💀 僵尸碰到玩家！距离=" + str(int(dist)))

func _on_bullet_area_entered(area):
	if area.is_in_group("bullets") and not dead:
		var bullet = area as Bullet
		if bullet:
			var final_damage = bullet.damage
			var is_critical = randf() < 0.15
			if is_critical:
				final_damage *= 2.0
			take_damage(final_damage)
			_show_damage_number(final_damage, is_critical)
			if not bullet.is_pierce:
				bullet.queue_free()

func _disable_collision():
	if player_area:
		player_area.monitoring = false
		player_area.monitorable = false
	if bullet_area:
		bullet_area.monitoring = false
		bullet_area.monitorable = false

func _physics_process(delta):
	if dead:
		return
	
	# 移动逻辑
	var target = get_tree().get_first_node_in_group("player")
	if target:
		var target_pos = target.position + Vector2(360, 640)  # 转换为世界坐标
		var direction = (target_pos - position).normalized()
		position += direction * speed * delta
	
	# 动画
	if sprite and sprite.texture:
		frame = (frame + delta * 8) % 4

func take_damage(damage: float):
	if dead:
		return
	current_health -= damage
	_update_health_bar()
	if current_health <= 0:
		_die()

func _die():
	if dead:
		return
	dead = true
	_disable_collision()
	
	# 创建粒子效果
	_spawn_death_particles()
	
	var player = get_tree().get_first_node_in_group("player")
	var spawner = get_tree().get_first_node_in_group("spawner")
	var audio = get_tree().get_first_node_in_group("audio_manager")
	var stats_mgr = get_tree().get_first_node_in_group("stats_manager")
	
	if audio:
		audio.play_explode()
	
	if player:
		player.add_experience(EXPERIENCE_REWARD)
		player.add_kill()
		print("💀 Zombie死亡: 类型=" + zombie_type + " 玩家击杀=" + str(player.kills))
	
	if spawner:
		spawner.add_kill()
	
	if is_boss or zombie_type == "boss":
		emit_signal("boss_died")
		if player:
			player.emit_signal("game_won")
		if stats_mgr:
			stats_mgr.add_kill(true)
	
	if stats_mgr:
		stats_mgr.add_kill(false)
	
	queue_free()

func _update_health_bar():
	if health_bar_fg:
		var max_health = get_max_health()
		var pct = current_health / max_health
		health_bar_fg.size.x = 20 * pct
		if pct > 0.6:
			health_bar_fg.color = Color(0, 1, 0)
		elif pct > 0.3:
			health_bar_fg.color = Color(1, 1, 0)
		else:
			health_bar_fg.color = Color(1, 0, 0)

func _setup_health_bar():
	health_bar_fg = ColorRect.new()
	health_bar_fg.name = "HealthBarFg"
	health_bar_fg.color = Color(0, 1, 0)
	health_bar_fg.size = Vector2(20, 4)
	health_bar_fg.position = Vector2(-10, -40)
	add_child(health_bar_fg)

func _spawn_death_particles():
	var particle = GPUParticles2D.new()
	particle.process_material = ProcessMaterial.new()
	particle.process_material.emission_sphere_radius = 20
	particle.one_shot = true
	particle.max_particles = 10
	particle.emitting = true
	particle.lifetime = 0.5
	position.y -= 20
	add_child(particle)
	await get_tree().create_timer(0.5).timeout
	particle.queue_free()

func _show_damage_number(damage, is_critical):
	var number = Label.new()
	number.text = str(int(damage))
	if is_critical:
		number.text = str(int(damage)) + "!"
	number.add_theme_font_size_override("font_size", 12 if not is_critical else 18)
	number.modulate = Color(1, 1, 0.2) if is_critical else Color(1, 1, 1)
	number.position = position + Vector2(0, -35)
	number.z_index = 100
	get_parent().add_child(number)
	
	var tween = create_tween()
	tween.tween_property(number, "position:y", number.position.y - 30, 0.5)
	tween.tween_property(number, "modulate:a", 0, 0.5)
	tween.tween_callback(number.queue_free)

func get_max_health() -> float:
	if is_boss or zombie_type == "boss":
		return BOSS_HEALTH
	elif zombie_type == "fast":
		return FAST_HEALTH
	else:
		return BASE_HEALTH

func get_speed() -> float:
	if is_boss or zombie_type == "boss":
		return BOSS_SPEED
	elif zombie_type == "fast":
		return FAST_SPEED
	else:
		return BASE_SPEED
