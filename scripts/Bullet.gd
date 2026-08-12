extends Area2D
class_name Bullet

var damage = 10.0
var direction = Vector2(0, -1)
var current_speed = 600.0
var kills_for_speed = 0
var is_pierce = false
var max_distance = 1200.0
var traveled_distance = 0.0

# 透视缩放参数
const PLAYER_Y = 460.0     # 玩家在中心坐标系Y
const BULLET_SCALE_TOP = 0.4   # 远处(生成点)缩放
const BULLET_SCALE_BOTTOM = 1.2  # 近处(玩家)缩放

func _ready():
	add_to_group("bullets")
	collision_layer = 4
	collision_mask = 2  # 检测僵尸 (layer 2)
	
	# 添加精灵
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.centered = true
	var rect = ColorRect.new()
	rect.size = Vector2(6, 6)
	rect.color = Color(1, 1, 0)
	sprite.add_child(rect)
	add_child(sprite)
	
	# 添加碰撞形状
	var shape = CollisionShape2D.new()
	shape.name = "Collision"
	var circle = CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	add_child(shape)
	
	body_entered.connect(_on_body_entered)
	
	print("🔫 子弹创建！位置=(" + str(int(position.x)) + "," + str(int(position.y)) + ")")

func _physics_process(delta):
	var move = direction * current_speed * delta
	position += move
	traveled_distance += move.length()
	
	# 应用透视缩放：越远越小
	var center_y = position.y + 640.0  # 转换为中心坐标
	var t = clamp((center_y - PLAYER_Y) / (-640.0 - PLAYER_Y), 0.0, 1.0)
	var scale = lerp(BULLET_SCALE_BOTTOM, BULLET_SCALE_TOP, t)
	$Sprite.scale = Vector2(scale, scale)
	
	if traveled_distance >= max_distance:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		var final_damage = damage
		var is_critical = randf() < 0.15
		if is_critical:
			final_damage *= 2.0
		body.take_damage(final_damage)
		_show_damage_number(body, final_damage, is_critical)
		print("💥 子弹命中！伤害=" + str(int(final_damage)) + " 暴击=" + str(is_critical))
		if not is_pierce:
			queue_free()

func _show_damage_number(target, damage, is_critical):
	var number = Label.new()
	number.text = str(int(damage))
	if is_critical:
		number.text = str(int(damage)) + "!"
	number.add_theme_font_size_override("font_size", 14 if not is_critical else 20)
	number.modulate = Color(1, 1, 0.2) if is_critical else Color(1, 1, 1)
	number.position = target.position + Vector2(0, -30)
	number.z_index = 100
	get_parent().add_child(number)
	
	var tween = create_tween()
	tween.tween_property(number, "position:y", number.position.y - 40, 0.6)
	tween.tween_property(number, "modulate:a", 0, 0.6)
	tween.tween_callback(number.queue_free)