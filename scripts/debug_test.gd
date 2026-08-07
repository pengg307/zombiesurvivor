extends Node2D

func _ready():
    print("=== 调试测试 ===")
    
    # 测试1: 检查僵尸生成坐标
    print("\n--- 测试1: 僵尸生成坐标 ---")
    var spawner = load("res://scripts/EnemySpawner.gd").new()
    add_child(spawner)
    
    await get_tree().process_frame
    
    # 测试2: 检查玩家三发子弹
    print("\n--- 测试2: 三发子弹 ---")
    var player = load("res://scripts/Player.gd").new()
    player.name = "Player"
    player.position = Vector2(360, 1100)
    add_child(player)
    
    await get_tree().process_frame
    
    print("初始状态: kills=", player.kills, "triple_shot=", player.triple_shot_unlocked)
    
    for i in range(7):
        player.add_kill()
        print(f"Kill {i+1}: kills={player.kills}, triple_shot={player.triple_shot_unlocked}")
    
    # 测试3: 检查弹药桶碰撞
    print("\n--- 测试3: 弹药桶碰撞 ---")
    var barrel = load("res://scripts/AmmoBarrel.gd").new()
    barrel.name = "AmmoBarrel"
    barrel.position = Vector2(360, 1050)
    add_child(barrel)
    
    await get_tree().process_frame
    
    var area = barrel.get_node_or_null("CollisionArea")
    if area:
        print("CollisionArea 存在")
        print("  layer:", area.collision_layer)
        print("  mask:", area.collision_mask)
        
        var overlapping = area.get_overlapping_bodies()
        print("  overlapping:", overlapping.size())
        for body in overlapping:
            print("    Body:", body.name, "groups:", body.get_groups())
    else:
        print("❌ CollisionArea 不存在!")
    
    print("\n=== 测试完成 ===")
