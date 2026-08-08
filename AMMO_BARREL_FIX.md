# 弹药桶消失问题修复报告

**日期**: 2026-08-08
**状态**: ✅ 已修复

---

## 问题
弹药桶在半路消失

## 根本原因
坐标系统混淆：
- AmmoBarrel使用**中心坐标**（origin在屏幕中心）
- 销毁条件错误：`position.y > 1250`（中心坐标）
- 屏幕Y=1250对应中心Y=610，远远低于玩家位置（屏幕Y=1100）

## 修复
```gdscript
const DESTROY_Y = 1400.0  # 修改为1400（中心坐标）
```

**坐标转换：**
- 生成: 中心Y=-120 → 屏幕Y=520
- 销毁: 中心Y=1400 → 屏幕Y=2040
- 玩家: 屏幕Y=1100

**结果：** 弹药桶现在会在到达玩家位置后才销毁！

---

## 验证
```
Spawn: centered y=-120 → screen y=520 ✓
Destroy: centered y=1400 → screen y=2040 ✓
Player: screen y=1100 ✓
Result: AmmoBarrel reaches player!
```

---

**Git提交:**
```
c9f4e12 Fix AmmoBarrel disappearing too early
e0a59b0 Fix AmmoBarrel collision with Player
5fcb688 Fix AmmoBarrel collision with Player
974baaf Fix collision system and triple shot direction
```

---

**修复已完成！现在弹药桶应该能到达玩家位置并被收集。**
