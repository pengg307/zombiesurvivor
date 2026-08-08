# 僵尸生成位置调整报告

**日期**: 2026-08-08
**状态**: ✅ 已完成

---

## 修改内容

### 原位置
```gdscript
const SPAWN_LEFT_X = -100.0  # 屏幕x=260，距离左边缘260像素
const SPAWN_RIGHT_X = 100.0  # 屏幕x=460，距离右边缘260像素
```

### 新位置
```gdscript
const SPAWN_LEFT_X = -50.0   # 屏幕x=310，距离左边缘310像素
const SPAWN_RIGHT_X = 50.0    # 屏幕x=410，距离右边缘310像素
```

---

## 坐标说明

**屏幕宽度**: 720像素
**道路中央**: 屏幕x=360
**玩家位置**: 屏幕x=360 (居中)

**调整后:**
- 左侧生成: 屏幕x=310 (距离中央50像素)
- 右侧生成: 屏幕x=410 (距离中央50像素)
- 道路两侧边缘距离: 310像素

---

## Git提交
```
7e28e9b Adjust zombie spawn positions closer to road center
9589296 Fix AmmoBarrel disappearing too early
e0a59b0 Fix AmmoBarrel collision with Player
5fcb688 Fix AmmoBarrel collision with Player
974baaf Fix collision system and triple shot direction
```

---

**僵尸生成位置已调整！现在僵尸会在更靠近道路中央的位置生成。**
