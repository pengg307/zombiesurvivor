extends Node2D

func _ready():
    print("=== 测试1: 三发子弹解锁 ===")
    var player = load("res://scripts/Player.gd").new()
    add_child(player)
    player.position = Vector2(360, 1100)
    
    for i in range(7):
        player.add_kill()
        print("  Kill", i+1, ": kills =", player.kills, ", triple_shot =", player.triple_shot_unlocked)
    
    print("\n=== 测试2: 弹药桶碰撞 ===")
    var player2 = CharacterBody2D.new()
    player2.name = "Player"
    player2.add_to_group("player")
    player2.collision_layer = 2
    player2.collision_mask = 1
    player2.position = Vector2(360, 1100)
    add_child(player2)
    
    var barrel = load("res://scripts/AmmoBarrel.gd").new()
    barrel.name = "AmmoBarrel"
    barrel.position = Vector2(360, 1050)
    add_child(barrel)
    
    await get_tree().process_frame
    
    var area = barrel.get_node_or_null("CollisionArea")
    if area:
        var overlapping = area.get_overlapping_bodies()
        print("  Overlapping bodies:", overlapping.size())
        for body in overlapping:
            print("    -", body.name, "groups:", body.get_groups())
    else:
        print("  ERROR: CollisionArea not found!")
        print("  Barrel children:", barrel.get_children())
    
    print("\n=== 测试完成 ===")
