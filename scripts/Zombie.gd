extends CharacterBody2D
class_name Zombie

const BASE_HEALTH = 10.0
const BASE_SPEED = 50.0
const FAST_HEALTH = 8.0
const FAST_SPEED = 70.0
const BOSS_HEALTH = 500.0
const BOSS_SPEED = 30.0
const DAMAGE = 10.0
const EXPERIENCE_REWARD = 10
const SCREEN_HEIGHT = 1280.0
const PLAYER_Y_SCREEN = 1100.0

signal boss_died
signal zombie_reached_player

@export var zombie_type: String = "basic"
@export var is_boss: bool = false

var current_health = BASE_HEALTH
var base_speed = BASE_SPEED
var target_x = 0.0
var side = "左侧"
var frame_count = 0
var sprite_node: Sprite2D = null
var walk_timer = 0.0
var current_frame = 0
var hit_flash_timer = 0.0
var has_reached_player = false
var _boss_anim_timer = 0.0
var _boss_frame_size = 166
var _boss_frame_height = 374
var player_node = null
var health_bar: ProgressBar = null
var health_bar_bg: ColorRect = null
var sprite_size = Vector2(64, 64)

const ZOMBIE_CONFIG = {
	"basic": {"health": 10.0, "speed": 50.0, "color": Color(0.3, 0.5, 0.3)},
	"fast": {"health": 8.0, "speed": 70.0, "color": Color(0.5, 0.3, 0.5)},
	"boss": {"health": 500.0, "speed": 30.0, "color": Color(0.8, 0.2, 0.2)}
}

func _ready():
	current_health = BASE_HEALTH
	add_to_group("zombies")
	
	collision_layer = 2
	collision_mask = 1
	
	call_deferred("_setup_collision")
	
	if is_boss or zombie_type == "boss":
		current_health = BOSS_HEALTH
		base_speed = BOSS_SPEED
		_setup_boss_sprite()
		print("👹 Boss创建完成: 位置=( " + str(int(position.x)) + "," + str(int(position.y)) + ")")
	elif zombie_type == "fast":
		base_speed = 70.0
		_setup_sprite()
	else:
		_setup_sprite()
	
	print("✅ Zombie创建: 类型=" + zombie_type)

func _setup_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	
	var texture_path = "res://assets/downloads/zombie_front_4frames_game.png"
	var texture = load(texture_path)
	
	if texture:
		sprite.texture = texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 64, 64)
		sprite.centered = true
		sprite.position = Vector2(0, 0)
		add_child(sprite)
		sprite_node = sprite
		sprite_size = Vector2(64, 64)
		print("🎨 僵尸素材加载成功")
	else:
		_setup_fallback_sprite()

func _setup_boss_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.z_index = 50
	sprite.visible = true
	
	var boss_texture_path = "res://assets/downloads/biggerboss.png"
	var boss_texture = load(boss_texture_path)
	
	if boss_texture:
		sprite.texture = boss_texture
		sprite.region_enabled = true
		# Boss 4x1 布局，每帧166x374
		_boss_frame_size = 166
		_boss_frame_height = 374
		sprite.region_rect = Rect2(0, 0, _boss_frame_size, _boss_frame_height)
		sprite.centered = true
		sprite.position = Vector2(0, 0)
		add_child(sprite)
		sprite_node = sprite
		sprite_size = Vector2(_boss_frame_size, _boss_frame_height)
		print("🎨 Boss素材加载成功: " + str(boss_texture.get_width()) + "x" + str(boss_texture.get_height()))
	else:
		_setup_fallback_sprite()
		print("⚠️ 无法加载Boss素材")

func _setup_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var rect = ColorRect.new()
	rect.size = sprite_size
	rect.color = ZOMBIE_CONFIG.get(zombie_type, ZOMBIE_CONFIG["basic"]).color
	sprite.add_child(rect)
	add_child(sprite)
	sprite_node = sprite
	print("⚠️ 使用备用僵尸素材")

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 30.0
	shape.height = 50.0
	collision.shape = shape
	add_child(collision)
	
	var area = Area2D.new()
	area.name = "PlayerDetector"
	area.monitoring = true
	area.collision_layer = 2
	area.collision_mask = 1
	area.body_entered.connect(_on_player_detected)
	add_child(area)
	
	_create_health_bar()
	
	print("✅ 碰撞体创建成功")

func _to_screen_position() -> Vector2:
	return position + Vector2(360, 640)

func _on_player_detected(body):
	if body.is_in_group("player"):
		print("💥 Zombie 碰到玩家！类型=" + zombie_type)
		if player_node:
			player_node.take_damage(999)
			player_node.emit_signal("player_died")
		else:
			player_node = get_tree().get_first_node_in_group("player")
			if player_node:
				player_node.take_damage(999)
				player_node.emit_signal("player_died")
		emit_signal("zombie_reached_player")

func _physics_process(delta):
	frame_count += 1
	
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
			_boss_anim_timer += delta
			var pulse = 1.0 + 0.1 * sin(_boss_anim_timer * 3.0)
			var base_scale = Vector2(1.0, 1.0)
			sprite_node.scale = base_scale * pulse
			# Boss 显示所有4帧动画
			if frame_count % 8 == 0:
				current_frame = (current_frame + 1) % 4
				var frame_x = (current_frame % 4) * _boss_frame_size
				var frame_y = 0
				sprite_node.region_rect = Rect2(frame_x, frame_y, _boss_frame_size, _boss_frame_height)
		
		# 检查是否到达玩家位置
		var screen_pos = _to_screen_position()
		var screen_y = screen_pos.y
		
		if screen_y >= PLAYER_Y_SCREEN and not has_reached_player:
			has_reached_player = true
			print("🚨 警报！Zombie到达玩家位置！")
			
			if is_boss or zombie_type == "boss":
				print("👹 Boss到达玩家！游戏失败！")
				player_node.take_damage(999)
				player_node.emit_signal("player_died")
			else:
				print("❌ 僵尸到达玩家！游戏失败！")
				player_node.take_damage(999)
				player_node.emit_signal("player_died")
			emit_signal("zombie_reached_player")
			
			print("🗑️ Boss/僵尸将被删除: " + zombie_type)
			_die()

func take_damage(damage: float):
	current_health -= damage
	print("💥 Zombie受伤: 类型=" + zombie_type + " 血量=" + str(int(current_health)) + "/" + str(get_max_health()))
	
	# 受伤闪烁效果
	hit_flash_timer = 0.2
	modulate = Color(1, 0.3, 0.3)
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	
	# 播放受伤音效
	var audio = get_tree().get_first_node_in_group("audio_manager")
	if audio:
		audio.play_hit()
	
	# 更新健康条
	_update_health_bar()
	
	if current_health <= 0:
		print("💀 Zombie死亡: 类型=" + zombie_type)
		_die()

func get_max_health() -> float:
	if zombie_type == "boss":
		return BOSS_HEALTH
	elif zombie_type == "fast":
		return FAST_HEALTH
	else:
		return BASE_HEALTH

func _create_health_bar():
	# 健康条背景 - 更窄更靠下
	health_bar_bg = ColorRect.new()
	health_bar_bg.name = "HealthBarBG"
	health_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	health_bar_bg.position = Vector2(-30, -sprite_size.y / 2 - 5)
	health_bar_bg.size = Vector2(60, 6)
	add_child(health_bar_bg)
	
	# 健康条前景 - 更窄更靠下
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.min_value = 0
	health_bar.max_value = get_max_health()
	health_bar.value = current_health
	health_bar.position = Vector2(-30, -sprite_size.y / 2 - 5)
	health_bar.size = Vector2(60, 6)
	health_bar.modulate = Color(0, 1, 0)
	health_bar.step = 1
	add_child(health_bar)
	
	print("✅ 健康条已创建: 最大血量=" + str(get_max_health()))

func _update_health_bar():
	if health_bar:
		health_bar.value = current_health
		var pct = float(current_health) / float(get_max_health())
		if pct > 0.6:
			health_bar.modulate = Color(0, 1, 0)
		elif pct > 0.3:
			health_bar.modulate = Color(1, 1, 0)
		else:
			health_bar.modulate = Color(1, 0, 0)
		# 更新背景大小
		if health_bar_bg:
			health_bar_bg.size = Vector2(60, 6)

func _die():
	var player = get_tree().get_first_node_in_group("player")
	var spawner = get_tree().get_first_node_in_group("spawner")
	var audio = get_tree().get_first_node_in_group("audio_manager")
	var stats_mgr = get_tree().get_first_node_in_group("stats_manager")
	
	# 播放死亡音效
	if audio:
		if is_boss or zombie_type == "boss":
			audio.play_explode()
		else:
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
