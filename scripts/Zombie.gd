extends CharacterBody2D
class_name Zombie

const BASE_HEALTH = 10.0
const BASE_SPEED = 50.0
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
var _boss_anim_timer = 0.0  # Boss animation timer
var _boss_frame_size = 128  # Boss sprite frame size

const ZOMBIE_CONFIG = {
	"basic": {"health": 10.0, "speed": 50.0, "color": Color(0.3, 0.5, 0.3)},
	"fast": {"health": 8.0, "speed": 70.0, "color": Color(0.5, 0.3, 0.5)},
	"boss": {"health": 500.0, "speed": 30.0, "color": Color(0.8, 0.2, 0.2)}
}

func _ready():
	current_health = BASE_HEALTH
	add_to_group("zombies")
	
	collision_layer = 2  # Different from player so they collide
	collision_mask = 1   # Detect player (layer 1)
	
	# Defer collision setup to avoid "flushing queries" error
	call_deferred("_setup_collision")
	
	if is_boss or zombie_type == "boss":
		current_health = BOSS_HEALTH
		base_speed = BOSS_SPEED
		_setup_boss_sprite()
	elif zombie_type == "fast":
		base_speed = 70.0
		_setup_sprite()
	else:
		_setup_sprite()
	
	print("✅ Zombie创建: 类型=" + zombie_type + " 初始位置=中心(" + str(int(position.x)) + "," + str(int(position.y)) + ") 屏幕(" + str(int(position.x + 360)) + "," + str(int(position.y + 640)) + ")")
	print("👁️ 可见性: z_index=" + str(z_index) + " visible=" + str(visible))

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
		print("🎨 僵尸素材加载成功")
	else:
		_setup_fallback_sprite()

func _setup_boss_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.z_index = 50  # Boss should be on top
	sprite.visible = true
	
	# 创建4帧动画精灵图 (256x128 = 4帧×64x128)
	var frame_w = 64
	var frame_h = 128
	var cols = 4
	var sheet = Image.create(frame_w * cols, frame_h, false, Image.FORMAT_RGBA8)
	
	# 生成4帧 - 不同亮度的红色圆形
	for frame in range(cols):
		var x_start = frame * frame_w
		
		# 亮度变化：暗-亮-暗-亮 (模拟脉冲)
		var brightness = 0.7 + 0.3 * ((frame % 2) * 0.5 + 0.5)
		
		for px in range(frame_w):
			for py in range(frame_h):
				# 创建圆形（不同姿态）
				var cx = frame_w / 2.0
				var cy = frame_h / 2.0
				
				# 轻微位移模拟行走
				var offset_x = sin(frame * PI / 2.0) * 3.0
				var offset_y = cos(frame * PI / 2.0) * 2.0
				
				var dist = Vector2(px - cx - offset_x, py - cy).length()
				
				if dist < 50:
					# 红色身体
					var r = 0.9 * brightness
					var g = 0.2 * brightness
					var b = 0.2 * brightness
					sheet.set_pixel(x_start + px, py, Color(r, g, b, 1.0))
				elif dist < 55:
					# 边缘渐变
					sheet.set_pixel(x_start + px, py, Color(0.5, 0.1, 0.1, 0.5))
				else:
					sheet.set_pixel(x_start + px, py, Color(0, 0, 0, 0))
		
		# 画眼睛（不同位置模拟表情）
		var eye_offset = sin(frame * PI) * 2.0
		for angle in [PI * 0.3, PI * 0.7]:
			var ex = int(cx + 18 * cos(angle) + eye_offset)
			var ey = int(cy - 15 + 5 * sin(angle))
			for dx in range(-4, 4):
				for dy in range(-4, 4):
					if dx*dx + dy*dy < 16:
						sheet.set_pixel(x_start + ex + dx, ey + dy, Color(1.0, 1.0, 0.0, 1.0))
	
	var tex = ImageTexture.create_from_image(sheet)
	sprite.texture = tex
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, frame_w, frame_h)
	sprite.centered = true
	sprite.scale = Vector2(2.5, 2.5)
	add_child(sprite)
	sprite_node = sprite
	_boss_frame_size = frame_w
	print("🎨 Boss动画精灵图创建成功 (256x128, 4帧)")

func _setup_programmatic_boss(sprite: Sprite2D):
	# 创建4帧程序化Boss纹理 (128x128每帧)
	var frame_size = 128
	var sheet = Image.create(frame_size * 2, frame_size * 2, false, Image.FORMAT_RGBA8)
	
	for frame in range(4):
		var x = (frame % 2) * frame_size
		var y = (frame / 2) * frame_size
		
		# 创建红色圆形（不同亮度模拟脉冲）
		for px in range(frame_size):
			for py in range(frame_size):
				var dist = Vector2(px - frame_size/2, py - frame_size/2).length()
				var brightness = 1.0
				if frame == 1 or frame == 3:
					brightness = 1.3  # 较亮
				elif frame == 0 or frame == 2:
					brightness = 0.8  # 较暗
				
				if dist < 55:
					sheet.set_pixel(x + px, y + py, Color(brightness * 0.8, brightness * 0.2, brightness * 0.2, 1.0))
				elif dist < 60:
					sheet.set_pixel(x + px, y + py, Color(0.0, 0.0, 0.0, 0.0))  # 边缘透明
		
		# 画眼睛
		for angle in [PI * 0.3, PI * 0.7]:
			var ex = int(frame_size/2 + 20 * cos(angle))
			var ey = int(frame_size/2 + 20 * sin(angle))
			for dx in range(-5, 5):
				for dy in range(-5, 5):
					if dx*dx + dy*dy < 20:
						sheet.set_pixel(x + ex + dx, y + ey + dy, Color(1.0, 1.0, 0.0, 1.0))
	
	var tex = ImageTexture.create_from_image(sheet)
	sprite.texture = tex
	sprite.region_enabled = true
	sprite.region_rect = Rect2(0, 0, frame_size, frame_size)
	sprite.centered = true
	sprite.scale = Vector2(2.0, 2.0)
	add_child(sprite)
	sprite_node = sprite
	_boss_frame_size = frame_size
	print("🎨 Boss程序化动画纹理创建成功 (4帧)")

func _setup_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var rect = ColorRect.new()
	rect.size = Vector2(50, 70)
	var config = ZOMBIE_CONFIG.get(zombie_type, {"color": Color(0.4, 0.6, 0.4)})
	rect.color = config.color if config.has("color") else Color(0.4, 0.6, 0.4)
	sprite.add_child(rect)
	add_child(sprite)
	sprite_node = sprite

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	if is_boss or zombie_type == "boss":
		shape.radius = 60.0  # 更大的碰撞体
		shape.height = 140.0
	else:
		shape.radius = 25.0
		shape.height = 70.0
	collision.shape = shape
	add_child(collision)
	print("✅ 碰撞体创建成功")

func _to_screen_position() -> Vector2:
	return position + Vector2(360, 640)

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
		
		# 动画
		var anim_speed = 5 if (!is_boss and zombie_type != "boss") else 8
		if frame_count % anim_speed == 0 and sprite_node and sprite_node.texture and sprite_node.region_enabled:
			current_frame = (current_frame + 1) % 4
			sprite_node.region_rect = Rect2(current_frame * 64, 0, 64, 64)
		
		# Boss 动画效果（脉冲）
		if (is_boss or zombie_type == "boss") and sprite_node:
			_boss_anim_timer += delta
			var pulse = 1.0 + 0.1 * sin(_boss_anim_timer * 3.0)  # 脉动效果
			var base_scale = Vector2(2.0, 2.0)
			sprite_node.scale = base_scale * pulse
			# 同时切换帧
			if frame_count % 8 == 0:
				current_frame = (current_frame + 1) % 4
				sprite_node.region_rect = Rect2(current_frame * _boss_frame_size, 0, _boss_frame_size, _boss_frame_size)
		
		# 检查是否到达玩家位置
		var screen_pos = _to_screen_position()
		var screen_y = screen_pos.y
		
		if screen_y >= PLAYER_Y_SCREEN and not has_reached_player:
			has_reached_player = true
			print("")
			print("🚨 警报！Zombie到达玩家位置！")
			print("   类型: " + zombie_type)
			print("   屏幕Y: " + str(int(screen_y)) + " >= " + str(PLAYER_Y_SCREEN))
			print("")
			
			if is_boss or zombie_type == "boss":
				print("👹 Boss到达玩家！游戏胜利！")
				emit_signal("boss_died")
				player_node.emit_signal("game_won")
			else:
				print("❌ 僵尸到达玩家！游戏失败！")
				player_node.take_damage(999)
				player_node.emit_signal("player_died")
				emit_signal("zombie_reached_player")
			
			queue_free()
		
		# 超出屏幕底部也清除
		if screen_y > SCREEN_HEIGHT + 100:
			queue_free()

func screen_position_y() -> float:
	return position.y + 640.0

func take_damage(damage: float):
	current_health -= damage
	print("💥 Zombie受伤: 类型=" + zombie_type + " 血量=" + str(current_health))
	
	hit_flash_timer = 0.3
	modulate = Color(1, 0, 0)
	var timer = get_tree().create_timer(0.15)
	timer.timeout.connect(func():
		modulate = Color(1, 1, 1)
	)
	
	if current_health <= 0:
		_die()

func _die():
	var player = get_tree().get_first_node_in_group("player")
	var spawner = get_tree().get_first_node_in_group("spawner")
	
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
	
	print("💀 Zombie死亡！获得经验:" + str(EXPERIENCE_REWARD))
	queue_free()
