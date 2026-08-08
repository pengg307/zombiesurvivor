# 修复报告：Tank改弹药桶 + 三发子弹

**日期**: 2026-08-07
**状态**: ✅ 已修复

---

## 修复内容

### 1. Tank僵尸改为弹药桶 ✅

**修改文件**: EnemySpawner.gd, Zombie.gd, AmmoBarrel.gd

**原代码**:
```gdscript
# 僵尸类型包括tank
const ZOMBIE_CONFIG = {
    "basic": {...},
    "fast": {...},
    "tank": {"health": 25.0, "speed": 35.0, "color": Color(0.5, 0.4, 0.2)},
    "boss": {...}
}
```

**修改后**:
- 移除tank类型从僵尸配置
- 只生成basic(65%)和fast(25%)僵尸
- 50%概率生成弹药桶(AmmoBarrel)

```gdscript
const ZOMBIE_CONFIG = {
    "basic": {...},
    "fast": {...},
    "boss": {...}
}
# tank不再出现在僵尸配置中
```

### 2. 弹药桶爆炸效果 ✅

**新增功能**:
- 弹药桶被僵尸或子弹击中时爆炸
- 爆炸产生25个粒子，0.8秒生命周期
- 爆炸颜色: 橙红色火焰

**AmmoBarrel.gd**:
```gdscript
func _explode():
    print("💥 弹药桶爆炸！")
    _spawn_explosion_effect()
    queue_free()

func _spawn_explosion_effect():
    var particles = GPUParticles2D.new()
    particles.amount = 25
    particles.lifetime = 0.8
    particles.emitting = true
    # 橙红色火焰效果
```

### 3. 三发子弹验证 ✅

**代码检查**:
```
Player.gd 第303行:
    if kills == 5 and not triple_shot_unlocked:
        triple_shot_unlocked = true
        print("🎯 [解锁] 三发子弹已解锁！")
```

**验证结果**:
- ✅ triple_shot_unlocked 变量存在
- ✅ 5击杀解锁逻辑正确
- ✅ _spawn_triple_bullet 函数正确实现
- ✅ 角度spread=10度(总20度)

---

## 类型分布

| 类型 | 概率 | 说明 |
|------|------|------|
| basic | 65% | 绿色基础僵尸 |
| fast | 25% | 紫色快速僵尸 |
| boss | 击杀20后 | 红色大僵尸 |
| 弹药桶 | 50%生成 | 棕色油桶，爆炸给火力增强 |

---

## 修改文件

| 文件 | 改动 |
|------|------|
| EnemySpawner.gd | 移除tank类型，添加弹药桶生成 |
| Zombie.gd | 移除tank配置 |
| AmmoBarrel.gd | 添加爆炸效果和类型名称 |
| Player.gd | 三发子弹逻辑验证正确 |

---

**所有修复已完成！**
