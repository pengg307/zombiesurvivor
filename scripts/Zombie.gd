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
const COLLISION_RADIUS = 60.0

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
var health_bar_bg: ColorRect = null
var health_bar_fg: ColorRect = null

signal zombie_reached_player
signal zombie_spawned

func _ready():
	add_to_group("zombies")
	
	_setup_sprite()
	_setup_collision()
	_create_health_bar()
	
	if is_boss or zombie_type == "boss":
		current_health = BOSS_HEALTH
		base_speed = BOSS_SPEED
	else:
		if zombie_type == "fast":
			current_health = FAST_HEALTH
			base_speed = FAST_SPEED
		else:
			current_health = BASE_HEALTH
			base_speed = BASE_SPEED
	
	print("✅ Zombie创建: 类型=" + zombie_type + " 健康=" + str(int(current_health)))
	
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
			sprite.scale = Vector2(1.2, 1.2)
		else:
			_setup_fallback_sprite(Color(1, 0, 0), Vector2(1.2, 1.2))
	else:
		_setup_fallback_sprite(Color(0, 0.8, 0), Vector2(0.8, 0.8))
	
	add_child(sprite)
	sprite_node = sprite

func _setup_fallback_sprite(color: Color, scale: Vector2):
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = true
	sprite.z_index = 10
	var rect = ColorRect.new()
	rect.size = Vector2(30, 30)
	rect.color = color
	sprite.add_child(rect)
	sprite.scale = scale
	add_child(sprite)
	sprite_node = sprite

func _setup_collision():
	# 玩家检测区域
	var player_area = Area2D.new()
	player_area.name = "PlayerArea"
	player_area.collision_layer = 2
	player_area.collision_mask = 1
	player_area.monitoring = true
	player_area.body_entered.connect(_on_player_detected)
	add_child(player_area)
	
	var player_collision = CollisionShape2D.new()
	var player_shape = CircleShape2D.new()
	player_shape.radius = COLLISION_RADIUS * 0.4
	player_collision.shape = player_shape
	player_area.add_child(player_collision)
	
	# 子弹检测区域 - 使用 area_entered 检测 Area2D
	var bullet_area = Area2D.new()
	bullet_area.name = "BulletArea"
	bullet_area.collision_layer = 2
	bullet_area.collision_mask = 4  # 检测 bullets
	bullet_area.monitoring = true
	bullet_area.monitorable = true
	bullet_area.area_entered.connect(_on_bullet_area_entered)
	add_child(bullet_area)
	
	var bullet_collision = CollisionShape2D.new()
	var bullet_shape = CircleShape2D.new()
	bullet_shape.radius = 25.0
	bullet_collision.shape = bullet_shape
	bullet_area.add_child(bullet_collision)
	
	print("  ✅ 碰撞体创建 (玩家半径=" + str(COLLISION_RADIUS * 0.4) + ", 子弹半径=25)")

func _create_health_bar():
	# 非常小的健康条 - 20x4
	health_bar_bg = ColorRect.new()
	health_bar_bg.name = "HealthBarBg"
	health_bar_bg.color = Color(0.5, 0, 0)
	health_bar_bg.size = Vector2(20, 4)
	health_bar_bg.position = Vector2(-10, -40)
	add_child(health_bar_bg)
	
	health_bar_fg = ColorRect.new()
	health_bar_fg.name = "HealthBarFg"
	health_bar_fg.color = Color(0, 1, 0)
	health_bar_fg.size = Vector2(20, 4)
	health_bar_fg.position = Vector2(-10, -40)
	add_child(health_bar_fg)

func _on_player_detected(body):
	if body.is_in_group("player") and not dead:
		if not dead:
			dead = true
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.take_damage(999)
			emit_signal("zombie_reached_player")

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
			print("💥 Zombie受伤: 类型=" + zombie_type + " 伤害=" + str(int(final_damage)) + " 暴击=" + str(is_critical))
			if not bullet.is_pierce:
				bullet.queue_free()

func _physics_process(delta):
	if dead:
		return
	
	frame_count += 1
	
	var player_node = get_tree().get_first_node_in_group("player")
	
	if player_node:
		var target_center_pos = player_node.position - Vector2(360, 640)
		
		var dx = target_center_pos.x - position.x
		var dy = target_center_pos.y - position.y
		var move_dir = Vector2(dx, dy).normalized()
		position += move_dir * base_speed * delta
		
		# 动画
		if !is_boss and zombie_type != "boss":
			if frame_count % 5 == 0 and sprite_node:
				current_frame = (current_frame + 1) % 4
				sprite_node.region_rect = Rect2(current_frame * 30, 0, 30, 30)
		
		# Boss 动画
		if is_boss or zombie_type == "boss":
			boss_anim_timer += delta
			var pulse = 1.0 + 0.1 * sin(boss_anim_timer * 3.0)
			sprite_node.scale = Vector2(1.2, 1.2) * pulse
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

func take_damage(damage: float):
	if dead:
		return
	
	current_health -= damage
	_update_health_bar()
	
	if current_health <= 0:
		_die()

func _update_health_bar():
	if health_bar_fg:
		var max_health = get_max_health()
		var health_pct = max(0.0, float(current_health) / float(max_health))
		health_bar_fg.size.x = 20.0 * health_pct
		
		if health_pct > 0.6:
			health_bar_fg.color = Color(0, 1, 0)
		elif health_pct > 0.3:
			health_bar_fg.color = Color(1, 1, 0)
		else:
			health_bar_fg.color = Color(1, 0, 0)

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
