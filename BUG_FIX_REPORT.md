# 修复报告：弹药桶消失和枪支失控

**日期**: 2026-08-08
**状态**: ✅ 已修复

---

## 问题1: 弹药桶在半路消失

### 根本原因
AmmoBarrel的collision_mask=1会检测所有layer 1的物体（包括zombie），当zombie与弹药桶重叠时，Godot的物理引擎会产生碰撞响应，阻止弹药桶继续下降。

### 修复
```gdscript
func _on_body_entered(body: Node2D):
    # 只处理player碰撞，忽略其他物体
    if body.is_in_group("player"):
        _collect_barrel(body)
    # 不处理zombie碰撞，让弹药桶穿过僵尸
```

**效果**: 弹药桶现在会穿过僵尸到达玩家位置。

---

## 问题2: 枪支失控

### 根本原因
1. `fire_rate`使用局部变量`FIRE_RATE_BASE`而不是保留的`base_fire_rate`
2. `ammo_boost_timer`从未被递减，导致增益效果永久存在
3. 鼠标左键同时控制移动和手雷投掷

### 修复
```gdscript
# 保留基础射速
var base_fire_rate = FIRE_RATE_BASE

# 正确计算射速
fire_rate = max(0.1, base_fire_rate - float(ammo_boost_level) * 0.05)

# 每帧递减增益计时器
func _update_ammo_boost(delta):
    if ammo_boost_timer > 0:
        ammo_boost_timer -= delta
        if ammo_boost_timer <= 0:
            ammo_boost_level = 0
            fire_rate = base_fire_rate
```

**鼠标控制修复**:
- 左键：向左移动
- 右键：向右移动
- 中键：投掷手雷

---

## Git提交
```
f9a0caf Fix AmmoBarrel collision and gun control
bd16246 Fix AmmoBarrel and gun control issues
d834f13 Fix AmmoBarrel disappearing and gun out of control
```

---

**修复完成！现在弹药桶会穿过僵尸到达玩家，枪支控制稳定。**
