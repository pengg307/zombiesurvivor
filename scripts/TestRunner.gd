extends SceneTree

# 测试脚本：验证游戏功能

func _init():
	print("========================================")
	print("Zombie Survivor - PC测试开始")
	print("========================================")
	
	# 加载主场景
	var game_scene = load("res://scenes/Game.tscn")
	if game_scene == null:
		print("ERROR: 无法加载场景 res://scenes/Game.tscn")
		quit(1)
	
	print("✅ 场景加载成功")
	
	# 实例化场景
	var game_instance = game_scene.instantiate()
	if game_instance == null:
		print("ERROR: 无法实例化场景")
		quit(1)
	
	print("✅ 场景实例化成功")
	
	# 添加到根节点
	root.add_child(game_instance)
	print("✅ 场景添加到根节点")
	
	# 模拟运行
	print("\n========================================")
	print("测试步骤:")
	print("1. 按 WASD 或方向键移动")
	print("2. 观察敌人生成")
	print("3. 观察自动攻击")
	print("4. 观察升级面板")
	print("5. 按 ESC 暂停")
	print("========================================\n")
	
	print("游戏已启动！请手动测试。")
	print("按 F5 或点击运行按钮可重新测试。")
	
	# 不自动退出，让用户测试
	# quit(0)
