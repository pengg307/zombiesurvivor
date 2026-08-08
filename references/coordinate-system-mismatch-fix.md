# Coordinate System Mismatch Fix

**Date**: 2026-08-08
**Issue**: Bullets not hitting zombies due to coordinate mismatch

## Problem

Player uses SCREEN coordinates (0,0 = top-left)
Zombie uses CENTERED coordinates (0,0 = screen center at 360,640)

When Player calculates distance to zombie:
```gdscript
# ❌ WRONG - Mixing coordinate systems
var dist = position.distance_to(zombie.position)
```

Player position: Vector2(360, 1100) [screen coords]
Zombie position: Vector2(-50, -200) [centered coords]
Result: Distance is completely wrong!

## Solution

Convert zombie position to screen coordinates before distance calculation:
```gdscript
# ✅ CORRECT - Convert to same coordinate system
var zombie_screen_pos = zombie.position + Vector2(360, 640)
var dist = position.distance_to(zombie_screen_pos)
```

## Files Modified

### Player.gd

```gdscript
func _attack():
    var nearest = _find_nearest_enemy(enemies)
    if nearest:
        # Convert zombie centered coords to screen coords
        var zombie_screen_pos = nearest.position + Vector2(360, 640)
        var dist = position.distance_to(zombie_screen_pos)
        
        if dist <= SHOT_RANGE:
            _spawn_bullet(Vector2(0, -1))

func _find_nearest_enemy(enemies):
    for enemy in enemies:
        # Convert to screen coords
        var enemy_screen_pos = enemy.position + Vector2(360, 640)
        var dist = position.distance_to(enemy_screen_pos)
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = enemy
    return nearest
```

### Zombie.gd

No changes needed - zombie uses centered coords internally.
Only the distance calculation in Player needs fixing.

## Coordinate Reference

| System | Origin | Player | Zombie |
|--------|--------|--------|--------|
| Screen | Top-left (0,0) | 360, 1100 | - |
| Centered | Center (360,640) | - | -50, -200 |

**Conversion**:
- Centered → Screen: `screen = centered + Vector2(360, 640)`
- Screen → Centered: `centered = screen - Vector2(360, 640)`

## Testing

1. Headless test:
```bash
Godot_v4.7.1-stable_win64.exe --headless --quit --path "E:/godot/zombiesurvivor" --scene "res://scenes/Game.tscn" 2>&1
```

2. Check for:
- No "ERROR" lines
- "游戏启动成功!" message
- Zombie spawn positions correct

## Git Commit

```
124f825 Fix shooting coordinate mismatch and boss health
```

## Related Issues

- Bullet disappearing mid-flight
- Boss not spawning
- Zombie movement incorrect

All caused by coordinate system confusion.
