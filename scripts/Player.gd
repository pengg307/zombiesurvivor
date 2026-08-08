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
signal boss_kills_changed(current: int, required: int)

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
