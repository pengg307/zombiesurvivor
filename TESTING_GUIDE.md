# 🎮 游戏测试指南

## ✅ 已修复的问题

### 1. GameManager节点查找
```
修复：确保子节点名称正确
• Player
• EnemySpawner
• UI
• GameManager
```

### 2. 场景结构
```
正确结构：
Game (Node2D)
├── Player (CharacterBody2D)
├── EnemySpawner (Node2D)
├── UI (CanvasLayer)
└── GameManager (Node)
```

---

## 🎮 测试步骤

### 方法1：使用Godot编辑器（推荐）
```
1. 打开Godot编辑器
   E:\godot\Godot_v4.7.1-stable_win64.exe

2. 导入项目
   • 点击 "Import" 按钮
   • 选择文件夹：E:\godot\zombiesurvivor
   • 点击 "Import & Edit"

3. 导入素材（可选）
   • 在FileSystem面板找到 assets/
   • 右键 kenney_top-down-shooter/PNG
   • 选择 "Import"
   • 等待导入完成

4. 导入音效（可选）
   • 右键 assets/audio/sfx/
   • 选择 "Import"
   • 将WAV文件拖到AudioManager对应字段

5. 按F5运行测试
```

### 方法2：命令行测试
```bash
"E:/godot/Godot_v4.7.1-stable_win64.exe" 
--headless 
--quit 
--path "E:/godot/zombiesurvivor" 
--scene "res://scenes/Game.tscn"
```

---

## 🎮 操作说明

### PC端
```
移动：WASD 或 方向键
投掷手雷：SPACE键
自动攻击：最近敌人或Boss
```

### 游戏流程
```
1. 点击 START GAME 开始
2. WASD移动，自动攻击僵尸
3. 击杀僵尸获得经验
4. 升级时选择升级选项：
   • 射击速度+1x
   • 伤害+50%
   • 生命+20
5. 每80击杀获得1个手雷
6. SPACE投掷手雷（范围伤害）
7. 击杀100个僵尸后Boss出现
8. 击败Boss获得胜利
```

---

## ⚠️ 已知问题

### 1. 音效未导入
```
状态：音效文件已生成，但未导入Godot
影响：游戏可以运行，但无声
解决：在Godot中导入WAV文件并关联
```

### 2. 移动端控制
```
状态：仅支持PC键鼠
影响：移动端无法操作
解决：需要添加虚拟摇杆和按钮
```

### 3. 素材未导入
```
状态：使用默认几何体（圆形、方形）
影响：视觉简单
解决：导入Kenney素材包
```

---

## 📊 游戏参数

### 玩家属性
```
• 初始生命：100点
• 升级增加：+10生命/级
• 初始射速：3x（0.33秒/发）
• 升级上限：5x射速
• 危险状态：≤20%血 → 1x射速
• 低血量：≤50%血 → 2x射速
```

### 僵尸属性
```
• 普通僵尸：50px/s，30HP
• 快速僵尸：70px/s，30HP
• 坦克僵尸：35px/s，60HP
• Boss：70px/s，500HP
```

### 手雷系统
```
• 获取条件：每80击杀
• 最大携带：10个
• 爆炸半径：200像素
• 普通伤害：50点
• Boss伤害：25点
```

### 回血系统
```
• 延迟时间：5秒不被击中
• 回血速度：2点/秒
• 上限：满血停止
```

---

## 🔧 后续优化建议

### 优先级1：移动端适配
```
□ 添加虚拟摇杆（移动控制）
□ 添加射击按钮
□ 添加手雷按钮
□ 添加暂停按钮
□ 触摸事件优化
```

### 优先级2：音效导入
```
□ 在Godot中导入WAV文件
□ 关联到AudioManager
□ 测试音效播放
□ 调整音量平衡
```

### 优先级3：美术优化
```
□ 导入Kenney角色素材
□ 添加更多动画
□ 添加粒子特效
□ 优化UI界面
```

### 优先级4：导出发布
```
□ 导出Android APK
□ 真机测试
□ 调试移动端问题
□ 提交应用商店
```

---

## 📝 常见问题

### Q1: 游戏无法启动
```
A: 检查场景文件路径是否正确
   确保所有脚本文件存在
   检查Godot版本兼容性（需要4.7.1+）
```

### Q2: 音效不播放
```
A: 在Godot中导入WAV文件
   将音效拖到AudioManager字段
   检查音量设置
```

### Q3: 移动端无法操作
```
A: 需要添加虚拟摇杆和按钮
   使用Godot的TouchScreenButton节点
   或第三方插件如Virtual Joystick
```

---

**现在可以在Godot编辑器中测试游戏了！** 🎮
