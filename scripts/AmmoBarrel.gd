extends Node2D
class_name AmmoBarrel

const BASE_SPEED = 30.0  # 油桶滚动速度（比僵尸慢）
const FAR_Y = -300.0
const NEAR_Y = 1150.0

var current_speed = BASE_SPEED
var roll_timer = 0.0
var barrel_type = 0  # 0-2 三种不同类型的火力增强

signal barrel_collected  # 油桶被收集信号

func _ready():
	_setup_barrel()
	# 添加坐标标签（放在油桶底部）
	var label = Label.new()
	label.name = "CoordLabel"
	label.text = "(" + str(int(position.x)) + "," + str(int(position.y)) + ")"
	label.add_theme_font_size_override("font_size", 10)
	label.modulate = Color(0.3, 1, 1)  # 青色
	label.position = Vector2(-20, 30)  # 改为下方
	add_child(label)
	print("🛢️ 弹药桶生成！类型:", barrel_type)

func _setup_barrel():
	# 油桶主体（圆柱形）- 使用较浅的颜色，避免遮挡后面的僵尸
	var barrel_body = ColorRect.new()
	barrel_body.name = "BarrelBody"
	barrel_body.size = Vector2(40, 50)
	barrel_body.color = Color(0.6, 0.4, 0.2)  # 浅棕色
	barrel_body.position = Vector2(-20, -25)
	barrel_body.modulate = Color(1, 1, 1, 0.8)  # 80%透明度
	add_child(barrel_body)
	
	# 油桶条纹
	var stripe = ColorRect.new()
	stripe.name = "Stripe"
	stripe.size = Vector2(42, 8)
	stripe.color = Color(0.2, 0.15, 0.05)
	stripe.position = Vector2(-21, 0)
	add_child(stripe)
	
	# 机枪图标（用ColorRect模拟）
	var gun_icon = ColorRect.new()
	gun_icon.name = "GunIcon"
	gun_icon.size = Vector2(30, 20)
	
	# 根据类型设置不同颜色
	if barrel_type == 0:
		gun_icon.color = Color(1, 0.8, 0.2)  # 金色 - 重型机枪
	elif barrel_type == 1:
		gun_icon.color = Color(1, 0.3, 0.3)  # 红色 - 加特林
	else:
		gun_icon.color = Color(0.3, 1, 0.3)  # 绿色 - 散弹枪
	
	gun_icon.position = Vector2(-15, 10)
	add_child(gun_icon)
	
	# 机枪管（三条线）
	for i in range(3):
		var barrel_line = ColorRect.new()
		barrel_line.name = "BarrelLine" + str(i)
		barrel_line.size = Vector2(4, 15)
		barrel_line.color = Color(0.6, 0.6, 0.6)
		barrel_line.position = Vector2(-20 + i * 8, 12)
		add_child(barrel_line)
	
	# 碰撞形状（使用Area2D）
	var collision_area = Area2D.new()
	collision_area.name = "CollisionArea"
	collision_area.collision_layer = 1
	collision_area.collision_mask = 2  # 检测玩家
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape"
	var shape = CapsuleShape2D.new()
	shape.radius = 25.0
	shape.height = 45.0
	collision_shape.shape = shape
	collision_area.add_child(collision_shape)
	add_child(collision_area)
	
	# 连接碰撞信号
	collision_area.body_entered.connect(_on_body_entered)
	
	# 添加到ammo_barrels组
	add_to_group("ammo_barrels")
	
	# 滚动动画
	roll_timer = randf() * TAU

func _physics_process(delta):
	# 向前滚动移动
	position.y += current_speed * delta
	
	# 更新坐标标签
	if has_node("CoordLabel"):
		$CoordLabel.text = "(" + str(int(position.x)) + "," + str(int(position.y)) + ")"
	
	# 透视效果：越近越大
	var depth_ratio = clamp((position.y - FAR_Y) / (NEAR_Y - FAR_Y), 0.0, 1.0)
	var node_scale = 0.3 + depth_ratio * 1.5  # 远处0.3倍，近处1.8倍
	scale_node(self, node_scale)
	
	# 超出屏幕移除
	if position.y > NEAR_Y + 100:
		queue_free()

func scale_node(node: Node2D, s: float):
	node.scale = Vector2(s, s)

func _on_body_entered(body: Node2D):
	# 如果玩家碰到油桶，直接收集
	if body.is_in_group("player"):
		_collect_barrel(body)

func _collect_barrel(player: Node2D):
	print("🎯 弹药桶被收集！类型:", barrel_type)
	
	# 给予玩家火力增强
	if player.has_method("apply_ammo_boost"):
		player.apply_ammo_boost(barrel_type)
	
	# 播放收集特效
	_spawn_collect_effect()
	
	# 发出信号
	emit_signal("barrel_collected")
	
	# 移除油桶
	queue_free()

func _spawn_collect_effect():
	# 创建收集特效
	var effect = GPUParticles2D.new()
	effect.amount = 15
	effect.lifetime = 0.5
	effect.emitting = true
	effect.process_material = ParticleProcessMaterial.new()
	
	# 根据类型设置颜色
	match barrel_type:
		0:
			effect.process_material.color = Color(1, 0.8, 0.2)
		1:
			effect.process_material.color = Color(1, 0.3, 0.3)
		2:
			effect.process_material.color = Color(0.3, 1, 0.3)
	
	get_parent().add_child(effect)
	
	# 0.5秒后移除
	get_tree().create_timer(0.5).timeout.connect(func(): effect.queue_free())
