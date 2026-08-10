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

@export var is_boss: bool = false
var zombie_type = "basic"
var current_health: float
var base_speed: float
var dead = false
var damage_timer = 0.0
var sprite_node: Sprite2D = null
var health_bar: ProgressBar = null
var frame_count = 0
var current_frame = 0
var boss_anim_timer = 0.0
var spawn_time = 0.0  # 生成时间，用于安全延迟
var safety_delay = 2.0  # 安全延迟时间（秒）

signal zombie_reached_player
signal zombie_spawned

func _ready():
	add_to_group("zombies")
	
	_setup_sprite()
	_setup_collision()
	
	# 记录生成时间
	spawn_time = Time.get_ticks_msec() / 1000.0
	safety_delay = 2.0
	
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
	print("   位置=(" + str(int(position.x)) + ", " + str(int(position.y)) + ") 安全延迟=" + str(safety_delay) + "秒")
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
			print("🎨 Boss素材加载成功: 167x374, 缩放2x")
		else:
			_setup_fallback_sprite(Color(1, 0, 0), Vector2(2, 2))
	else:
		# 使用备用素材，因为原素材路径可能不存在
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
	print("⚠️ 使用备用僵尸素材 (颜色=" + str(color) + ")")

func _setup_collision():
	var area = Area2D.new()
	area.name = "ZombieArea"
	area.collision_layer = 2
	area.collision_mask = 1  # 只检测玩家
	area.body_entered.connect(_on_player_detected)
	add_child(area)
	
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape"
	var shape = CircleShape2D.new()
	shape.radius = 30.0
	collision.shape = shape
	area.add_child(collision)
	
	_create_health_bar()
	
	print("✅ 碰撞体创建成功 (半径=30)")

func _create_health_bar():
	if is_boss or zombie_type == "boss":
		var bar_bg = ColorRect.new()
		bar_bg.name = "HealthBarBg"
		bar_bg.color = Color(0.5, 0, 0)
		bar_bg.size = Vector2(100, 10)
		bar_bg.position = Vector2(-50, -80)
		add_child(bar_bg)
		
		var bar_fg = ColorRect.new()
		bar_fg.name = "HealthBarFg"
		bar_fg.color = Color(1, 0, 0)
		bar_fg.size = Vector2(100, 10)
		bar_fg.position = Vector2(-50, -80)
		add_child(bar_fg)
		
		print("✅ Boss健康条已创建")
	else:
		var bar_container = VBoxContainer.new()
		bar_container.name = "HealthBarContainer"
		bar_container.position = Vector2(0, -50)
		add_child(bar_container)
		
		var bar_bg = ColorRect.new()
		bar_bg.name = "HealthBarBg"
		bar_bg.color = Color(0.5, 0, 0)
		bar_bg.size = Vector2(60, 6)
		bar_container.add_child(bar_bg)
		
		var bar_fg = ColorRect.new()
		bar_fg.name = "HealthBarFg"
		bar_fg.color = Color(0, 1, 0)
		bar_fg.size = Vector2(60, 6)
		bar_container.add_child(bar_fg)
		
		print("✅ 僵尸健康条已创建")

func _to_screen_position() -> Vector2:
	return position + Vector2(360, 640)

func _on_player_detected(body):
	# 检查是否在安全延迟期间
	var safety_time = Time.get_ticks_msec() / 1000.0 - spawn_time
	var remaining_time = safety_delay - safety_time
	
	if safety_time < safety_delay:
		print("  🔒 僵尸在安全期内，不攻击玩家 (剩余: " + str(remaining_time) + "秒)")
		return
	
	if body.is_in_group("player") and not dead:
		print("💥 Zombie 碰到玩家！类型=" + zombie_type + " 剩余安全时间=0")
		if not dead:
			dead = true
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.take_damage(999)
			emit_signal("zombie_reached_player")

func _physics_process(delta):
	if dead:
		return
	
	frame_count += 1
	
	# 检查安全延迟
	var safety_time = Time.get_ticks_msec() / 1000.0 - spawn_time
	if safety_time < safety_delay:
		return  # 还在安全期内，不移动
	
	var player_node = get_tree().get_first_node_in_group("player")
	
	if player_node:
		var target_x_pos: float = player_node.position.x - 360.0
		var target_y_pos: float = player_node.position.y - 640.0
		
		var dx = target_x_pos - position.x
		var dy = target_y_pos - position.y
		var move_dir = Vector2(dx, dy).normalized()
		position += move_dir * base_speed * delta
		
		# 动画（普通僵尸才切换帧）
		var anim_speed = 5 if (!is_boss and zombie_type != "boss") else 8
		if frame_count % anim_speed == 0 and sprite_node and sprite_node.texture and sprite_node.region_enabled and zombie_type != "boss":
			current_frame = (current_frame + 1) % 4
			sprite_node.region_rect = Rect2(current_frame * 64, 0, 64, 64)
		
		# Boss 动画效果（脉冲 + 帧切换）
		if (is_boss or zombie_type == "boss") and sprite_node:
			boss_anim_timer += delta
			var pulse = 1.0 + 0.1 * sin(boss_anim_timer * 3.0)
			var base_scale = Vector2(1.0, 1.0)
			sprite_node.scale = base_scale * pulse
			# Boss 显示所有4帧动画
			if frame_count % 8 == 0:
				var frame = (current_frame % 4) * 167
				sprite_node.region_rect = Rect2(frame, 0, 167, 374)
		
		# 更新位置标签
		var screen_pos = _to_screen_position()
		if has_node("PositionLabel"):
			$PositionLabel.text = "位置:" + str(int(screen_pos.x)) + "," + str(int(screen_pos.y))
		else:
			var label = Label.new()
			label.name = "PositionLabel"
			label.text = "位置:" + str(int(screen_pos.x)) + "," + str(int(screen_pos.y))
			label.add_theme_font_size_override("font_size", 10)
			add_child(label)
	
	# Boss 伤害检测
	if (is_boss or zombie_type == "boss") and player_node:
		damage_timer += delta
		if damage_timer >= 1.0:
			damage_timer = 0.0
			var player_health = player_node.current_health if player_node.has_method("take_damage") else 100
			if player_health > 0:
				player_node.take_damage(DAMAGE_PER_SECOND)
				print("💥 Boss攻击玩家！伤害=" + str(DAMAGE_PER_SECOND) + " 剩余HP=" + str(int(player_health - DAMAGE_PER_SECOND)))

func take_damage(damage: float):
	if dead:
		return
	
	current_health -= damage
	_update_health_bar()
	
	print("💥 Zombie受伤: 类型=" + zombie_type + " 健康=" + str(int(current_health)) + "/" + str(int(get_max_health())))
	
	if current_health <= 0:
		_die()

func _update_health_bar():
	if is_boss or zombie_type == "boss":
		if has_node("HealthBarFg"):
			var bar = $HealthBarFg
			var max_health = get_max_health()
			bar.size.x = 100.0 * (current_health / max_health)
	else:
		var health_bar_container = get_node_or_null("HealthBarContainer")
		if health_bar_container and health_bar_container.has_node("HealthBarFg"):
			var bar = health_bar_container.get_node("HealthBarFg")
			var max_health = get_max_health()
			bar.size.x = 60.0 * (current_health / max_health)

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
	
	# 播放死亡音效
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
