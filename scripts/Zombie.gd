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
var _boss_anim_timer = 0.0

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
	else:
		_setup_fallback_sprite()

func _setup_boss_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.z_index = 50
	sprite.visible = true
	
	# 使用 bigboss.png 作为 Boss 纹理
	var boss_texture_path = "res://assets/downloads/bigboss.png"
	var boss_texture = load(boss_texture_path)
	
	if boss_texture:
		sprite.texture = boss_texture
		sprite.centered = true
		# 根据屏幕尺寸调整 scale：boss 1312x736，目标显示 ~200x112
		var target_width = 200.0
		var target_height = 112.0
		var scaleX = target_width / 1312.0
		var scaleY = target_height / 736.0
		sprite.scale = Vector2(scaleX * 2.5, scaleY * 2.5)
		print("🎨 Boss 纹理加载成功: " + boss_texture_path)
		print("  - 原始尺寸: 1312x736")
		print("  - 缩放: " + str(sprite.scale))
	else:
		print("❌ 无法加载 Boss 纹理: " + boss_texture_path)
		_setup_fallback_sprite()
	
	add_child(sprite)
	sprite_node = sprite

func _setup_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.visible = true
	
	# 创建简单的红色矩形作为 fallback
	var fallback_image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	fallback_image.fill(Color(0.8, 0.2, 0.2, 1.0))
	var fallback_texture = ImageTexture.create_from_image(fallback_image)
	sprite.texture = fallback_texture
	sprite.centered = true
	sprite.scale = Vector2(2.0, 2.0)
	
	add_child(sprite)
	sprite_node = sprite

func _physics_process(delta):
	walk_timer += delta
	
	# 移动逻辑
	var dx = target_x - position.x
	var dy = PLAYER_Y_SCREEN - 640.0 - position.y  # 转换到 centered coords
	var move_dir = Vector2(dx, dy).normalized()
	
	position += move_dir * base_speed * delta
	
	# 边界检查
	if position.y >= PLAYER_Y_SCREEN - 640.0:  # 转换到 centered coords
		_die()

func _die():
	if current_health <= 0:
		print("💀 Zombie死亡: 类型=" + zombie_type + " 玩家击杀数=" + str(player.get_kill_count()))
		# 发出死亡信号
		if zombie_type == "boss":
			boss_died.emit()
		else:
			# 通知 spawner 增加击杀计数
			if is_in_group("zombies"):
				var spawner = get_tree().get_first_node_in_group("spawner")
				if spawner:
					spawner.add_kill(zombie_type)
		
		# 获得经验
		player.add_experience(EXPERIENCE_REWARD)
		
		queue_free()

func _setup_collision():
	var collision = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	shape.radius = 30.0
	shape.height = 60.0
	collision.shape = shape
	add_child(collision)
