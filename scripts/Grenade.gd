extends Node2D
class_name Grenade

# 手雷属性
var throw_direction: Vector2 = Vector2(0, -1)
var throw_speed: float = 300.0
var explosion_radius: float = 200.0  # 爆炸半径（像素）
var explosion_damage: float = 50.0   # 爆炸伤害
var explosion_timer: float = 1.5     # 投掷后1.5秒爆炸
var fuse_timer: float = 0.0
var is_exploded: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	# 设置手雷外观
	var texture = load("res://assets/kenney_top-down-shooter/PNG/Items/item_grenade.png")
	if texture:
		sprite.texture = texture
		sprite.scale = Vector2(1.5, 1.5)
	else:
		# 如果没有手雷素材，使用圆形代替
		var circle = CircleShape2D.new()
		circle.radius = 15.0
		collision.shape = circle
		sprite.modulate = Color.ORANGE
	
	# 设置碰撞体
	collision.shape = CircleShape2D.new()
	collision.shape.radius = 15.0

func _process(delta: float):
	if is_exploded:
		return
	
	# 投掷动画
	position += throw_direction * throw_speed * delta
	
	# 旋转效果
	sprite.rotation += delta * 5.0
	
	# 检查边界
	var screen_size = get_viewport_rect().size
	if position.x < 0 or position.x > screen_size.x or \
	   position.y < 0 or position.y > screen_size.y:
		# 飞出屏幕，强制爆炸
		explosion_timer = 0.0
	
	# 计时爆炸
	fuse_timer += delta
	if fuse_timer >= explosion_timer:
		_explode()

func _explode():
	if is_exploded:
		return
	
	is_exploded = true
	
	# 爆炸效果
	_spawn_explosion_effect()
	
	# 检测范围内的敌人
	_damage_enemies_in_radius()
	
	# 销毁自己
	queue_free()

func _spawn_explosion_effect():
	# 创建爆炸粒子效果
	var explosion = Sprite2D.new()
	explosion.texture = load("res://assets/kenney_top-down-shooter/PNG/Effects/Effect_001.png")
	explosion.scale = Vector2(4, 4)
	explosion.position = position
	get_parent().add_child(explosion)
	
	# 缩放动画
	var tween = create_tween()
	tween.tween_property(explosion, "scale", Vector2(8, 8), 0.3)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.3)
	tween.tween_callback(explosion.queue_free)
	
	# 屏幕震动
	var screen_shake = get_tree().root.get_node_or_null("Game")
	if screen_shake:
		var shake_tween = create_tween()
		for i in range(5):
			shake_tween.tween_property(screen_shake, "position", 
				Vector2(randf() * 10 - 5, randf() * 10 - 5), 0.05)
		shake_tween.tween_callback(func(): 
			screen_shake.position = Vector2(0, 0)
		)

func _damage_enemies_in_radius():
	var enemies = get_tree().get_nodes_in_group("zombies")
	var boss = get_tree().get_first_node_in_group("boss")
	
	var hit_count = 0
	
	for enemy in enemies:
		var dist = position.distance_to(enemy.position)
		if dist <= explosion_radius:
			# 根据距离计算伤害（越近伤害越高）
			var damage_ratio = 1.0 - (dist / explosion_radius) * 0.5
			var damage = explosion_damage * damage_ratio
			enemy.take_damage(damage)
			hit_count += 1
	
	# 检查Boss
	if boss and boss.position.distance_to(position) <= explosion_radius:
		var damage_ratio = 1.0 - (boss.position.distance_to(position) / explosion_radius) * 0.5
		var damage = explosion_damage * damage_ratio * 0.5  # Boss伤害减半
		boss.take_damage(damage)
		hit_count += 1
		print("💥 手雷命中Boss！造成 %.0f 点伤害" % damage)
	
	if hit_count > 0:
		print("💣 手雷爆炸！命中 %d 个敌人" % hit_count)
