extends Node
class_name GameManager

var spawner = null
var ui = null
var player = null

func _ready():
	spawner = get_parent().get_node_or_null("EnemySpawner")
	ui = get_parent().get_node_or_null("UI")
	player = get_parent().get_node_or_null("Player")
	
	print("DEBUG: spawner =", spawner)
	print("DEBUG: ui =", ui)
	print("DEBUG: player =", player)
	
	if ui and player:
		ui.set_player(player)
	if ui and spawner:
		ui.set_spawner(spawner)
	
	_start_game()

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
