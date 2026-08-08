extends Area2D
class_name AmmoBarrel

const BASE_SPEED = 30.0
const FAR_Y = 80.0
const NEAR_Y = 1150.0
const DESTROY_Y = 1400.0

var current_speed = BASE_SPEED
var roll_timer = 0.0
var barrel_type = 0
var exploded = false
var spawn_time = 0.0

signal barrel_exploded

func _ready():
	# 碰撞层设置: AmmoBarrel在layer 2
	# 关键：collision_mask=1 会检测所有layer 1的物体(player和zombie)
	# 但我们只在_on_body_entered中处理player碰撞
	collision_layer = 2
	collision_mask = 1
	_setup_barrel()
	_setup_collision()
	
	var label = Label.new()
	label.name = "CoordLabel"
	label.text = "弹药桶"
	label.add_theme_font_size_override("font_size", 10)
	label.modulate = Color(1, 0.8, 0.2)
	label.position = Vector2(-20, 35)
	add_child(label)
	
	body_entered.connect(_on_body_entered)
	
	spawn_time = Time.get_ticks_msec()
	
	print("🛢️ 弹药桶生成！类型:" + _get_type_name() + " 位置=" + str(position))

func _get_type_name() -> String:
	match barrel_type:
		0: return "重型机枪(+伤害)"
		1: return "加特林(加速)"
		2: return "散弹枪(范围)"
	return "未知"

func _setup_barrel():
	var barrel_body = ColorRect.new()
	barrel_body.name = "BarrelBody"
	barrel_body.size = Vector2(40, 50)
	barrel_body.color = Color(0.8, 0.5, 0.1)
	barrel_body.position = Vector2(-20, -25)
	add_child(barrel_body)
	
	var stripe = ColorRect.new()
	stripe.name = "Stripe"
	stripe.size = Vector2(42, 10)
	stripe.color = Color(0.3, 0.2, 0.05)
	stripe.position = Vector2(-21, -5)
	add_child(stripe)
	
	var icon = ColorRect.new()
	icon.name = "Icon"
	match barrel_type:
		0: icon.color = Color(1, 0.8, 0.2)
		1: icon.color = Color(1, 0.3, 0.3)
		2: icon.color = Color(0.3, 1, 0.3)
	icon.size = Vector2(20, 20)
	icon.position = Vector2(-10, 5)
	add_child(icon)

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 25.0
	shape.height = 45.0
	collision.shape = shape
	add_child(collision)

func _physics_process(delta):
	position.y += current_speed * delta
	
	if has_node("CoordLabel"):
		$CoordLabel.text = "弹药桶 " + _get_type_name()
	
	var depth_ratio = clamp((position.y - FAR_Y) / (NEAR_Y - FAR_Y), 0.0, 1.0)
	var node_scale = 0.5 + depth_ratio * 1.0
	scale = Vector2(node_scale, node_scale)
	
	if position.y > DESTROY_Y:
		queue_free()

func _on_body_entered(body: Node2D):
	# 只处理player碰撞，忽略其他物体
	if body.is_in_group("player"):
		_collect_barrel(body)
	# 不处理zombie碰撞，让弹药桶穿过僵尸

func _collect_barrel(player: Node2D):
	print("")
	print("🎯 [弹药桶] 被玩家收集！类型:" + _get_type_name())
	
	if player.has_method("apply_ammo_boost"):
		player.apply_ammo_boost(barrel_type)
	
	_spawn_collect_effect()
	emit_signal("barrel_exploded")
	queue_free()

func _spawn_collect_effect():
	var particles = GPUParticles2D.new()
	particles.amount = 15
	particles.lifetime = 0.5
	particles.emitting = true
	particles.one_shot = true
	
	match barrel_type:
		0: particles.process_material = _create_material(Color(1, 0.8, 0.2))
		1: particles.process_material = _create_material(Color(1, 0.3, 0.3))
		2: particles.process_material = _create_material(Color(0.3, 1, 0.3))
	
	get_parent().add_child(particles)
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func(): particles.queue_free())

func _create_material(color: Color) -> ParticleProcessMaterial:
	var material = ParticleProcessMaterial.new()
	material.color = color
	material.speed_scale = 1.5
	return material
