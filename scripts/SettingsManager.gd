extends Node
class_name SettingsManager

var settings = {
	"music_volume": 0.6,
	"sfx_volume": 0.7,
	"master_volume": 0.8,
	"music_enabled": true,
	"sfx_enabled": true,
	"vibration_enabled": true,
	"tutorial_seen": false,
	"fullscreen": false
}

var audio_manager = null
var stats_manager = null

func _ready():
	add_to_group("settings_manager")
	_load_settings()
	_setup_audio()
	print("⚙️ SettingsManager启动")

func _setup_audio():
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am
		_apply_audio_settings()

func _load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		for key in settings:
			if config.has_section_key("settings", key):
				settings[key] = config.get_value("settings", key)
		print("💾 设置已加载")
	else:
		print("⚙️ 使用默认设置")

func _save_settings():
	var config = ConfigFile.new()
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save("user://settings.cfg")
	print("💾 设置已保存")

func _apply_audio_settings():
	if audio_manager:
		audio_manager.set_master_volume(settings["master_volume"])
		audio_manager.set_music_volume(settings["music_volume"])
		audio_manager.set_sfx_volume(settings["sfx_volume"])
		audio_manager.toggle_music()
		audio_manager.toggle_sfx()

func toggle_music():
	settings["music_enabled"] = not settings["music_enabled"]
	if audio_manager:
		audio_manager.toggle_music()
	_save_settings()
	return settings["music_enabled"]

func toggle_sfx():
	settings["sfx_enabled"] = not settings["sfx_enabled"]
	if audio_manager:
		audio_manager.toggle_sfx()
	_save_settings()
	return settings["sfx_enabled"]

func set_music_volume(value: float):
	settings["music_volume"] = clamp(value, 0.0, 1.0)
	_apply_audio_settings()
	_save_settings()

func set_sfx_volume(value: float):
	settings["sfx_volume"] = clamp(value, 0.0, 1.0)
	_apply_audio_settings()
	_save_settings()

func set_master_volume(value: float):
	settings["master_volume"] = clamp(value, 0.0, 1.0)
	_apply_audio_settings()
	_save_settings()

func reset_settings():
	settings = {
		"music_volume": 0.6,
		"sfx_volume": 0.7,
		"master_volume": 0.8,
		"music_enabled": true,
		"sfx_enabled": true,
		"vibration_enabled": true,
		"tutorial_seen": false,
		"fullscreen": false
	}
	_apply_audio_settings()
	_save_settings()
	print("⚙️ 设置已重置为默认值")

func is_tutorial_seen() -> bool:
	return settings["tutorial_seen"]

func set_tutorial_seen(visited: bool):
	settings["tutorial_seen"] = visited
	_save_settings()
