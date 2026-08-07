# 🎮 升级系统说明

## ✅ 已添加的升级系统

### 1. 射击速度升级
```
初始：1x 射速
升级选项：射击速度 +1x
上限：5x 射速

效果：
• 1x → 2x → 3x → 4x → 5x
• 每次升级射速翻倍
• 子弹发射更快
```

### 2. 僵尸移动速度升级
```
初始：1x 移动速度
升级条件：玩家升级射击速度时自动触发
上限：3x 移动速度

效果：
• 僵尸移动更快
• 增加游戏难度
• 挑战玩家的反应速度
```

### 3. 通关条件
```
击杀数量：50个僵尸
进度显示：Kills: 0/50
进度条：实时显示完成百分比
胜利条件：击杀50个僵尸
```

---

## 🎯 升级选项

### 升级面板（等级提升时出现）

| 选项 | 效果 | 描述 |
|------|------|------|
| **射击速度+1x** | 射速提升 | 同时僵尸速度+0.5x |
| **伤害+50%** | 伤害提升 | 子弹伤害增加50% |
| **生命+20** | 生命提升 | 最大生命值+20 |

---

## 📊 数值配置

### 射击速度
```gdscript
# Player.gd
var fire_rate_multiplier: float = 1.0  # 初始1x
var attack_cooldown: float = 1.0        # 初始1秒/发

# 升级后
fire_rate_multiplier = 2.0  # 2x射速（0.5秒/发）
fire_rate_multiplier = 5.0  # 5x射速（0.2秒/发）
```

### 僵尸速度
```gdscript
# Zombie.gd
var speed_multiplier: float = 1.0  # 初始1x
var base_speed: float = 50.0       # 基础速度

# 升级后
speed_multiplier = 1.5  # 1.5x速度
speed_multiplier = 3.0  # 3x速度（上限）
```

### 通关条件
```gdscript
# EnemySpawner.gd
var kills_to_win: int = 50  # 需要击杀50个僵尸
var current_kills: int = 0   # 当前击杀数

# 胜利条件
if current_kills >= kills_to_win:
    emit_signal("game_won_signal")
```

---

## 🎮 游戏流程

### 开始游戏
```
1. 点击 "START GAME"
2. 使用 WASD 移动
3. 自动攻击最近敌人
```

### 升级系统
```
1. 击杀僵尸获得经验
2. 经验满后等级提升
3. 暂停并显示升级面板
4. 选择升级选项
5. 继续游戏
```

### 通关条件
```
1. 击杀50个僵尸
2. 显示进度条（Kills: X/50）
3. 达到50击杀时胜利
4. 显示 "YOU WIN!" 面板
```

---

## 🔧 可调参数

### 玩家参数（Player.gd）
```gdscript
@export var move_speed: float = 250.0    # 移动速度
@export var max_health: float = 100.0    # 最大生命
@export var attack_cooldown: float = 1.0 # 射击间隔
```

### 僵尸参数（Zombie.gd）
```gdscript
@export var health: float = 30.0         # 生命值
@export var speed: float = 50.0          # 移动速度
@export var damage: float = 10.0         # 攻击伤害
@export var experience_reward: int = 10  # 经验奖励
```

### 通关参数（EnemySpawner.gd）
```gdscript
var kills_to_win: int = 50    # 通关所需击杀数
var max_enemies: int = 20     # 同时最大敌人数量
var spawn_interval: float = 2.0  # 生成间隔
```

---

## 📝 使用说明

### PC端操作
```
WASD 或 方向键：移动
自动攻击：最近敌人
升级时：选择选项
```

### 移动端操作
```
触摸屏幕：朝触摸方向移动
自动攻击：最近敌人
升级时：点击选项按钮
```

---

## 🎨 视觉效果

### 射击效果
```
• 子弹轨迹动画
• 攻击时切换持枪姿势
• 敌人受伤闪烁
```

### 升级效果
```
• 升级光效（缩放动画）
• 进度条实时更新
• 击杀计数显示
```

### 胜利/失败
```
• 胜利：金色 "YOU WIN!" 面板
• 失败：红色 "GAME OVER" 面板
• 显示最终击杀数
```

---

**现在用Godot编辑器测试吧！** 🎮
