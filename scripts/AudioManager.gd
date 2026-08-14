extends Node
class_name AudioManager

const SOUND_PATHS = {
	"shoot": "res://assets/audio/sfx/shoot.wav",
	"hit": "res://assets/audio/sfx/hit.wav",
	"explode": "res://assets/audio/sfx/explosion.wav",
	"levelup": "res://assets/audio/sfx/upgrade.wav",
	"pickup": "res://assets/audio/sfx/upgrade.wav",
	"boss_appear": "res://assets/audio/sfx/boss.wav",
	"gameover": "res://assets/audio/sfx/game_over.wav",
	"victory": "res://assets/audio/sfx/victory.wav",
	"grenade_throw": "res://assets/audio/sfx/grenade.wav",
	"grenade_explode": "res://assets/audio/sfx/explosion.wav"
}

const BGM_PATHS = {
	"normal": "res://assets/audio/sfx/bgm.wav",
	"boss": "res://assets/audio/sfx/boss.wav"
}

var sound_effects = {}
var bgm_player = null
var music_enabled = true
var sfx_enabled = true
var master_volume = 0.8
var music_volume = 0.6
var sfx_volume = 0.7

func _ready():
	add_to_group("audio_manager")
	_init_audio()
	print("🎵 AudioManager启动")

func _init_audio():
	for sound_name in SOUND_PATHS:
		var player = AudioStreamPlayer.new()
		player.name = sound_name + "Player"
		player.volume_db = linear_to_db(sfx_volume)
		add_child(player)
		sound_effects[sound_name] = player
	
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	bgm_player.volume_db = linear_to_db(music_volume)
	add_child(bgm_player)
	
	print("✅ 音频系统初始化完成")

func play_sound(sound_name: String):
	if not sfx_enabled:
		return
	if sound_name in sound_effects:
		var player = sound_effects[sound_name]
		if player.stream:
			player.play()
		else:
			_load_and_play(player, SOUND_PATHS[sound_name])

func play_bgm(bgm_name: String):
	if not music_enabled or not bgm_player:
		return
	if bgm_name in BGM_PATHS:
		var stream = load(BGM_PATHS[bgm_name])
		if stream:
			bgm_player.stream = stream
			bgm_player.play()
			print("🎵 播放BGM: " + bgm_name)

func stop_bgm():
	if bgm_player:
		bgm_player.stop()

func play_shoot():
	play_sound("shoot")

func play_hit():
	play_sound("hit")

func play_explode():
	play_sound("explode")

func play_levelup():
	play_sound("levelup")

func play_pickup():
	play_sound("pickup")

func play_boss_appear():
	play_sound("boss_appear")
	play_bgm("boss")

func play_gameover():
	stop_bgm()
	play_sound("gameover")

func play_victory():
	stop_bgm()
	play_sound("victory")
	play_bgm("normal")

func play_grenade_throw():
	play_sound("grenade_throw")

func play_grenade_explode():
	play_sound("grenade_explode")

func _load_and_play(player: AudioStreamPlayer, path: String):
	var stream = load(path)
	if stream:
		player.stream = stream
		player.play()
	else:
		print("⚠️ 无法加载音效: " + path)

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func _update_volumes():
	if bgm_player:
		bgm_player.volume_db = linear_to_db(music_volume * master_volume)
	for sound_name in sound_effects:
		sound_effects[sound_name].volume_db = linear_to_db(sfx_volume * master_volume)

func toggle_music():
	music_enabled = !music_enabled
	if not music_enabled:
		stop_bgm()
	return music_enabled

func toggle_sfx():
	sfx_enabled = !sfx_enabled
	return sfx_enabled
