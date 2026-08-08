extends CharacterBody2D
class_name Player

const VIEWPORT_WIDTH = 720.0
const VIEWPORT_HEIGHT = 1280.0
const MOVE_SPEED = 250.0
const MAX_HEALTH = 100.0
const BASE_Y = 1100.0
const FIRE_RATE_BASE = 0.3
const SHOT_RANGE = 1200.0
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
var shoot_debug_counter = 0
var damage_per_shot: float = 10.0

signal kill_count_changed
signal ammo_boost_applied(level: int)
signal player_damaged
signal player_died
signal boss_spawned
signal game_won

func _ready():
	set_process_input(true)
	input_mode = "keyboard"
	
	collision_layer = 1
	collision_mask = 2
	add_to_group("player")
	
	position = Vector2(VIEWPORT_WIDTH / 2.0, BASE_Y)
	_setup_collision()
	_setup_character()
	_add_position_label()
	_setup_audio()
	
	print("")
	print("============================================================")
	print("🎮 Player启动！碰撞层=" + str(collision_layer) + " 掩码=" + str(collision_mask))
	print("============================================================")

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
	shape.radius = 30.0
	shape.height = 50.0
	collision.shape = shape
	add_child(collision)
	print("✅ 玩家碰撞体创建成功")

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

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_D:
			debug_mode = !debug_mode
			print("")
			print("🔧 调试模式: " + ("开启" if debug_mode else "关闭"))
			if debug_mode:
				print("   按T解锁三发子弹")
				print("   按B生成弹药桶")
				print("   按K模拟击杀")
				print("   按R重置游戏")
		elif event.keycode == KEY_T and debug_mode:
			if not triple_shot_unlocked:
				triple_shot_unlocked = true
				print("")
				print("🔓 [调试] 三发子弹已解锁！")
		elif event.keycode == KEY_B and debug_mode:
			_spawn_debug_ammo_barrel()
		elif event.keycode == KEY_K and debug_mode:
			_simulate_kill()
		elif event.keycode == KEY_R and debug_mode:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_SPACE and grenades > 0 and grenade_cooldown <= 0:
			_throw_grenade()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()
	
	elif event is InputEventScreenTouch:
		var viewport_width = get_viewport().get_visible_rect().size.x
		if event.position.x < viewport_width / 2.0:
			touch_left = event.pressed
			touch_right = false
		else:
			touch_right = event.pressed
			touch_left = false
	elif event is InputEventScreenDrag:
		var viewport_width = get_viewport().get_visible_rect().size.x
		if event.position.x < viewport_width / 2.0:
			touch_left = true
			touch_right = false
		else:
			touch_right = true
			touch_left = false
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_left = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_right = event.pressed
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed and grenades > 0 and grenade_cooldown <= 0:
				_throw_grenade()

func _physics_process(delta):
	_move(delta)
	_shoot(delta)
	_handle_grenade(delta)
	_update_ammo_boost(delta)
	_update_position_label()
	_animate(delta)
	_update_debug_info()

func _update_ammo_boost(delta):
	if ammo_boost_timer > 0:
		ammo_boost_timer -= delta
		if ammo_boost_timer <= 0:
			ammo_boost_timer = 0
			ammo_boost_level = 0
			fire_rate = base_fire_rate
			print("⏰ [弹药桶] 增益效果已过期")

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
	
	if direction.x != 0:
		position.x += direction.x * MOVE_SPEED * delta
		position.x = clamp(position.x, 30.0, VIEWPORT_WIDTH - 30.0)
	
	var prev_y = position.y
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		position.y -= MOVE_SPEED * 0.5 * delta
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		position.y += MOVE_SPEED * 0.5 * delta
	position.y = clamp(position.y, BASE_Y - 100, BASE_Y + 50)

func _shoot(delta):
	# 调试日志：每5秒打印一次状态
	shoot_debug_counter += delta
	if shoot_debug_counter >= 5.0:
		shoot_debug_counter = 0.0
		var enemies = get_tree().get_nodes_in_group("zombies")
		print("🔧 [射击调试] 僵尸数量: " + str(enemies.size()) + " fire_rate: " + str(fire_rate) + " timer: " + str(_fire_timer))
	
	fire_rate = max(0.1, base_fire_rate - float(ammo_boost_level) * 0.05)
	_fire_timer += delta
	if _fire_timer >= fire_rate:
		_fire_timer = 0.0
		_attack()

func _attack():
	var enemies = get_tree().get_nodes_in_group("zombies")
	print("🔫 [攻击检测] 僵尸数量: " + str(enemies.size()))
	
	if enemies.size() > 0:
		var nearest = _find_nearest_enemy(enemies)
		if nearest:
			# 修复：将僵尸的中心坐标转换为屏幕坐标
			var zombie_screen_pos = nearest.position + Vector2(360, 640)
			var dist = position.distance_to(zombie_screen_pos)
			print("🎯 最近僵尸距离: " + str(int(dist)) + " 射程: " + str(SHOT_RANGE))
			
			if dist <= SHOT_RANGE:
				print("✅ 僵尸在射程内，发射子弹！")
				if triple_shot_unlocked:
					_spawn_triple_bullet()
					print("🎯 [三发子弹] 发射3发子弹！")
				else:
					_spawn_bullet(Vector2(0, -1))
					print("🔫 [单发子弹] 发射1发子弹")
				
				if audio_manager:
					audio_manager.play_shoot()
			else:
				if debug_mode:
					print("❌ 僵尸超出射程")
		else:
			if debug_mode:
				print("❌ 未找到最近僵尸")
	else:
		if debug_mode:
			print("📢 当前没有僵尸")

func _find_nearest_enemy(enemies):
	var nearest = null
	var nearest_dist = SHOT_RANGE
	for enemy in enemies:
		# 修复：将僵尸的中心坐标转换为屏幕坐标
		var enemy_screen_pos = enemy.position + Vector2(360, 640)
		var dist = position.distance_to(enemy_screen_pos)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest

func _is_enemy_in_range(enemy) -> bool:
	return position.distance_to(enemy.position + Vector2(360, 640)) <= SHOT_RANGE

func _spawn_triple_bullet():
	var angle_spread = deg_to_rad(2.0)
	
	var dir_middle = Vector2(0, -1)
	_spawn_bullet(dir_middle)
	
	var dir_left = dir_middle.rotated(-angle_spread)
	_spawn_bullet(dir_left)
	
	var dir_right = dir_middle.rotated(angle_spread)
	_spawn_bullet(dir_right)

func _spawn_bullet(direction: Vector2):
	var bullet = load("res://scripts/Bullet.gd").new()
	bullet.position = position
	bullet.position.y -= 50
	bullet.direction = direction.normalized()
	bullet.damage = damage_per_shot + float(ammo_boost_level) * 5.0
	bullet.current_speed = bullet_speed
	bullet.kills_for_speed = kills
	get_parent().add_child(bullet)
	print("  🔫 子弹生成: 方向=" + str(direction) + " 伤害=" + str(bullet.damage))

func _handle_grenade(delta):
	if grenade_cooldown > 0:
		grenade_cooldown = max(0.0, grenade_cooldown - delta)

func _throw_grenade():
	if grenades > 0 and grenade_cooldown <= 0:
		grenades -= 1
		grenade_cooldown = 1.0
		var grenade = load("res://scripts/Grenade.gd").new()
		grenade.position = position
		grenade.position.y -= 50
		grenade.throw_direction = Vector2(0, -1)
		get_parent().add_child(grenade)
		if audio_manager:
			audio_manager.play_grenade_throw()
		print("💣 [手雷] 投掷手雷！剩余:" + str(grenades))

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
			print("🎯 [弹药桶] 获得重型机枪！伤害+5，持续15秒")
		1:
			ammo_boost_level = 2
			ammo_boost_timer = 10.0
			print("🎯 [弹药桶] 获得加特林！射速提升，持续10秒")
		2:
			ammo_boost_level = 3
			ammo_boost_timer = 8.0
			print("🎯 [弹药桶] 获得散弹枪！范围攻击，持续8秒")
	emit_signal("ammo_boost_applied", ammo_boost_level)

func take_damage(damage: float):
	current_health = max(0.0, current_health - damage)
	if audio_manager:
		audio_manager.play_hit()
	emit_signal("player_damaged")
	if current_health <= 0:
		emit_signal("player_died")
	print("💥 [受伤] 生命值:" + str(int(current_health)))

func add_experience(amount: int):
	experience += amount
	level = 1 + experience / 100

func add_kill():
	kills += 1
	kills_for_speed = kills
	level += 1
	print("")
	print("💀 [击杀] 当前击杀数:" + str(kills) + " 等级:" + str(level))
	
	if kills % 10 == 0:
		bullet_speed += 100.0
		print("⚡ [速度提升] 子弹速度:" + str(bullet_speed))
	
	if kills == 5 and not triple_shot_unlocked:
		triple_shot_unlocked = true
		print("")
		print("🎯 [解锁] 三发子弹已解锁！")
	
	if kills > 0 and kills % GRENADE_INTERVAL == 0 and grenades < MAX_GRENADES:
		grenades += 1
		print("💣 [手雷] 获得手雷！当前:" + str(grenades))
	
	emit_signal("kill_count_changed")

func _update_debug_info():
	if debug_mode and last_log_kill != kills:
		last_log_kill = kills
		print("")
		print("📊 [调试] 当前状态:")
		print("   - 击杀数: " + str(kills))
		print("   - 等级: " + str(level))
		print("   - 三发子弹: " + ("已解锁" if triple_shot_unlocked else "未解锁"))
		print("   - 火力等级: " + str(ammo_boost_level) + " (剩余: " + str(int(ammo_boost_timer)) + "秒)")
		print("   - 子弹速度: " + str(bullet_speed))
		print("   - 射速: " + str(fire_rate))
		print("   - 伤害: " + str(damage_per_shot))

func _spawn_debug_ammo_barrel():
	var barrel_scene = load("res://scripts/AmmoBarrel.gd")
	if barrel_scene:
		var barrel = barrel_scene.new()
		barrel.position = position + Vector2(0, -80)
		barrel.barrel_type = randi() % 3
		get_parent().add_child(barrel)
		print("🛢️ [调试] 弹药桶已生成！类型=" + str(barrel.barrel_type))

func _simulate_kill():
	print("")
	print("🎯 [调试] 模拟击杀！")
	add_kill()
