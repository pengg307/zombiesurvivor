# 修复报告：弹药桶消失和枪支失控

**日期**: 2026-08-08
**状态**: ✅ 已修复

---

## 问题1: 弹药桶在半路消失

### 根本原因
AmmoBarrel错误地检测了zombie碰撞，导致碰到僵尸就爆炸：
```gdscript
# 原代码
elif body.is_in_group("zombies") or body.is_in_group("bullets"):
    _explode()
```

### 修复
```gdscript
# 新代码：只检测player
if body.is_in_group("player"):
    _collect_barrel(body)
# 移除zombie碰撞检测，让弹药桶穿过僵尸
```

---

## 问题2: 枪支失控

### 根本原因
鼠标左键同时控制移动和手雷投掷，导致冲突：
```gdscript
# 原代码
if event.button_index == MOUSE_BUTTON_LEFT:
    if event.pressed:
        mouse_left = true
        if grenades > 0 and grenade_cooldown <= 0:
            _throw_grenade()  # 冲突！
```

### 修复
- **鼠标左键**: 向左移动
- **鼠标右键**: 向右移动
- **鼠标中键**: 投掷手雷

---

## Git提交
```
8c3f2d1 Fix AmmoBarrel disappearing and gun out of control
636ab9b Adjust zombie spawn positions closer to road center
9b9b33e Adjust zombie spawn positions closer to road center
```

---

**修复完成！弹药桶现在会穿过僵尸到达玩家，鼠标控制也更稳定。**
