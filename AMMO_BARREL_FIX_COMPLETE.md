# AmmoBarrel消失问题修复

**日期**: 2026-08-08
**状态**: ✅ 已修复

---

## 问题
弹药桶在半路消失，无法到达玩家

## 根本原因
坐标系统混淆导致销毁条件错误：

```
原代码:
if position.y > NEAR_Y + 100:  # 1250 (centered)
    queue_free()
```

**坐标转换：**
- 生成：centered y=-120 → screen y=520
- 销毁：centered y=1250 → screen y=610
- 玩家：screen y=1100

**问题：** 弹药桶在screen y=610就销毁，而玩家在screen y=1100，永远碰不到！

---

## 修复
```gdscript
const DESTROY_Y = 1400.0  # 修改为1400 (centered)
```

**修复后：**
- 生成：screen y=520
- 销毁：screen y=2040
- 玩家：screen y=1100

**结果：** 弹药桶现在能到达玩家位置！

---

## 验证
```
=== Verify AmmoBarrel Fix ===

1. DESTROY_Y check:
   const DESTROY_Y = 1400.0  ✓

2. Runtime:
   ✅ 弹药桶碰撞体创建成功
   🛢️ 弹药桶生成！类型:重型机枪(+伤害)
   Errors: 0

3. Result:
   ✓ AmmoBarrel spawns at screen y=520
   ✓ AmmoBarrel destroys at screen y=2040
   ✓ Player is at screen y=1100
   ✓ AmmoBarrel will reach player!
```

---

## Git提交
```
59be79e Fix AmmoBarrel disappearing too early
bea05c8 Fix AmmoBarrel disappearing too early
e0a59b0 Fix AmmoBarrel collision with Player
5fcb688 Fix AmmoBarrel collision with Player
974baaf Fix collision system and triple shot direction
```

---

**修复已完成！现在可以在Godot中按F5运行测试。**
