extends Node
class_name GameManager

var spawner = null
var ui = null
var player = null
var audio_manager = null
var weapon_upgrade_sys = null
var stats_manager = null
var settings_manager = null
var tutorial_manager = null

func _ready():
	add_to_group("game_manager")
	
	spawner = get_parent().get_node_or_null("EnemySpawner")
	ui = get_parent().get_node_or_null("UI")
	player = get_parent().get_node_or_null("Player")
	audio_manager = get_parent().get_node_or_null("AudioManager")
	weapon_upgrade_sys = get_node_or_null("/root/WeaponUpgradeSystem")
	stats_manager = get_node_or_null("/root/StatsManager")
	settings_manager = get_node_or_null("/root/SettingsManager")
	tutorial_manager = get_node_or_null("/root/TutorialOverlay")
	
	if ui and player:
		if ui.has_method("set_player"):
			ui.set_player(player)
	if ui and spawner:
		if ui.has_method("set_spawner"):
			ui.set_spawner(spawner)
	
	_connect_signals_deferred()
	
	print("")
	print("============================================================")
	print("🎮 GameManager启动！")
	print("============================================================")
	
	# 启动游戏
	_start_game()

func _start_game():
	print("🎮 启动游戏！")
	if settings_manager:
		settings_manager._apply_audio_settings()
	if spawner:
		spawner.start()
		print("  ✅ 生成器已启动")
	if audio_manager:
		audio_manager.play_bgm("normal")
		print("  ✅ BGM已播放")

func _connect_signals_deferred():
	await get_tree().process_frame
	
	if player:
		if player.has_signal("kill_count_changed"):
			player.kill_count_changed.connect(_on_kill_count_changed)
			print("✅ 已连接 kill_count_changed")
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
			print("✅ 已连接 player_died")
		if player.has_signal("game_won"):
			player.game_won.connect(_on_game_won)
			print("✅ 已连接 game_won")
		if player.has_signal("upgrade_available"):
			player.upgrade_available.connect(_on_upgrade_available)
			print("✅ 已连接 upgrade_available")
	
	if spawner:
		if spawner.has_signal("boss_spawned"):
			spawner.boss_spawned.connect(_on_boss_spawned)
			print("✅ 已连接 boss_spawned")

func _on_kill_count_changed():
	if player and weapon_upgrade_sys:
		weapon_upgrade_sys.add_kills(1)
	if stats_manager:
		stats_manager.add_kill()

func _on_upgrade_available():
	print("🎁 [升级] 获得升级机会！")
	if ui and ui.has_method("show_upgrade_panel"):
		ui.show_upgrade_panel()

func _on_player_died():
	print("💀 玩家死亡！")
	if audio_manager:
		audio_manager.play_gameover()
	if stats_manager:
		stats_manager.end_game(false)
	if ui and ui.has_method("show_game_over"):
		ui.show_game_over(spawner.current_kills if spawner else 0)
	if spawner:
		spawner.stop()

func _on_boss_spawned():
	print("👹 Boss已出现！")
	if audio_manager:
		audio_manager.play_boss_appear()

func _on_game_won():
	print("🏆 胜利！")
	if audio_manager:
		audio_manager.play_victory()
	if stats_manager:
		stats_manager.end_game(true)
	if ui and ui.has_method("show_win"):
		ui.show_win(spawner.current_kills if spawner else 0)
	if spawner:
		spawner.stop()
