extends CharacterBody2D
class_name ExplorerZombie

const BASE_HEALTH = 5.0
const BASE_SPEED = 60.0
const EXPLOSION_RADIUS = 100.0
const EXPERIENCE_REWARD = 15
const SCREEN_HEIGHT = 1280.0
const PLAYER_Y_SCREEN = 1100.0

var current_health = BASE_HEALTH
var sprite_node: Sprite2D = null
var walk_timer = 0.0
var current_frame = 0
var health_bar: ProgressBar = null
var health_bar_bg: ColorRect = null
var sprite_size = Vector2(48, 48)
var is_exploding = false

func _ready():
	add_to_group("zombies")
	collision_layer = 2
	collision_mask = 1
	call_deferred("_setup_collision")
	_setup_sprite()
	_create_health_bar()
	print("✅ ExplorerZombie创建: 血量=" + str(BASE_HEALTH) + " 速度=" + str(BASE_SPEED))

func _setup_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var texture = load("res://assets/downloads/zombie_front_4frames_game.png")
	if texture:
		sprite.texture = texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 64, 64)
		sprite.centered = true
		add_child(sprite)
		sprite_node = sprite
	else:
		_setup_fallback_sprite()

func _setup_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var rect = ColorRect.new()
	rect.size = Vector2(48, 48)
	rect.color = Color(0.5, 0.5, 0.3)
	sprite.add_child(rect)
	add_child(sprite)
	sprite_node = sprite

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 24.0
	shape.height = 40.0
	collision.shape = shape
	add_child(collision)
	
	var area = Area2D.new()
	area.name = "PlayerDetector"
	area.collision_layer = 2
	area.collision_mask = 1
	area.body_entered.connect(_on_player_detected)
	add_child(area)

func _on_player_detected(body):
	if body.is_in_group("player") and not is_exploding:
		is_exploding = true
		_explode()

func _explode():
	# 创建爆炸效果
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = get_global_position().distance_to(player.global_position)
		if distance < EXPLOSION_RADIUS:
			player.take_damage(30)
	
	# 销毁自身
	queue_free()

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player and not is_exploding:
		# 玩家屏幕坐标 -> 僵尸中心坐标
		var target_center = player.position - Vector2(360, 640)
		# 到达玩家Y行后只在X轴移动，收敛到玩家正上方
		if position.y >= target_center.y - 5.0:
			target_center.y = position.y
		var move_dir = (target_center - position).normalized()
		position += move_dir * BASE_SPEED * delta
		
		walk_timer += delta
		if sprite_node and walk_timer >= 0.15:
			walk_timer = 0.0
			current_frame = (current_frame + 1) % 4
			if sprite_node.texture:
				sprite_node.region_rect = Rect2(current_frame * 64, 0, 64, 64)
		
		if get_global_position().distance_to(player.global_position) <= 50.0:
			_explode()

func take_damage(damage: float):
	current_health -= damage
	modulate = Color(1, 0, 0)
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): modulate = Color(1, 1, 1))
	_update_health_bar()
	if current_health <= 0:
		_die()

func _die():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_kill()
		player.add_experience(EXPERIENCE_REWARD)
	if health_bar:
		health_bar.queue_free()
	if health_bar_bg:
		health_bar_bg.queue_free()
	queue_free()

func _create_health_bar():
	health_bar_bg = ColorRect.new()
	health_bar_bg.name = "HealthBarBG"
	health_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	health_bar_bg.position = Vector2(-24, -32)
	health_bar_bg.size = Vector2(48, 6)
	add_child(health_bar_bg)
	
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.min_value = 0
	health_bar.max_value = BASE_HEALTH
	health_bar.value = BASE_HEALTH
	health_bar.position = Vector2(-24, -32)
	health_bar.size = Vector2(48, 6)
	health_bar.modulate = Color(0, 1, 0)
	add_child(health_bar)

func _update_health_bar():
	if health_bar:
		health_bar.value = current_health
		var pct = float(current_health) / BASE_HEALTH
		if pct > 0.6:
			health_bar.modulate = Color(0, 1, 0)
		elif pct > 0.3:
			health_bar.modulate = Color(1, 1, 0)
		else:
			health_bar.modulate = Color(1, 0, 0)
