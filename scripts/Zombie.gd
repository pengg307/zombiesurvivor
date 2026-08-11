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
var sprite_hit: Sprite2D
var health_bar_fg: ColorRect
var anim_timer = 0.0
var is_attacking = false

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
		# Boss移动动画
		sprite = Sprite2D.new()
		var boss_texture = load("res://assets/downloads/bboss.png")
		if boss_texture:
			sprite.texture = boss_texture
			sprite.scale = Vector2(1, 1)
			sprite.centered = true
		add_child(sprite)
		
		# Boss攻击动画（受伤时显示）
		sprite_hit = Sprite2D.new()
		sprite_hit.visible = false
		var boss_hit_texture = load("res://assets/downloads/bbosshit.png")
		if boss_hit_texture:
			sprite_hit.texture = boss_hit_texture
			sprite_hit.scale = Vector2(1, 1)
			sprite_hit.centered = true
		add_child(sprite_hit)
		
		position = Vector2(0, -300)
	else:
		# 普通僵尸移动动画
		sprite = Sprite2D.new()
		var texture = load("res://assets/downloads/szombie.png")
		if texture:
			sprite.texture = texture
			sprite.scale = Vector2(2, 2)
			sprite.centered = true
		add_child(sprite)
		
		# 普通僵尸攻击动画
		sprite_hit = Sprite2D.new()
		sprite_hit.visible = false
		var hit_texture = load("res://assets/downloads/szombiehit.png")
		if hit_texture:
			sprite_hit.texture = hit_texture
			sprite_hit.scale = Vector2(2, 2)
			sprite_hit.centered = true
		add_child(sprite_hit)

func _setup_collision():
	# 创建碰撞体
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
	bullet_area.collision_layer = 0
	bullet_area.collision_mask = 4
	bullet_area.area_entered.connect(_on_bullet_area_entered)
	add_child(bullet_area)
	
	var bullet_shape = CollisionShape2D.new()
	var circle2 = CircleShape2D.new()
	circle2.radius = 20
	bullet_shape.shape = circle2
	bullet_area.add_child(bullet_shape)
	
	print("  ✅ 碰撞体创建成功")

func _on_player_detected(body):
	if body.is_in_group("player") and not dead and can_attack:
		var player_pos = body.position + Vector2(360, 640)
		var dist = position.distance_to(player_pos)
		if dist <= COLLISION_RADIUS:
			_disable_collision()
			dead = true
			is_attacking = true
			_show_hit_animation()
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.take_damage(999)
			emit_signal("zombie_reached_player")
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

func _show_hit_animation():
	# 显示攻击动画
	if sprite_hit:
		sprite_hit.visible = true
	if sprite:
		sprite.visible = false

func _show_move_animation():
	# 显示移动动画
	if sprite_hit:
		sprite_hit.visible = false
	if sprite:
		sprite.visible = true

func _physics_process(delta):
	if dead:
		return
	
	# 移动逻辑
	var target = get_tree().get_first_node_in_group("player")
	if target:
		var target_pos = target.position + Vector2(360, 640)
		var direction = (target_pos - position).normalized()
		position += direction * speed * delta
	
	# 动画计时
	anim_timer += delta
	if anim_timer >= 0.15:
		anim_timer = 0
		# 切换帧
		if sprite and sprite.texture:
			var frame_count = _get_frame_count()
			if frame_count > 1:
				sprite.frame = (sprite.frame + 1) % frame_count

func _get_frame_count() -> int:
	if not sprite or not sprite.texture:
		return 1
	var tex = sprite.texture
	if tex:
		return max(1, tex.get_width() / 64)
	return 1

func take_damage(damage: float):
	if dead:
		return
	current_health -= damage
	_update_health_bar()
	
	# 受伤时短暂显示攻击动画
	if not is_attacking:
		is_attacking = true
		_show_hit_animation()
		# 0.5秒后恢复移动动画
		await get_tree().create_timer(0.5).timeout
		if not dead:
			is_attacking = false
			_show_move_animation()

func _die():
	if dead:
		return
	dead = true
	_disable_collision()
	_show_move_animation()
	
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
