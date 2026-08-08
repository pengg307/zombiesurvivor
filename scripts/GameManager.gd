extends Node
class_name GameManager

var spawner = null
var ui = null
var player = null
var audio_manager = null

func _ready():
	add_to_group("game_manager")
	
	spawner = get_parent().get_node_or_null("EnemySpawner")
	ui = get_parent().get_node_or_null("UI")
	player = get_parent().get_node_or_null("Player")
	audio_manager = get_parent().get_node_or_null("AudioManager")
	
	print("DEBUG: spawner =", spawner)
	print("DEBUG: ui =", ui)
	print("DEBUG: player =", player)
	print("DEBUG: audio =", audio_manager)
	
	if ui and player:
		ui.set_player(player)
	if ui and spawner:
		ui.set_spawner(spawner)
	
	# 延迟连接信号，确保Player已完全加载
	_connect_signals_deferred()
	
	_start_game()

func _connect_signals_deferred():
	# 等待一帧确保Player脚本完全加载
	await get_tree().process_frame
	
	if player:
		# 检查Player是否有这些信号
		if player.has_signal("kill_count_changed"):
			player.kill_count_changed.connect(_on_kill_count_changed)
			print("✅ 已连接 kill_count_changed 信号")
		if player.has_signal("player_died"):
			player.player_died.connect(_on_player_died)
			print("✅ 已连接 player_died 信号")
		if player.has_signal("game_won"):
			player.game_won.connect(_on_game_won)
			print("✅ 已连接 game_won 信号")
	
	if spawner:
		if spawner.has_signal("boss_spawned"):
			spawner.boss_spawned.connect(_on_boss_spawned)
			print("✅ 已连接 boss_spawned 信号")

func _on_kill_count_changed():
	print("📊 击杀数更新，当前:", player.kills)
	# 每10击杀弹出升级面板
	if player.kills > 0 and player.kills % 10 == 0:
		if ui:
			ui.show_upgrade_panel()

func _on_player_died():
	print("💀 玩家死亡！")
	if ui:
		ui.show_game_over(spawner.current_kills if spawner else 0)

func _on_boss_spawned():
	print("👹 Boss已生成！")

func _on_game_won():
	print("🏆 胜利！")
	if ui:
		ui.show_win(spawner.current_kills if spawner else 0)

func _start_game():
	if not spawner or not ui:
		print("ERROR: 缺少必要节点")
		return
	
	spawner.current_kills = 0
	spawner.boss_active = false
	spawner.wave_number = 1
	spawner.start_wave()
	print("✅ 游戏启动成功！")

func restart_game():
	get_tree().reload_current_scene()
