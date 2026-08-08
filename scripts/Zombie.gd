extends CharacterBody2D
class_name Zombie

const BASE_HEALTH = 10.0
const BASE_SPEED = 50.0
const BOSS_HEALTH = 500.0
const BOSS_SPEED = 30.0
const DAMAGE = 10.0
const EXPERIENCE_REWARD = 10
const SCREEN_HEIGHT = 1280.0

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

const ZOMBIE_CONFIG = {
	"basic": {"health": 10.0, "speed": 50.0, "color": Color(0.3, 0.5, 0.3)},
	"fast": {"health": 8.0, "speed": 70.0, "color": Color(0.5, 0.3, 0.5)},
	"boss": {"health": 500.0, "speed": 30.0, "color": Color(0.8, 0.2, 0.2)}
}

func _ready():
	current_health = BASE_HEALTH
	add_to_group("zombies")
	
	# 碰撞层设置: zombie在layer 1，检测layer 2的子弹
	collision_layer = 1
	collision_mask = 2
	
	if is_boss or zombie_type == "boss":
		current_health = BOSS_HEALTH
		base_speed = BOSS_SPEED
		_setup_boss_sprite()
	elif zombie_type == "fast":
		base_speed = 70.0
		_setup_sprite()
	else:
		_setup_sprite()
	
	_setup_collision()
	
	print("✅ Zombie创建: 类型=" + zombie_type + " 血量=" + str(current_health) + " 速度=" + str(base_speed))

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
	
	# 使用littleboss.png作为Boss素材
	var texture_path = "res://assets/downloads/littleboss.png"
	var texture = load(texture_path)
	
	if texture:
		sprite.texture = texture
		sprite.centered = true
		# Boss体型更大
		sprite.scale = Vector2(1.5, 1.5)
		sprite.position = Vector2(0, 0)
		add_child(sprite)
		sprite_node = sprite
		print("🎨 Boss素材加载成功: littleboss.png")
	else:
		print("❌ Boss素材加载失败，使用备用样式")
		_setup_fallback_sprite()

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
		# Boss碰撞体更大
		shape.radius = 40.0
		shape.height = 100.0
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
	walk_timer += delta
	hit_flash_timer = max(0.0, hit_flash_timer - delta)
	
	var player_node = get_tree().get_first_node_in_group("player")
	var target_x_pos: float = 0.0
	var target_y_pos: float = 460.0
	
	if player_node:
		target_x_pos = player_node.position.x - 360.0
		target_y_pos = player_node.position.y - 640.0
	
	var dx = target_x_pos - position.x
	var dy = target_y_pos - position.y
	var move_dir = Vector2(dx, dy).normalized()
	position += move_dir * base_speed * delta
	
	# Boss动画帧数不同（更慢）
	var anim_speed = 5 if (!is_boss and zombie_type != "boss") else 8
	if frame_count % anim_speed == 0 and sprite_node and sprite_node.texture:
		current_frame = (current_frame + 1) % 4
		if sprite_node.region_enabled:
			sprite_node.region_rect = Rect2(current_frame * 64, 0, 64, 64)
	
	if hit_flash_timer > 0 and sprite_node:
		sprite_node.modulate = Color(1, 0.3, 0.3)
	else:
		if sprite_node:
			sprite_node.modulate = Color(1, 1, 1)
	
	if screen_position_y() > 1280 + 50:
		var player = get_tree().get_first_node_in_group("player")
		var screen_pos = _to_screen_position()
		var player_pos = player.position if player else Vector2(360, 1100)
		if player and screen_pos.distance_to(player_pos) < 60:
			if is_boss or zombie_type == "boss":
				emit_signal("boss_died")
				player.emit_signal("game_won")
			else:
				player.take_damage(DAMAGE)
				emit_signal("zombie_reached_player")
		queue_free()

func screen_position_y() -> float:
	return position.y + 640.0

func take_damage(damage: float):
	current_health -= damage
	print("💥 Zombie受伤: 类型=" + zombie_type + " 血量=" + str(current_health))
	
	hit_flash_timer = 0.2
	modulate = Color(1, 0.3, 0.3)
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func():
		modulate = Color(1, 1, 1)
	)
	
	if current_health <= 0:
		_die()

func _die():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_experience(EXPERIENCE_REWARD)
		player.add_kill()
		print("💀 Zombie死亡: 类型=" + zombie_type + " 玩家击杀数=" + str(player.kills))
	
	if is_boss or zombie_type == "boss":
		emit_signal("boss_died")
		if player:
			player.emit_signal("game_won")
	
	print("💀 Zombie死亡！获得经验:" + str(EXPERIENCE_REWARD))
	queue_free()
