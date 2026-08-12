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
const SAFETY_TIME = 2.0

# 透视缩放参数
# 道路宽度分析: 街道图片(512x512)缩放至720x1280后的比例
# 缩放因子: 720/512 = 1.40625 (X轴), 1280/512 = 2.5 (Y轴)
const ROAD_WIDTH_TOP = 614.0    # 屏幕顶部(中心y=-576)道路宽度
const ROAD_WIDTH_BOTTOM = 20.0  # 玩家位置(中心y=460)道路宽度(最小宽度)
const PLAYER_Y_CENTER = 460.0   # 玩家在中心坐标系中的Y位置
const SPAWN_Y_TOP = -450.0      # 僵尸生成最远Y
const SPAWN_Y_BOTTOM = -350.0   # 僵尸生成最近Y

var zombie_type = "basic"
var is_boss = false
var current_health = BASE_HEALTH
var speed = BASE_SPEED
var dead = false
var can_attack = true
var player_node = null
var player_area = null
var bullet_area = null
var sprite: Sprite2D
var health_bar_fg: ColorRect
var zombie_kills = 0
var frame_count = 0
var current_frame = 0
var boss_anim_timer = 0.0
var base_scale = 1.0  # 基础缩放

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
	
	# 根据初始位置设置基础缩放
	_update_perspective()
	
	print("✅ Zombie创建: 类型=" + zombie_type + " 健康=" + str(int(current_health)))

# 根据Y位置计算道路半宽（中心坐标系）
func _get_road_half_width(y_pos: float) -> float:
	var t = inverse_lerp(PLAYER_Y_CENTER, SPAWN_Y_TOP, y_pos)
	t = clamp(t, 0.0, 1.0)
	var width = lerp(ROAD_WIDTH_BOTTOM, ROAD_WIDTH_TOP, t)
	return width / 2.0

# 根据Y位置计算透视缩放比例
func _get_perspective_scale(y_pos: float) -> float:
	var t = inverse_lerp(PLAYER_Y_CENTER, SPAWN_Y_TOP, y_pos)
	t = clamp(t, 0.0, 1.0)
	# 远处(顶部)t=0, scale=1.2; 近处(玩家)t=1, scale=0.6
	# 修正：生成时在远处，用更大基础缩放让它们看起来更大
	return lerp(1.2, 0.6, t)

# 更新透视缩放和位置
func _update_perspective():
	var half_width = _get_road_half_width(position.y)
	# 限制X位置在道路范围内
	position.x = clamp(position.x, -half_width, half_width)
	
	# 计算并应用缩放
	var scale_val = _get_perspective_scale(position.y)
	base_scale = scale_val
	
	if sprite:
		if is_boss or zombie_type == "boss":
			# Boss: 基础0.6，透视放大到1.2
			sprite.scale = Vector2(0.6, 0.6) * scale_val
		else:
			# 僵尸: 基础0.9，透视放大到1.5
			sprite.scale = Vector2(0.9, 0.9) * scale_val

func _setup_sprite():
	if is_boss or zombie_type == "boss":
		sprite = Sprite2D.new()
		var boss_texture = load("res://assets/downloads/bbossmove.png")
		if boss_texture:
			sprite.texture = boss_texture
			sprite.region_enabled = true
			sprite.region_rect = Rect2(0, 0, 150, 300)
			sprite.scale = Vector2(0.4, 0.4)
			sprite.centered = true
		add_child(sprite)
		position = Vector2(0, -300)
	else:
		sprite = Sprite2D.new()
		var texture = load("res://assets/downloads/zombie_front_4frames_game.png")
		if texture:
			sprite.texture = texture
			sprite.region_enabled = true
			sprite.region_rect = Rect2(0, 0, 64, 64)
			sprite.scale = Vector2(0.8, 0.8)
			sprite.centered = true
		add_child(sprite)

func _setup_collision():
	player_area = Area2D.new()
	player_area.name = "PlayerArea"
	player_area.collision_layer = 2
	player_area.collision_mask = 1
	player_area.body_entered.connect(_on_player_detected)
	add_child(player_area)
	
	var player_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = COLLISION_RADIUS
	player_shape.shape = circle
	player_area.add_child(player_shape)
	
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
	
	print("  ✅ 碰撞体创建成功 (检测玩家层=2, 子弹层=4)")

func _on_player_detected(body):
	if body.is_in_group("player") and not dead and can_attack:
		_disable_collision()
		dead = true
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(999)
			player.emit_signal("player_died")
		print("💀 僵尸碰到玩家！")

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
		player_area.set_deferred("monitoring", false)
		player_area.set_deferred("monitorable", false)
	if bullet_area:
		bullet_area.set_deferred("monitoring", false)
		bullet_area.set_deferred("monitorable", false)

func _physics_process(delta):
	if dead:
		return
	
	frame_count += 1
	
	# 移动逻辑
	var target = get_tree().get_first_node_in_group("player")
	if target:
		var target_center = target.position - Vector2(360, 640)
		if position.y >= target_center.y - 5.0:
			target_center.y = position.y
		var direction = (target_center - position).normalized()
		position += direction * speed * delta
	
	# 每帧更新透视缩放
	_update_perspective()
	
	# 动画帧切换
	if sprite and sprite.texture:
		if is_boss or zombie_type == "boss":
			boss_anim_timer += delta
			var pulse = 1.0 + 0.1 * sin(boss_anim_timer * 3.0)
			var max_hp = get_max_health()
			var hp_ratio = clamp(current_health / max_hp, 0.0, 1.0)
			var shrink = 0.4 + 0.6 * hp_ratio
			# Boss缩放 = 基础透视缩放 * 脉动 * 血量缩放
			base_scale = _get_perspective_scale(position.y)
			sprite.scale = Vector2(0.4, 0.4) * base_scale * shrink * pulse
			if frame_count % 8 == 0:
				current_frame = (current_frame + 1) % 4
				sprite.region_rect = Rect2(current_frame * 150, 0, 150, 300)
		else:
			if frame_count % 5 == 0:
				current_frame = (current_frame + 1) % 4
				sprite.region_rect = Rect2(current_frame * 64, 0, 64, 64)

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
	particle.amount = 10
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