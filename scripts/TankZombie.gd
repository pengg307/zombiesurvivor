extends CharacterBody2D
class_name TankZombie

const BASE_HEALTH = 30.0
const BASE_SPEED = 30.0
const EXPERIENCE_REWARD = 20
const SCREEN_HEIGHT = 1280.0
const PLAYER_Y_SCREEN = 1100.0

# 透视缩放参数（与 Zombie.gd 一致）
const ROAD_WIDTH_TOP = 614.0
const ROAD_WIDTH_BOTTOM = 20.0
const PLAYER_Y_CENTER = 460.0
const SPAWN_Y_TOP = -450.0

var current_health = BASE_HEALTH
var sprite_node: Sprite2D = null
var walk_timer = 0.0
var current_frame = 0
var health_bar: ProgressBar = null
var health_bar_bg: ColorRect = null
var sprite_size = Vector2(80, 80)
var dead = false

signal tank_exploded

func _ready():
	add_to_group("zombies")  # Tank 仍然是僵尸，会攻击玩家
	collision_layer = 2
	collision_mask = 1
	call_deferred("_setup_collision")
	_setup_sprite()
	_create_health_bar()
	_update_perspective()
	print("✅ TankZombie创建: 血量=" + str(BASE_HEALTH) + " 速度=" + str(BASE_SPEED))

func _get_road_half_width(y_pos: float) -> float:
	var t = inverse_lerp(PLAYER_Y_CENTER, SPAWN_Y_TOP, y_pos)
	t = clamp(t, 0.0, 1.0)
	var width = lerp(ROAD_WIDTH_BOTTOM, ROAD_WIDTH_TOP, t)
	return width / 2.0

func _get_perspective_scale(y_pos: float) -> float:
	var t = inverse_lerp(PLAYER_Y_CENTER, SPAWN_Y_TOP, y_pos)
	t = clamp(t, 0.0, 1.0)
	return lerp(1.2, 0.6, t)

func _update_perspective():
	var half_width = _get_road_half_width(position.y)
	position.x = clamp(position.x, -half_width, half_width)
	
	var scale_val = _get_perspective_scale(position.y)
	if sprite_node:
		sprite_node.scale = Vector2(1.0, 1.0) * scale_val  # Tank 比正常僵尸稍大

func _setup_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var texture = load("res://assets/downloads/zombie_front_4frames_game.png")
	if texture:
		sprite.texture = texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 64, 64)
		sprite.centered = true
		add_child(sprite)
		sprite_node = sprite
		print("🎨 TankZombie素材加载成功")
	else:
		_setup_fallback_sprite()

func _setup_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var rect = ColorRect.new()
	rect.size = Vector2(80, 80)
	rect.color = Color(0.8, 0.3, 0.1)  # 橙色表示 Tank
	sprite.add_child(rect)
	add_child(sprite)
	sprite_node = sprite

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 40.0
	shape.height = 60.0
	collision.shape = shape
	add_child(collision)
	
	var area = Area2D.new()
	area.name = "PlayerDetector"
	area.collision_layer = 2
	area.collision_mask = 1
	area.body_entered.connect(_on_player_detected)
	add_child(area)

func _on_player_detected(body):
	if body.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.take_damage(999)
			player.emit_signal("player_died")
		emit_signal("zombie_reached_player")

func _physics_process(delta):
	if dead:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# 玩家屏幕坐标 -> 僵尸中心坐标
		var target_center = player.position - Vector2(360, 640)
		# 到达玩家Y行后只在X轴移动，收敛到玩家正上方
		if position.y >= target_center.y - 5.0:
			target_center.y = position.y
		var move_dir = (target_center - position).normalized()
		position += move_dir * BASE_SPEED * delta
		
		# 每帧更新透视
		_update_perspective()
		
		# 动画
		walk_timer += delta
		if sprite_node and walk_timer >= 0.2:
			walk_timer = 0.0
			current_frame = (current_frame + 1) % 4
			if sprite_node.texture:
				sprite_node.region_rect = Rect2(current_frame * 64, 0, 64, 64)
		
		# 接触玩家判定（用全局坐标）
		if get_global_position().distance_to(player.global_position) <= 50.0:
			var player_node = get_tree().get_first_node_in_group("player")
			if player_node:
				player_node.take_damage(999)
				player_node.emit_signal("player_died")
			queue_free()

func take_damage(damage: float):
	if dead:
		return
	current_health -= damage
	modulate = Color(1, 0, 0)
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	_update_health_bar()
	if current_health <= 0:
		_die()

func _die():
	if dead:
		return
	dead = true
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_kill()
		player.add_experience(EXPERIENCE_REWARD)
	
	# Tank 爆炸！生成火力增强包
	_explode()
	
	if health_bar:
		health_bar.queue_free()
	if health_bar_bg:
		health_bar_bg.queue_free()
	queue_free()

func _explode():
	# 触发爆炸信号
	emit_signal("tank_exploded")
	
	# 显示爆炸特效
	_spawn_explosion_effect()
	
	# 生成火力增强包（不再是直接升级，而是掉落道具）
	_spawn_power_up()

func _spawn_power_up():
	var power_up_scene = load("res://scripts/TankPowerUp.gd")
	if power_up_scene:
		var power_up = power_up_scene.new()
		power_up.position = position
		get_parent().add_child(power_up)
		print("🎁 火力增强包已生成！位置=(" + str(int(position.x)) + "," + str(int(position.y)) + ")")

func _spawn_explosion_effect():
	var particles = GPUParticles2D.new()
	particles.one_shot = true
	particles.amount = 30
	particles.lifetime = 0.6
	particles.emitting = true
	# 设置粒子颜色（橙色爆炸）
	particles.process_material = ParticleProcessMaterial.new()
	particles.process_material.color = Color(1.0, 0.5, 0.0, 1.0)
	particles.process_material.gravity = Vector3(0, -200, 0)
	# 注意: 2D粒子不支持linear_velocity和scale_ratio，跳过
	get_parent().add_child(particles)
	
	var timer = get_tree().create_timer(0.6)
	timer.timeout.connect(func(): particles.queue_free())
	print("💥 Tank爆炸特效！")

func _create_health_bar():
	health_bar_bg = ColorRect.new()
	health_bar_bg.name = "HealthBarBG"
	health_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	health_bar_bg.position = Vector2(-40, -50)
	health_bar_bg.size = Vector2(80, 8)
	add_child(health_bar_bg)
	
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.min_value = 0
	health_bar.max_value = BASE_HEALTH
	health_bar.value = BASE_HEALTH
	health_bar.position = Vector2(-40, -50)
	health_bar.size = Vector2(80, 8)
	health_bar.modulate = Color(1, 0.3, 0.1)
	add_child(health_bar)

func _update_health_bar():
	if health_bar:
		health_bar.value = current_health
		var pct = float(current_health) / BASE_HEALTH
		if pct > 0.6:
			health_bar.modulate = Color(1, 0.8, 0.1)
		elif pct > 0.3:
			health_bar.modulate = Color(1, 0.5, 0.1)
		else:
			health_bar.modulate = Color(1, 0.1, 0.1)