# Boss Spawn Trigger Pattern

## Problem
Boss doesn't spawn even after killing required number of zombies.

## Root Cause
Zombie calls `player.add_kill()` but doesn't call `spawner.add_kill()`, so `spawner.current_kills` never increments.

## Solution

### 1. Add EnemySpawner to "spawner" group
```gdscript
# EnemySpawner.gd
func _ready():
    add_to_group("spawner")  # Add this line
```

### 2. Zombie notifies spawner on death
```gdscript
# Zombie.gd
func _die():
    var spawner = get_tree().get_first_node_in_group("spawner")
    if spawner:
        spawner.add_kill()  # Critical!
        print("📊 Spawner击杀数: " + str(spawner.current_kills))
```

## Key Points
- EnemySpawner must be in "spawner" group
- Zombie._die() must call spawner.add_kill()
- BOSS_KILLS_REQUIRED constant controls when boss spawns
