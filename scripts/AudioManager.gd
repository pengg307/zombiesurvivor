extends Node
class_name AudioManager

# 音效资源
@export var shoot_sound: AudioStream
@export var explosion_sound: AudioStream
@export var hit_sound: AudioStream
@export var grenade_sound: AudioStream
@export var upgrade_sound: AudioStream
@export var level_up_sound: AudioStream
@export var boss_spawn_sound: AudioStream
@export var game_over_sound: AudioStream
@export var victory_sound: AudioStream

# 背景音乐
@export var bgm: AudioStream
@export var bgm_volume: float = 0.3

# 音效通道索引
var sfx_bus_idx: int = -1
var music_bus_idx: int = -1
@onready var bgm_player: AudioStreamPlayer = null

func _ready():
	# 确保音效和音乐通道存在
	var bus_count = AudioServer.get_bus_count()
	sfx_bus_idx = -1
	music_bus_idx = -1
	for i in range(bus_count):
		var bus_name = AudioServer.get_bus_name(i)
		if bus_name == "SFX":
			sfx_bus_idx = i
		elif bus_name == "Music":
			music_bus_idx = i
	if sfx_bus_idx == -1:
		AudioServer.add_bus()
		sfx_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(sfx_bus_idx, "SFX")
	if music_bus_idx == -1:
		AudioServer.add_bus()
		music_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(music_bus_idx, "Music")
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(bgm_volume))

	# 创建背景音乐播放器
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	add_child(bgm_player)
	
	# 播放背景音乐
	if bgm:
		bgm_player.stream = bgm
		bgm_player.loop = true
		bgm_player.play()

func play_sfx(sound: AudioStream) -> void:
	if sound:
		var player = AudioStreamPlayer.new()
		player.stream = sound
		player.bus = "SFX"
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)

func play_shoot() -> void:
	play_sfx(shoot_sound)

func play_explosion() -> void:
	play_sfx(explosion_sound)

func play_hit() -> void:
	play_sfx(hit_sound)

func play_grenade_throw() -> void:
	play_sfx(grenade_sound)

func play_upgrade() -> void:
	play_sfx(upgrade_sound)

func play_level_up() -> void:
	play_sfx(level_up_sound)

func play_boss_spawn() -> void:
	play_sfx(boss_spawn_sound)

func play_game_over() -> void:
	play_sfx(game_over_sound)

func play_victory() -> void:
	play_sfx(victory_sound)

func stop_bgm() -> void:
	if bgm_player:
		bgm_player.stop()

func play_bgm() -> void:
	if bgm and bgm_player:
		bgm_player.play()

func set_bgm_volume(volume: float) -> void:
	bgm_volume = clamp(volume, 0.0, 1.0)
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(bgm_volume))

func set_sfx_volume(volume: float) -> void:
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(volume))
