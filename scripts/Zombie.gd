extends CharacterBody2D
class_name Zombie

const BASE_HEALTH = 10.0
const BASE_SPEED = 50.0
const FAST_HEALTH = 8.0
const FAST_SPEED = 70.0
const BOSS_HEALTH = 500.0
const BOSS_SPEED = 30.0
const DAMAGE = 10.0
const COLLISION_RADIUS = 50.0
const EXPERIENCE_REWARD = 10
const SAFETY_TIME = 2.0

# 透视缩放参数
const ROAD_WIDTH_TOP = 614.0
const ROAD_WIDTH_BOTTOM = 20.0
const PLAYER_Y_CENTER = 460.0
const SPAWN_Y_TOP = -450.0
const SPAWN_Y_BOTTOM = -350.0

var zombie_type = "basic"
var is_boss = false
var current_health = BASE_HEALTH
var speed = BASE_SPEED
var dead = false
var can_attack = true
var player_node = null
var player_area = null
var bullet_area = null
var sprite: Sprite2D
var health_bar_fg: ColorRect
var zombie_kills = 0
var frame_count = 0
var current_frame = 0
var boss_anim_timer = 0.0
var base_scale = 1.0

signal zombie_died
signal boss_died
signal zombie_reached_player

func _ready():
	add_to_group("zombies")
	_setup_sprite()
	_setup_collision()
	_setup_health_bar()
	
	current_health = get_max_health()
	speed = get_speed()
	
	# 根据关卡调整属性
	_apply_level_modifiers()
	
	_update_perspective()
	
	print("✅ Zombie创建: 类型=" + zombie_type + " 健康=" + str(int(current_health)) + " 速度=" + str(int(speed)))

func _apply_level_modifiers():
	var lm = get_tree().get_first_node_in_group("level_manager")
	if not lm:
		return
	
	var config = lm.get_current_config()
	
	if is_boss or zombie_type == "boss":
		# Boss 属性调整
		var boss_mult = config.boss_health_mult if config else 1.0
		current_health = BOSS_HEALTH * boss_mult
		speed = BOSS_SPEED * (1.0 / config.zombie_speed_mult if config else 1.0)
	else:
		# 普通僵尸属性调整
		var health_mult = config.zombie_health_mult if config else 1.0
		var speed_mult = config.zombie_speed_mult if config else 1.0
		
		match zombie_type:
			"fast":
				current_health = FAST_HEALTH * health_mult
				speed = FAST_SPEED * speed_mult
			_:
				current_health = BASE_HEALTH * health_mult
				speed = BASE_SPEED * speed_mult

func get_max_health() -> float:
	if is_boss or zombie_type == "boss":
		return BOSS_HEALTH
	elif zombie_type == "fast":
		return FAST_HEALTH
	return BASE_HEALTH

func get_speed() -> float:
	if is_boss or zombie_type == "boss":
		return BOSS_SPEED
	elif zombie_type == "fast":
		return FAST_SPEED
	return BASE_SPEED