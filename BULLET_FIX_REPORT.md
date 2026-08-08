# 子弹闪烁/消失问题修复

**日期**: 2026-08-08
**状态**: ✅ 已修复

---

## 问题
子弹有时出现后很快消失，或根本无法击中僵尸。

---

## 根本原因

### 1. 碰撞体位置偏移
- **视觉效果**: 子弹图片居中，但弹头在 y=-15
- **碰撞体**: 原来设置在节点中心 (y=0)
- **结果**: 碰撞体比视觉位置低约15像素，导致子弹"穿过"僵尸而不触发碰撞

### 2. 碰撞半径过大
- 原来 radius=12，height=28
- 实际子弹宽度只有8像素，碰撞区域过大

---

## 修复内容

### Bullet.gd 修改
```gdscript
# 碰撞体重新对齐
shape.radius = 6.0      # 从12缩小到6
shape.height = 28.0     # 高度28像素，覆盖整个子弹

# 视觉元素重新定位
bullet.position = Vector2(0, 0)      # 居中
tip.position = Vector2(0, -18)        # 顶部弹头
flame.position = Vector2(0, 12)       # 底部火焰
```

### 边界检查优化
```gdscript
# 从固定值改为使用常量
if position.y < FAR_Y - 50 or position.y > NEAR_Y + 50
```

### 生命周期调整
- LIFETIME: 4.0s → 3.0s (减少不必要的等待)

---

## 验证
- ✅ 碰撞体与视觉对齐
- ✅ 运行时0错误
- ✅ 子弹生成正常

---

## Git提交
```
da4c81a Fix bullet collision alignment
```
