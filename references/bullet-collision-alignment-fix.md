# Bullet Collision Alignment Fix

**Date**: 2026-08-08
**Issue**: Bullets appear to disappear or miss zombies

## Problem

Collision shape was offset from visual sprite:
- Visual bullet: centered at y = -15 (above node)
- Collision shape: centered at y = 0 (at node position)

Result: Bullet visually appears higher than where collision actually occurs.

## Solution

Center collision shape with visual sprite:
```gdscript
func _setup_visuals():
    # Bullet centered at node (0,0)
    var bullet = ColorRect.new()
    bullet.size = Vector2(8, 30)
    bullet.position = Vector2(0, 0)  # CENTERED
    add_child(bullet)
    
    # Tip at top
    var tip = ColorRect.new()
    tip.position = Vector2(0, -18)  # Top
    add_child(tip)
    
    # Flame at bottom
    var flame = ColorRect.new()
    flame.position = Vector2(0, 12)  # Bottom
    add_child(flame)

func _setup_collision():
    var collision = CollisionShape2D.new()
    var shape = CapsuleShape2D.new()
    shape.radius = 6.0      # Match visual width (8px)
    shape.height = 28.0     # Match visual height (30px)
    collision.shape = shape
    add_child(collision)
```

## Changes Made

### Bullet.gd

**Before**:
```gdscript
bullet.position = Vector2(-4, -15)  # Visual offset
shape.radius = 12.0  # Too large
shape.height = 28.0
```

**After**:
```gdscript
bullet.position = Vector2(0, 0)  # Centered
shape.radius = 6.0  # Correct size
shape.height = 28.0
```

## Testing

Run headless test:
```bash
Godot_v4.7.1-stable_win64.exe --headless --quit --path "E:/godot/zombiesurvivor" --scene "res://scenes/Game.tscn" 2>&1
```

Check for:
- No ERROR lines
- "子弹碰撞体创建成功" message
- Correct bullet size

## Git Commit

```
da4c81a Fix bullet collision alignment
```

## Related Issues

- Bullets passing through zombies
- Zombie not taking damage
- Visual/collision mismatch
