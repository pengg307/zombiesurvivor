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
	
	# 不自动开始游戏，等待玩家点击"开始游戏"
	# _start_game() 由 UIManager._on_start_game() 调用

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
		if player.has_signal("upgrade_available"):
			player.upgrade_available.connect(_on_upgrade_available)
			print("✅ 已连接 upgrade_available 信号")
	
	if spawner:
		if spawner.has_signal("boss_spawned"):
			spawner.boss_spawned.connect(_on_boss_spawned)
			print("✅ 已连接 boss_spawned 信号")

func _on_upgrade_available():
	print("🎁 [升级] 获得升级机会！显示强化面板...")
	if ui:
		ui.show_upgrade_panel()

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
	# 停止生成器
	if spawner:
		spawner.spawn_timer.stop()
		print("⏹️ 生成器已停止")

func _on_boss_spawned():
	print("👹 Boss已生成！")

func _on_game_won():
	print("🏆 胜利！")
	if ui:
		ui.show_win(spawner.current_kills if spawner else 0)
	# 停止生成器
	if spawner:
		spawner.spawn_timer.stop()
		print("⏹️ 生成器已停止")

func _start_game():
	print("")
	print("========================================")
	print("🎮 [DEBUG] GameManager._start_game 被调用！")
	print("========================================")
	print("  - spawner: " + str(spawner))
	print("  - spawner 是否为 null: " + str(spawner == null))
	print("  - ui: " + str(ui))
	
	if not spawner or not ui:
		print("ERROR: 缺少必要节点 - spawner=" + str(spawner) + " ui=" + str(ui))
		return
	
	print("  - 开始启动游戏...")
	spawner.current_kills = 0
	spawner.boss_active = false
	spawner.boss_spawned_this_game = false
	spawner.wave_number = 0
	
	print("  - spawn_timer 自动启动: " + str(spawner.spawn_timer.autostart))
	print("  - spawn_timer 已停止: " + str(spawner.spawn_timer.is_stopped()))
	print("  - spawn_timer 等待时间: " + str(spawner.spawn_timer.wait_time))
	
	print("  - 启动 spawn_timer...")
	spawner.spawn_timer.start()
	
	# 等待一帧确保 timer 启动
	await get_tree().process_frame
	
	print("  - 启动后 spawn_timer 已停止: " + str(spawner.spawn_timer.is_stopped()))
	print("  - 调用 _start_next_wave()...")
	spawner._start_next_wave()
	
	print("✅ [DEBUG] 游戏启动成功！")
	print("========================================")

func reset_game():
	print("🔄 重置游戏状态...")
	# 重置生成器
	if spawner:
		spawner.current_kills = 0
		spawner.boss_active = false
		spawner.boss_spawned_this_game = false
		spawner.wave_number = 0
		spawner.spawn_timer.stop()
		print("  - Spawner 已重置")
	# 清理所有僵尸
	var zombie_count = get_tree().get_nodes_in_group("zombies").size()
	print("  - 清理前僵尸数量: " + str(zombie_count))
	for zombie in get_tree().get_nodes_in_group("zombies"):
		zombie.queue_free()
	# 清理所有子弹
	var bullet_count = get_tree().get_nodes_in_group("bullet").size()
	print("  - 清理前子弹数量: " + str(bullet_count))
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.queue_free()
	# 重置玩家状态
	if player:
		player.current_health = player.MAX_HEALTH
		player.kills = 0
		player.level = 1
		player.triple_shot_unlocked = false
		player.grenades = 0
		player.ammo_boost_timer = 0
		print("  - Player 已重置 (HP=" + str(player.MAX_HEALTH) + ", kills=0)")
	print("✅ 游戏已重置")

func restart_game():
	get_tree().reload_current_scene()
