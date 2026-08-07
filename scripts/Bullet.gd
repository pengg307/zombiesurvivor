extends Area2D
class_name Bullet

const BASE_SPEED = 600.0
const SPEED_INCREMENT = 100.0
const KILL_THRESHOLD = 10
const LIFETIME = 3.0
const FAR_Y = -300.0
const NEAR_Y = 1150.0

var damage = 10.0
var direction = Vector2(0, -1)
var current_speed = BASE_SPEED
var kills_for_speed = 0
var triple_shot = false  # 三发子弹模式

func _ready():
	# 绘制子弹 - 竖直长条
	var bullet = ColorRect.new()
	bullet.name = "BulletSprite"
	bullet.size = Vector2(12, 40)
	bullet.color = Color(1, 1, 0.2)
	bullet.position = Vector2(-6, -20)
	add_child(bullet)
	
	# 弹头
	var tip = ColorRect.new()
	tip.name = "Tip"
	tip.size = Vector2(10, 15)
	tip.color = Color(1, 0.5, 0.0)
	tip.position = Vector2(-5, -38)
	add_child(tip)
	
	# 尾焰
	var flame = ColorRect.new()
	flame.name = "Flame"
	flame.size = Vector2(8, 20)
	flame.color = Color(1, 0.3, 0.0)
	flame.position = Vector2(-4, 10)
	add_child(flame)
	
	# 碰撞形状
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 15.0
	shape.height = 35.0
	collision.shape = shape
	add_child(collision)
	
	# 粒子特效
	_add_particles()
	
	# 子弹垂直向上飞
	direction = Vector2(0, -1)
	
	# 死亡计时
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)
	
	# 添加坐标标签（放在子弹底部）
	var label = Label.new()
	label.name = "CoordLabel"
	label.text = "(" + str(int(position.x)) + "," + str(int(position.y)) + ")"
	label.add_theme_font_size_override("font_size", 10)
	label.modulate = Color(1, 1, 0.3)  # 黄色
	label.position = Vector2(15, 20)  # 改为下方
	add_child(label)
	print("🔫 子弹生成！位置:", position)
	# 碰撞检测
	body_entered.connect(_on_body_entered)
	
	print("🔫 子弹发射！速度:", current_speed, "大小:12x40")

func _add_particles():
	# 创建粒子系统
	var particles = GPUParticles2D.new()
	particles.name = "Particles"
	particles.amount = 10
	particles.lifetime = 0.3
	particles.explosiveness = 0.5
	particles.emitting = false
	add_child(particles)
	
	# 当子弹击中时触发粒子
	# 这里简化处理，实际需要在击中时emit
func _physics_process(delta):
	position += direction * current_speed * delta
	
	# 更新坐标标签
	if has_node("CoordLabel"):
		$CoordLabel.text = "(" + str(int(position.x)) + "," + str(int(position.y)) + ")"
	
	# 透视效果
	_update_scale()
	
	# 超出屏幕移除
	if position.y < FAR_Y - 100 or position.y > 1400 or position.x < -100 or position.x > 820:
		queue_free()

func _update_scale():
	var depth_ratio = clamp((position.y - FAR_Y) / (NEAR_Y - FAR_Y), 0.0, 1.0)
	var node_scale = 0.4 + depth_ratio * 0.6
	scale_node(self, node_scale)

func scale_node(node: Node2D, s: float):
	node.scale = Vector2(s, s)

func _on_body_entered(body: Node2D):
	if body.is_in_group("zombies"):
		body.take_damage(damage)
		queue_free()
		print("✅ 子弹击中僵尸！")
	elif body.is_in_group("player"):
		queue_free()
