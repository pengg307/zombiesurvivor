extends Node
class_name GameManager

var spawner = null
var ui = null
var player = null
var audio_manager = null
var weapon_upgrade_sys = null

func _ready():
	add_to_group("game_manager")
	
	spawner = get_parent().get_node_or_null("EnemySpawner")
	ui = get_parent().get_node_or_null("UI")
	player = get_parent().get_node_or_null("Player")
	audio_manager = get_parent().get_node_or_null("AudioManager")
	weapon_upgrade_sys = get_node_or_null("/root/WeaponUpgradeSystem")
	
	if ui and player:
		ui.set_player(player)
	if ui and spawner:
		ui.set_spawner(spawner)
	
	_connect_signals_deferred()

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

func _on_upgrade_available():
	print("🎁 [升级] 获得升级机会！")
	if ui:
		ui.show_upgrade_panel()

func _on_player_died():
	print("💀 玩家死亡！")
	if ui:
		ui.show_game_over(spawner.current_kills if spawner else 0)
	if spawner:
		spawner.stop()

func _on_boss_spawned():
	print("👹 Boss已出现！")

func _on_game_won():
	print("🏆 胜利！")
	if ui:
		ui.show_win(spawner.current_kills if spawner else 0)
	if spawner:
		spawner.stop()

func start_game():
	print("")
	print("========================================")
	print("🎮 [DEBUG] GameManager._start_game 被调用！")
	print("========================================")
	if spawner:
		spawner.start()
		print("  ✅ 生成器启动")
