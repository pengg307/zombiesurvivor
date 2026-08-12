extends CharacterBody2D
class_name Player

const VIEWPORT_WIDTH = 720.0
const VIEWPORT_HEIGHT = 1280.0
const MOVE_SPEED = 250.0
const MAX_HEALTH = 100.0
const BASE_Y = 1100.0
const FIRE_RATE_BASE = 0.3
const SHOT_RANGE = 1500.0
const GRENADE_INTERVAL = 80
const MAX_GRENADES = 5

var current_health: float = MAX_HEALTH
var experience: int = 0
var level: int = 1
var kills: int = 0
var ammo_boost_level: int = 0
var ammo_boost_timer: float = 0.0
var fire_rate: float = FIRE_RATE_BASE
var bullet_speed: float = 600.0
var kills_for_speed: int = 0
var sprite_node: Sprite2D = null
var walk_timer: float = 0.0
var anim_frame: int = 0
var triple_shot_unlocked: bool = false
var grenades: int = 0
var grenade_cooldown: float = 0.0
var audio_manager = null
var touch_left = false
var touch_right = false
var mouse_left = false
var mouse_right = false
var input_mode = "keyboard"
var last_log_kill = -1
var debug_mode = false
var _fire_timer = 0.0
var move_direction = Vector2(0, 0)
var base_fire_rate = FIRE_RATE_BASE
var shoot_debug_counter = 0.0
var damage_per_shot: float = 10.0
var critical_chance: float = 0.0
var pierce_shot: bool = false
var bullet_count: int = 1
var regen_rate: float = 0.0
var exp_multiplier: float = 1.0
var shield: int = 0
var game_over = false
var last_attack_pos = Vector2(0, 0)
var attack_log_counter = 0
var tank_upgrade_count: int = 0  # 记录Tank击杀数

signal kill_count_changed
signal ammo_boost_applied(level: int)
signal player_damaged
signal player_died
signal boss_spawned
signal game_won
signal upgrade_available

func _ready():
	set_process_input(true)
	input_mode = "keyboard"
	game_over = false
	
	collision_layer = 1
	collision_mask = 2
	add_to_group("player")
	
	position = Vector2(VIEWPORT_WIDTH / 2.0, BASE_Y)
	_setup_collision()
	_setup_character()
	_add_position_label()
	_setup_audio()
	
	print("🎮 Player启动！位置=(" + str(int(position.x)) + "," + str(int(position.y)) + ")")
	print("   SHOT_RANGE=" + str(SHOT_RANGE) + " fire_rate=" + str(fire_rate))

func _setup_character():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var texture = load("res://assets/kenney_top-down-shooter/PNG/Man Blue/manBlue_stand.png")
	if texture:
		sprite.texture = texture
		sprite.centered = true
		add_child(sprite)
		sprite_node = sprite
		print("🎨 玩家素材加载成功")
	else:
		_setup_fallback_sprite()

func _setup_fallback_sprite():
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var rect = ColorRect.new()
	rect.size = Vector2(40, 60)
	rect.color = Color(0.2, 0.4, 0.8)
	sprite.add_child(rect)
	add_child(sprite)
	sprite_node = sprite
	print("⚠️ 使用备用玩家素材")

func _setup_collision():
	var collision = CollisionShape2D.new()
	collision.name = "Collision"
	var shape = CapsuleShape2D.new()
	shape.radius = 20.0
	shape.height = 40.0
	collision.shape = shape
	add_child(collision)
	
	var area = Area2D.new()
	area.name = "ZombieDetector"
	area.monitoring = true
	area.monitorable = true
	area.collision_layer = 1
	area.collision_mask = 2
	area.body_entered.connect(_on_zombie_detected)
	add_child(area)
	
	var shape2 = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 30.0
	shape2.shape = circle
	area.add_child(shape2)
	
	print("✅ 玩家碰撞体创建成功 (层=1, 掩码=2, 半径=30)")

func _on_zombie_detected(body):
	if body.is_in_group("zombies") and not game_over:
		print("💥 僵尸碰撞检测: " + body.name)
		game_over = true
		current_health = 0
		emit_signal("player_died")

func _add_position_label():
	var label = Label.new()
	label.name = "PositionLabel"
	label.text = "位置:" + str(int(position.x)) + "," + str(int(position.y))
	label.add_theme_font_size_override("font_size", 12)
	label.position = Vector2(0, -40)
	add_child(label)

func _setup_audio():
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am
		print("🎵 音频管理器已连接")

func _unhandled_input(event):
	if get_tree().paused or game_over:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_D:
			debug_mode = !debug_mode
		elif event.keycode == KEY_SPACE and grenades > 0 and grenade_cooldown <= 0 and not game_over:
			_throw_grenade()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()
	
	elif event is InputEventScreenTouch and not game_over:
		var viewport_width = get_viewport().get_visible_rect().size.x
		if event.position.x < viewport_width / 2.0:
			touch_left = event.pressed
			touch_right = false
		else:
			touch_right = event.pressed
			touch_left = false
	elif event is InputEventScreenDrag and not game_over:
		var viewport_width = get_viewport().get_visible_rect().size.x
		if event.position.x < viewport_width / 2.0:
			touch_left = true
			touch_right = false
		else:
			touch_right = true
			touch_left = false
	
	elif event is InputEventMouseButton and not game_over:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_left = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_right = event.pressed

func _physics_process(delta):
	if game_over:
		return
	_move(delta)
	_shoot(delta)
	_handle_grenade(delta)
	_update_ammo_boost(delta)
	_update_position_label()
	_animate(delta)
	_update_debug_info()
	if regen_rate > 0 and current_health < MAX_HEALTH:
		current_health = min(MAX_HEALTH, current_health + regen_rate * delta)

func _update_ammo_boost(delta):
	if ammo_boost_timer > 0:
		ammo_boost_timer -= delta
		if ammo_boost_timer <= 0:
			ammo_boost_timer = 0
			ammo_boost_level = 0
			fire_rate = base_fire_rate

func _move(delta):
	var direction = Vector2(0, 0)
	
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x = -1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x = 1
	
	if touch_left:
		direction.x = -1
	if touch_right:
		direction.x = 1
	
	if mouse_left:
		direction.x = -1
	if mouse_right:
		direction.x = 1
	
	if move_direction.x != 0:
		direction.x = move_direction.x
	
	if direction.x != 0:
		position.x += direction.x * MOVE_SPEED * delta
		position.x = clamp(position.x, 30.0, VIEWPORT_WIDTH - 30.0)
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		position.y -= MOVE_SPEED * 0.5 * delta
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		position.y += MOVE_SPEED * 0.5 * delta
	position.y = clamp(position.y, BASE_Y - 100, BASE_Y + 50)

func _shoot(delta):
	if game_over:
		return
	shoot_debug_counter += delta
	if shoot_debug_counter >= 1.0:
		shoot_debug_counter = 0.0
		var enemies = get_tree().get_nodes_in_group("zombies")
		print("🔧 [射击调试] 僵尸:" + str(enemies.size()) + " fire_rate:" + str(fire_rate) + " timer:" + str(_fire_timer))
	
	fire_rate = max(0.1, base_fire_rate - float(ammo_boost_level) * 0.05)
	_fire_timer += delta
	if _fire_timer >= fire_rate:
		_fire_timer = 0.0
		_attack()

func _attack():
	if game_over:
		return
	var enemies = get_tree().get_nodes_in_group("zombies")
	
	if enemies.size() > 0:
		var nearest = _find_nearest_enemy(enemies)
		if nearest:
			var zombie_screen_pos = nearest.position + Vector2(360, 640)
			var dist = position.distance_to(zombie_screen_pos)
			
			if dist <= SHOT_RANGE:
				for i in range(bullet_count):
					var angle_offset = (i - (bullet_count - 1) / 2.0) * 0.1
					var dir = Vector2(0, -1).rotated(angle_offset)
					_spawn_bullet(dir)
				
				if audio_manager:
					audio_manager.play_shoot()
				print("🔫 [攻击] 射击! 距离=" + str(int(dist)) + " 子弹数=" + str(bullet_count))
			else:
				if attack_log_counter >= 5:
					print("⚠️ [攻击] 僵尸太远: " + str(int(dist)) + "/" + str(SHOT_RANGE))
					attack_log_counter = 0
	else:
		if attack_log_counter >= 10:
			print("⚠️ [攻击] 没有僵尸")
			attack_log_counter = 0

func _find_nearest_enemy(enemies):
	var nearest = null
	var nearest_dist = SHOT_RANGE
	for enemy in enemies:
		var enemy_screen_pos = enemy.position + Vector2(360, 640)
		var dist = position.distance_to(enemy_screen_pos)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func _spawn_bullet(direction: Vector2):
	if game_over:
		return
	var bullet = load("res://scripts/Bullet.gd").new()
	bullet.position = position
	bullet.position.y -= 50
	bullet.direction = direction.normalized()
	bullet.damage = damage_per_shot + float(ammo_boost_level) * 5.0
	bullet.current_speed = bullet_speed
	bullet.kills_for_speed = kills
	bullet.is_pierce = pierce_shot
	get_parent().add_child(bullet)
	
	if audio_manager:
		audio_manager.play_shoot()
	print("🔫 [子弹] 发射! 位置=" + str(int(bullet.position.x)) + "," + str(int(bullet.position.y)))

func _handle_grenade(delta):
	if grenade_cooldown > 0:
		grenade_cooldown = max(0.0, grenade_cooldown - delta)

func _throw_grenade():
	if grenades > 0 and grenade_cooldown <= 0 and not game_over:
		grenades -= 1
		grenade_cooldown = 1.0
		var grenade = load("res://scripts/Grenade.gd").new()
		grenade.position = position
		grenade.position.y -= 50
		grenade.throw_direction = Vector2(0, -1)
		get_parent().add_child(grenade)
		if audio_manager:
			audio_manager.play_grenade_throw()
		print("💣 手雷! 剩余:" + str(grenades))

func _update_position_label():
	if has_node("PositionLabel"):
		$PositionLabel.text = "位置:" + str(int(position.x)) + "," + str(int(position.y))

func _animate(delta):
	walk_timer += delta
	if sprite_node and walk_timer >= 0.15:
		walk_timer = 0.0
		if move_direction.x != 0:
			anim_frame = (anim_frame + 1) % 2
			if sprite_node and sprite_node.texture:
				sprite_node.region_rect = Rect2(anim_frame * 64, 0, 64, 64)
	else:
		if sprite_node and sprite_node.texture:
			sprite_node.region_rect = Rect2(0, 0, 64, 64)

func apply_ammo_boost(type: int):
	match type:
		0:
			ammo_boost_level = 1
			ammo_boost_timer = 15.0
			damage_per_shot = 10.0 + 5.0
		1:
			ammo_boost_level = 2
			ammo_boost_timer = 10.0
		2:
			ammo_boost_level = 3
			ammo_boost_timer = 8.0
	emit_signal("ammo_boost_applied", ammo_boost_level)

# Tank 被击杀后的永久升级
func apply_tank_upgrade():
	tank_upgrade_count += 1
	# 永久提升子弹伤害
	damage_per_shot += 5.0
	print("💥 Tank升级！当前伤害=" + str(int(damage_per_shot)) + " (已提升" + str(tank_upgrade_count) + "次)")

func take_damage(damage: float):
	if game_over:
		return
	current_health = max(0.0, current_health - damage)
	if audio_manager:
		audio_manager.play_hit()
	emit_signal("player_damaged")
	if current_health <= 0:
		game_over = true
		emit_signal("player_died")
	print("💥 [受伤] HP=" + str(int(current_health)))

func add_kill():
	if game_over:
		return
	kills += 1
	kills_for_speed = kills
	level += 1
	if kills % 10 == 0:
		emit_signal("upgrade_available")
	emit_signal("kill_count_changed")
	print("💀 [击杀] #" + str(kills) + " Lv." + str(level))
	
	if kills % 10 == 0:
		bullet_speed += 100.0
	
	if kills == 5 and not triple_shot_unlocked:
		triple_shot_unlocked = true
		bullet_count = 3
		print("🔓 [解锁] 三发子弹!")
	
	if kills > 0 and kills % GRENADE_INTERVAL == 0 and grenades < MAX_GRENADES:
		grenades += 1
		print("💣 [手雷] 获得! 当前:" + str(grenades))
	
	emit_signal("kill_count_changed")

func add_experience(amount: int):
	if game_over:
		return
	experience += amount
	level = 1 + experience / 100

func _update_debug_info():
	if debug_mode and last_log_kill != kills:
		last_log_kill = kills
		print("📊 [调试] 击杀:" + str(kills) + " 三发:" + str(bullet_count) + " 坦克升级:" + str(tank_upgrade_count))