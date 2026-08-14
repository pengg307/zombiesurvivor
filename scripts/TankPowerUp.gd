extends Area2D
class_name TankPowerUp

# 火力增强包 - 从 Tank 僵尸死亡后掉落
const UPGRADE_AMOUNT = 5.0  # 每次提供 +5 伤害

var collected = false

signal power_up_collected

func _ready():
	add_to_group("powerups")
	collision_layer = 8  # 独立层，不与僵尸/子弹冲突
	collision_mask = 1   # 只检测玩家
	
	_setup_sprite()
	_setup_collision()
	
	print("🎁 火力增强包生成！")

func _setup_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var rect = ColorRect.new()
	rect.size = Vector2(40, 40)
	rect.color = Color(1, 0.5, 0.1)  # 橙色
	sprite.add_child(rect)
	add_child(sprite)
	
	# 添加文字标签
	var label = Label.new()
	label.text = "+5"
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(-10, -10)
	add_child(label)
	
	# 脉动动画
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.5)
	tween.set_loops()

func _setup_collision():
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 25.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and not collected:
		collected = true
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("apply_tank_upgrade"):
			player.apply_tank_upgrade()
			print("💥 玩家获得火力增强！当前伤害=" + str(int(player.damage_per_shot)))
		emit_signal("power_up_collected")
		_spawn_collect_effect()
		queue_free()

func _spawn_collect_effect():
	var particles = GPUParticles2D.new()
	particles.one_shot = true
	particles.amount = 15
	particles.lifetime = 0.5
	particles.emitting = true
	get_parent().add_child(particles)
	
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func(): particles.queue_free())
