extends Area2D
class_name Bullet

const BASE_SPEED = 600.0
const SPEED_INCREMENT = 100.0
const KILL_THRESHOLD = 10
const LIFETIME = 4.0
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
	
	# 绘制子弹
	_setup_visuals()
	
	# 碰撞形状
	_setup_collision()
	
	# 死亡计时
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)
	
	print("🔫 子弹生成！位置:" + str(position) + " 方向:" + str(direction) + " 碰撞层=" + str(collision_layer) + " 掩码=" + str(collision_mask))

func _setup_visuals():
	var bullet = ColorRect.new()
	bullet.name = "BulletSprite"
	bullet.size = Vector2(8, 30)
	bullet.color = Color(1, 1, 0.3)
	bullet.position = Vector2(-4, -15)
	add_child(bullet)
	
	var tip = ColorRect.new()
	tip.name = "Tip"
	tip.size = Vector2(6, 12)
	tip.color = Color(1, 0.6, 0.1)
	tip.position = Vector2(-3, -30)
	add_child(tip)
	
	var flame = ColorRect.new()
	flame.name = "Flame"
	flame.size = Vector2(5, 15)
	flame.color = Color(1, 0.4, 0.0, 0.7)
	flame.position = Vector2(-2.5, 8)
	add_child(flame)

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 12.0
	shape.height = 28.0
	collision.shape = shape
	add_child(collision)
	print("✅ 子弹碰撞体创建成功")

func _physics_process(delta):
	position += direction * current_speed * delta
	
	_update_scale()
	
	if position.y < FAR_Y - 50 or position.y > 1400 or position.x < -50 or position.x > 770:
		queue_free()

func _update_scale():
	var depth_ratio = clamp((position.y - FAR_Y) / (NEAR_Y - FAR_Y), 0.0, 1.0)
	var node_scale = 0.5 + depth_ratio * 0.5
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
