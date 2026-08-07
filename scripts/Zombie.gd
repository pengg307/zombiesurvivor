extends CharacterBody2D
class_name Zombie

const BASE_HEALTH = 10.0  # 小僵尸一枪死（10 HP）
const BASE_SPEED = 50.0
const DAMAGE = 10.0
const EXPERIENCE_REWARD = 10
const SCREEN_HEIGHT = 1280.0
const FAR_Y = -300.0
const NEAR_Y = 1150.0

# Boss配置
const BOSS_HEALTH = 250.0  # Boss需要25-30枪打死
const BOSS_SPEED = 70.0

@export var zombie_type: String = "basic"

var current_health = BASE_HEALTH
var base_speed = BASE_SPEED
var target_x = 360.0  # 目标X坐标（斜向移动）
var side = "左侧"  # 生成侧（用于日志）
var frame_count = 0
var sprite_node: Sprite2D = null
var walk_timer = 0.0

func _ready():
	current_health = BASE_HEALTH
	add_to_group("zombies")
	
	# 添加坐标标签（放在角色底部）
	var label = Label.new()
	label.name = "CoordLabel"
	label.text = "(" + str(int(position.x)) + "," + str(int(position.y)) + ")"
	label.add_theme_font_size_override("font_size", 10)
	label.modulate = Color(0.3, 1, 0.3)  # 绿色
	label.position = Vector2(-20, 30)  # 改为下方
	add_child(label)
	
	# 根据类型设置属性
	if zombie_type == "boss":
		current_health = BOSS_HEALTH
		base_speed = BOSS_SPEED
	elif zombie_type == "fast":
		base_speed = 70.0
	elif zombie_type == "tank":
		base_speed = 35.0
		current_health = 20.0
	
	_setup_collision()
	_setup_sprite()
	
	print("✅ Zombie已创建 - 类型:", zombie_type, "血量:", current_health)

func _setup_sprite():
	# 使用下载的僵尸素材（正面视角）
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	
	var texture = load("res://assets/downloads/zombie_front_4frames_game.png")
	
	if texture:
		sprite.texture = texture
		# 设置纹理区域，只取第一帧
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 64, 64)
		# 确保Sprite居中显示
		sprite.centered = true
		sprite.position = Vector2(0, 0)
		add_child(sprite)
		sprite_node = sprite
		print("🎨 僵尸素材加载成功 - 正面视角！")
		print("  Sprite centered:", sprite.centered)
		print("  Sprite region:", sprite.region_rect)
	else:
		print("❌ 无法加载僵尸素材，使用默认矩形")
		_setup_fallback_sprite()

func _setup_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var rect = ColorRect.new()
	rect.size = Vector2(50, 70)
	rect.color = Color(0.4, 0.6, 0.4)
	sprite.add_child(rect)
	add_child(sprite)
	sprite_node = sprite

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 25.0
	shape.height = 70.0
	collision.shape = shape
	add_child(collision)

func _update_scale():
	var depth_ratio = _get_depth_ratio()
	# 远处更小，近处更大 - 增强纵深感
	var node_scale = 0.5 + depth_ratio * 1.5  # 远处0.5倍，近处2.0倍
	
	if sprite_node:
		sprite_node.scale = Vector2(node_scale, node_scale)
		# 让僵尸"站"在道路上，根据深度调整Y偏移
		var ground_offset = (1.0 - depth_ratio) * 20.0
		sprite_node.position.y = -node_scale * 32 + ground_offset

func _get_depth_ratio() -> float:
	# 玩家Y=1100，僵尸从Y=-600开始向玩家移动
	# depth_ratio=0 表示在远处（Y=-600），depth_ratio=1 表示在玩家位置（Y=1100）
	return clamp((position.y - (-600.0)) / (1100.0 - (-600.0)), 0.0, 1.0)

func _physics_process(delta):
	frame_count += 1
	walk_timer += delta
	
	# 动态追踪玩家当前位置（每帧更新）
	# 僵尸坐标系中心是(0,0)，玩家坐标系左上角是(0,0)
	# 转换公式：zombie_x = screen_x - 360, zombie_y = screen_y - 640
	var player_screen_x = 360.0  # 默认玩家X位置（实际由玩家脚本控制）
	var player_screen_y = 1100.0  # 玩家Y位置
	
	# 获取实际玩家位置（如果玩家移动）
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_screen_x = player_node.position.x
		player_screen_y = player_node.position.y
	
	# 转换为僵尸坐标系
	var target_x_pos = player_screen_x - 360.0
	var target_y_pos = player_screen_y - 640.0
	
	var dx = target_x_pos - position.x
	var dy = target_y_pos - position.y
	# 归一化方向向量
	var move_dir = Vector2(dx, dy).normalized()
	position += move_dir * base_speed * delta
	
	# 每30帧打印一次位置
	if frame_count % 30 == 0:
		print("🚶 帧", frame_count, " - 位置:", position.x, position.y, "(" + side + ")")
		# 更新坐标标签
		if has_node("CoordLabel"):
			$CoordLabel.text = "(" + str(int(position.x)) + "," + str(int(position.y)) + ")"
		# 如果僵尸跑到另一侧，打印警告
		if side == "左侧" and position.x > 360:
			print("⚠️ 左侧僵尸跑到右侧！X=" + str(int(position.x)))
		elif side == "右侧" and position.x < 360:
			print("⚠️ 右侧僵尸跑到左侧！X=" + str(int(position.x)))
	
	# 更新透视缩放
	_update_scale()
	
	# 走路动画 - 切换帧
	if has_node("Sprite"):
		var frame = int(walk_timer * 5) % 4  # 每0.2秒切换一帧
		$Sprite.region_rect = Rect2(frame * 64, 0, 64, 64)
	
	# 超出屏幕移除
	if position.y > SCREEN_HEIGHT + 50:
		queue_free()
		print("🗑️ Zombie超出屏幕")

func take_damage(damage: float):
	current_health -= damage
	print("💥 Zombie受伤！血量:", current_health)
	
	modulate = Color.WHITE
	get_tree().create_timer(0.1).timeout.connect(func():
		modulate = Color(1, 1, 1)
	)
	
	if current_health <= 0:
		_die()

func _die():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_experience(EXPERIENCE_REWARD)
		player.add_kill()
	
	print("💀 Zombie死亡！获得经验:", EXPERIENCE_REWARD)
	queue_free()
