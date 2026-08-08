# Game Over Condition Fix

## Problem
Zombies reaching player position doesn't trigger game over.

## Solution
Check Y coordinate, not distance:
```gdscript
const PLAYER_Y_SCREEN = 1100.0

if screen_y >= PLAYER_Y_SCREEN and not has_reached_player:
    has_reached_player = true
    if is_boss:
        emit_signal("game_won")
    else:
        player.take_damage(999)
        emit_signal("player_died")
    queue_free()
```

## Key Points
- Use Y coordinate check, not distance check
- Track `has_reached_player` flag to prevent double triggers
- Screen Y = position.y + 640 (coordinate conversion)
