extends Node2D

# 最简单的测试场景：只测试能否看见僵尸

func _ready():
	print("🧪 最简单的测试场景启动！")
	
	# 创建玩家（固定底部）
	var player = create_sprite(Vector2(360, 500), Color.BLUE, "Player")
	player.name = "Player"
	
	# 创建3个僵尸（固定顶部）
	create_sprite(Vector2(200, 100), Color.RED, "Zombie1")
	create_sprite(Vector2(360, 100), Color.RED, "Zombie2")
	create_sprite(Vector2(520, 100), Color.RED, "Zombie3")
	
	print("✅ 场景创建完成！")
	print("   玩家位置: (360, 500)")
	print("   僵尸位置: (200, 100), (360, 100), (520, 100)")
	print("   如果能看到，说明渲染正常")

func create_sprite(position: Vector2, color: Color, name: String) -> ColorRect:
	var rect = ColorRect.new()
	rect.name = name
	rect.position = position
	rect.size = Vector2(32, 32)
	rect.color = color
	add_child(rect)
	print("📍 创建了", name, "在位置", position)
	return rect
