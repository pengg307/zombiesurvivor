extends Area2D
class_name Bullet

const BASE_SPEED = 600.0
const SPEED_INCREMENT = 100.0
const KILL_THRESHOLD = 10
const LIFETIME = 3.0
const FAR_Y = 80.0
const NEAR_Y = 1150.0

var damage = 10.0
var direction = Vector2(0, -1)
var current_speed = BASE_SPEED
var kills_for_speed = 0
var triple_shot = false

func _ready():
	# 设置碰撞层: bullet在layer 2，检测layer 1的僵尸
	collision_layer = 2
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	
	# 绘制子弹 - 更大的黄色矩形，确保可见
	_setup_visuals()
	
	# 碰撞形状（与视觉对齐）
	call_deferred("_setup_collision")
	
	# 死亡计时
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)
	
	print("🔫 子弹生成！位置:" + str(position) + " 方向:" + str(direction) + " 碰撞层=" + str(collision_layer) + " 掩码=" + str(collision_mask))

func _setup_visuals():
	# 子弹主体 - 大黄色矩形，非常显眼
	var bullet = ColorRect.new()
	bullet.name = "BulletSprite"
	bullet.size = Vector2(12, 40)  # 更大
	bullet.color = Color(1, 1, 0)  # 纯黄色，更亮
	bullet.position = Vector2(0, 0)  # 居中
	add_child(bullet)
	
	# 弹头 - 橙色三角形
	var tip = ColorRect.new()
	tip.name = "Tip"
	tip.size = Vector2(10, 15)
	tip.color = Color(1, 0.8, 0)
	tip.position = Vector2(0, -25)  # 顶部
	add_child(tip)
	
	# 火焰 - 红色
	var flame = ColorRect.new()
	flame.name = "Flame"
	flame.size = Vector2(8, 20)
	flame.color = Color(1, 0.3, 0)
	flame.position = Vector2(0, 20)  # 底部
	add_child(flame)
	
	print("🎨 子弹视觉创建成功: 12x40黄色矩形")

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 8.0  # 更大的碰撞体
	shape.height = 35.0
	collision.shape = shape
	add_child(collision)
	print("✅ 子弹碰撞体创建成功")

func _physics_process(delta):
	position += direction * current_speed * delta
	
	_update_scale()
	
	# 检查边界（基于屏幕坐标）
	if position.y < FAR_Y - 50 or position.y > NEAR_Y + 50 or position.x < -50 or position.x > 770:
		queue_free()

func _update_scale():
	# 根据y位置调整大小（透视效果）
	var depth_ratio = clamp((position.y - FAR_Y) / (NEAR_Y - FAR_Y), 0.0, 1.0)
	var node_scale = 0.6 + depth_ratio * 0.4
	scale = Vector2(node_scale, node_scale)

func _on_body_entered(body: Node2D):
	print("🎯 子弹碰撞检测: 碰到 " + body.name + " 碰撞层=" + str(body.collision_layer) + " 在group: " + str(body.get_groups()))
	
	if body.is_in_group("zombies"):
		body.take_damage(damage)
		queue_free()
		print("✅ 子弹击中僵尸！伤害:" + str(damage))
	elif body.is_in_group("player"):
		queue_free()
		print("⚠️ 子弹击中玩家！")
	else:
		queue_free()
