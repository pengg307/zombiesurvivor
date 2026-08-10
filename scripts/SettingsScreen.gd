extends Control
class_name SettingsScreen

var settings_manager = null
var tutorial_manager = null

func _ready():
	hide()
	var sm = get_tree().get_first_node_in_group("settings_manager")
	if sm:
		settings_manager = sm
		print("⚙️ 设置屏幕启动")

func _show():
	show()
	_update_sliders()
	print("⚙️ 显示设置屏幕")

func _hide():
	hide()

func _update_sliders():
	if not settings_manager:
		return
	# 更新滑块显示当前值
	pass

func _on_music_volume_changed(value):
	if settings_manager:
		settings_manager.set_music_volume(value)

func _on_sfx_volume_changed(value):
	if settings_manager:
		settings_manager.set_sfx_volume(value)

func _on_master_volume_changed(value):
	if settings_manager:
		settings_manager.set_master_volume(value)

func _on_music_toggled(toggled_on):
	if settings_manager:
		settings_manager.toggle_music()

func _on_sfx_toggled(toggled_on):
	if settings_manager:
		settings_manager.toggle_sfx()

func _on_reset_pressed():
	if settings_manager:
		settings_manager.reset_settings()
		_update_sliders()
		print("⚙️ 设置已重置")

func _on_close_pressed():
	_hide()
