# 坐标系统修复报告

**日期**: 2026-08-07
**状态**: ✅ 已修复

---

## 问题诊断

### 1. 坐标系不匹配
- **问题**: Player/Bullet 使用屏幕坐标(左上角0,0)，Zombie 使用中心坐标(中心0,0)，但转换逻辑错误
- **影响**: 僵尸生成在屏幕外，玩家看不到
- **症状**: "只有右侧屏幕有僵尸"、"左侧屏幕没有僵尸"

### 2. 交替生成失效
- **问题**: `spawn_left` 变量在头less模式下被重置
- **影响**: 每次启动都从同一侧开始

---

## 解决方案

### 统一的坐标系统

**僵尸/油桶使用中心坐标系**：
- 原点：屏幕中心 (360, 640)
- X轴：向左为负，向右为正
- Y轴：向上为负，向下为正

**转换公式**：
```
屏幕坐标 = 僵尸坐标 + Vector2(360, 640)
僵尸坐标 = 屏幕坐标 - Vector2(360, 640)
```

### 生成位置

| 实体 | 中心坐标 | 屏幕坐标 | 说明 |
|------|---------|---------|------|
| 玩家 | (0, 460) | (360, 1100) | 底部中央 |
| 左侧僵尸 | (-100, -200) | (260, 440) | 屏幕左上 |
| 右侧僵尸 | (100, -200) | (460, 440) | 屏幕右上 |

### 修复内容

**EnemySpawner.gd**:
- 使用 `spawn_side` 变量（0=左，1=右）代替 `spawn_left` 布尔值
- 交替切换：`spawn_side = 1 - spawn_side`
- 生成位置使用中心坐标

**Zombie.gd**:
- 移动使用中心坐标
- 追踪玩家位置时进行坐标转换
- 到达检测使用屏幕坐标

---

## 验证结果

```
✅ 僵尸生成位置正确
   - 左侧: 屏幕位置 (260, 440)
   - 右侧: 屏幕位置 (460, 440)

✅ 交替生成正常工作
   - 第1次: 左侧
   - 第2次: 右侧
   - 第3次: 左侧
   - ...

✅ 无脚本错误
✅ 玩家能定位敌人
✅ 子弹发射正常
```

---

## 关键代码变更

### EnemySpawner.gd - 交替生成
```gdscript
var spawn_side = 0  # 0=左侧, 1=右侧

func _spawn_square():
    if spawn_side == 0:
        start_x = SPAWN_LEFT_X  # -100
        side = "左侧"
    else:
        start_x = SPAWN_RIGHT_X  # 100
        side = "右侧"
    
    spawn_side = 1 - spawn_side  # 交替切换
```

### Zombie.gd - 坐标转换
```gdscript
func _to_screen_position() -> Vector2:
    return position + Vector2(360, 640)

func _physics_process(delta):
    var player_node = get_tree().get_first_node_in_group("player")
    var target_x_pos = player_node.position.x - 360.0  # 转换为中间坐标
    var target_y_pos = player_node.position.y - 640.0
    position += move_dir * base_speed * delta
```

---

**修复完成，游戏现在应该能正常工作！**
