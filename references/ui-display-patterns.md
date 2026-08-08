# UI Display Patterns for Godot Games

**Date**: 2026-08-08
**Project**: Zombie Survivor

## Overview

User requires all game parameters to be visible on screen in real-time. This is a hard requirement for the zombie survivor game.

## Required Displays

### Right Panel (x=600)

| Display | Position | Color | Format |
|---------|----------|-------|--------|
| HP | Top | Green | "HP: X/Y" |
| Level | Below HP | Yellow | "Lv.X" |
| Kills | Below Level | White | "Kills: X" |
| Score | Below Kills | White | "Score: X" |
| Triple Shot | Below Score | Yellow/White | "🔫 三发子弹: 已解锁/未解锁" |
| Grenades | Below Triple | Orange | "💣 手雷: X" |
| **Damage** | Below Grenades | Red | "⚔️ 伤害: 10.0" |
| **Fire Rate** | Below Damage | Green | "💨 射速: 0.30s" |
| **Bullet Speed** | Below Fire Rate | Blue | "🚀 子弹速度: 600" |
| **Ammo Boost** | Below Bullet Speed | Yellow (hidden when 0) | "🛢️ 增益: 5s" |
| **Boss Progress** | Bottom | Red | "👹 Boss进度: 3/10" |

## Implementation Pattern

```gdscript
# UIManager.gd - Add to _ready()
func _add_status_displays():
    # Damage per shot
    var damage_label = Label.new()
    damage_label.name = "DamageDisplay"
    damage_label.text = "⚔️ 伤害: 10.0"
    damage_label.position = Vector2(600, 60)
    damage_label.modulate = Color(1, 0.3, 0.3)
    damage_label.add_theme_font_size_override("font_size", 16)
    add_child(damage_label)
    
    # Fire rate
    var speed_label = Label.new()
    speed_label.name = "SpeedDisplay"
    speed_label.text = "💨 射速: 0.30s"
    speed_label.position = Vector2(600, 80)
    speed_label.modulate = Color(0.3, 1, 0.3)
    speed_label.add_theme_font_size_override("font_size", 16)
    add_child(speed_label)
    
    # ... additional displays
```

## Update Pattern

```gdscript
func _update_status():
    if player:
        if has_node("DamageDisplay"):
            $DamageDisplay.text = "⚔️ 伤害: %.1f" % player.damage_per_shot
        if has_node("SpeedDisplay"):
            $SpeedDisplay.text = "💨 射速: %.2fs" % player.fire_rate
        if has_node("BulletSpeedDisplay"):
            $BulletSpeedDisplay.text = "🚀 子弹速度: %d" % player.bullet_speed
        if player.ammo_boost_timer > 0:
            $AmmoBoostDisplay.text = "🛢️ 增益: %ds" % int(player.ammo_boost_timer)
            $AmmoBoostDisplay.visible = true
        else:
            $AmmoBoostDisplay.visible = false
```

## Player.gd Variables

```gdscript
# Add these variables to Player.gd
var damage_per_shot: float = 10.0
var level: int = 1

func add_experience(amount: int):
    experience += amount
    level = 1 + experience / 100

func apply_ammo_boost(type: int):
    match type:
        0:
            ammo_boost_level = 1
            ammo_boost_timer = 15.0
            damage_per_shot = 10.0 + 5.0  # +50% damage
```

## Common Mistakes

### Mistake 1: Using player.level without defining it
```gdscript
# ❌ WRONG - player.level doesn't exist
$LevelLabel.text = "Lv.%d" % player.level

# ✅ CORRECT - Define level in Player.gd
var level: int = 1
```

### Mistake 2: Forgetting to check has_node()
```gdscript
# ❌ WRONG - Will error if node doesn't exist
$DamageDisplay.text = "..."

# ✅ CORRECT - Always check first
if has_node("DamageDisplay"):
    $DamageDisplay.text = "..."
```

### Mistake 3: Not hiding ammo boost when expired
```gdscript
# ❌ WRONG - Label stays visible with "0s"
$AmmoBoostDisplay.text = "🛢️ 增益: 0s"

# ✅ CORRECT - Hide when expired
if player.ammo_boost_timer > 0:
    $AmmoBoostDisplay.visible = true
else:
    $AmmoBoostDisplay.visible = false
```

## Testing

Run headless test to verify:
```bash
Godot_v4.7.1-stable_win64.exe --headless --quit --path "E:/godot/zombiesurvivor" --scene "res://scenes/Game.tscn" 2>&1 | grep -E "Error|成功|启动"
```

Expected output:
- "Player启动！碰撞层=1 掩码=2"
- "UIManager初始化完成"
- No ERROR lines

## File Locations

- UIManager.gd: `scripts/UIManager.gd`
- Player.gd: `scripts/Player.gd`
- EnemySpawner.gd: `scripts/EnemySpawner.gd`

## Related Skills

- godot-game-debugging
- godot-game-dev
