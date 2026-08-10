extends Control
class_name SettingsPanel

var audio_manager = null

func _ready():
	hide()
	_setup_audio()

func _setup_audio():
	var am = get_tree().get_first_node_in_group("audio_manager")
	if am:
		audio_manager = am

func show_panel():
	visible = true
	_update_settings()

func hide_panel():
	visible = false

func _update_settings():
	# 更新设置界面
	pass

func _on_music_toggled(toggled_on):
	if audio_manager:
		audio_manager.toggle_music()
		print("🎵 音乐: " + ("开启" if toggled_on else "关闭"))

func _on_sfx_toggled(toggled_on):
	if audio_manager:
		audio_manager.toggle_sfx()
		print("🔊 音效: " + ("开启" if toggled_on else "关闭"))

func _on_master_volume_changed(value):
	if audio_manager:
		audio_manager.set_master_volume(value)

func _on_music_volume_changed(value):
	if audio_manager:
		audio_manager.set_music_volume(value)

func _on_sfx_volume_changed(value):
	if audio_manager:
		audio_manager.set_sfx_volume(value)
