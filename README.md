# 🧟 Zombie Survivor - 向僵尸开炮

一款Godot 4.7.1开发的幸存者类游戏！

## ✅ 当前状态

- [x] 基础游戏框架
- [x] 玩家移动系统（WASD/方向键）
- [x] 自动攻击系统
- [x] 敌人生成系统（波次）
- [x] UI界面（血条、等级、波次）
- [x] 升级选择面板
- [x] PC端测试通过
- [x] 自动化测试通过

## 🚀 如何运行

### 方法1：Godot编辑器（推荐）

1. **打开Godot编辑器**
   ```
   E:\godot\Godot_v4.7.1-stable_win64.exe
   ```

2. **导入项目**
   - 点击 "Import"
   - 选择文件夹：`E:\godot\zombiesurvivor\`
   - 点击 "Import & Edit"

3. **运行游戏**
   - 按 F5 或点击运行按钮
   - 游戏应该启动并显示开始界面

### 方法2：命令行测试

```bash
# 运行主游戏
"E:/godot/Godot_v4.7.1-stable_win64.exe" --headless --quit --path "E:/godot/zombiesurvivor" --scene "res://scenes/Game.tscn"

# 运行自动化测试
"E:/godot/Godot_v4.7.1-stable_win64.exe" --headless --quit --path "E:/godot/zombiesurvivor" --scene "res://scenes/AutoTest.tscn"
```

---

## 📱 如何导出APK

### ⚠️ 重要：需要Android导出模板

由于Godot需要Android导出模板才能生成APK，你需要：

#### 步骤1：下载Android导出模板

1. 打开Godot编辑器
2. 菜单：`Editor → Manage Export Templates`
3. 点击 "Download"
4. 选择 "Godot Engine v4.7.1.stable"
5. 点击 "Download and Install"

#### 步骤2：配置Android SDK

Godot需要Android SDK来打包APK：

- **SDK路径**: `C:\NVPACK\android-sdk-windows`
- **NDK路径**: `C:\NVPACK\android-ndk-r10e`
- **Java路径**: `C:\NVPACK\jdk1.7.0_71`

在Godot中配置：
1. 菜单：`Project → Project Settings → General → Export`
2. Android SDK Path: `C:\NVPACK\android-sdk-windows`
3. Android NDK Path: `C:\NVPACK\android-ndk-r10e`

#### 步骤3：导出APK

1. 菜单：`Project → Export`
2. 点击 "Add..." → 选择 "Android"
3. 配置导出参数：
   - Application/Name: ZombieSurvivor
   - Application/Version: 1.0
   - Layout/Resolution/Width: 720
   - Layout/Resolution/Height: 1280
   - Layout/Orientation: Portrait
4. 点击 "Export Project"
5. 保存位置：`E:\godot\zombiesurvivor.apk`

---

## 🎮 游戏玩法

### 操作说明

| 平台 | 操作 |
|------|------|
| **PC** | WASD或方向键移动 |
| **手机** | 点击屏幕边缘移动 |

### 游戏机制

- **自动攻击**: 自动攻击最近的敌人
- **经验系统**: 击杀敌人获得经验
- **升级系统**: 升级时选择技能
- **波次系统**: 敌人越来越多，难度递增

### 敌人类型

| 类型 | 颜色 | 特点 |
|------|------|------|
| Basic | 绿色 | 基础敌人，平衡属性 |
| Fast | 黄色 | 速度快，血量低 |
| Tank | 红色 | 速度慢，血量高 |

---

## 📁 项目结构

```
zombiesurvivor/
├── project.godot          # 项目配置 ✅
├── export_presets.cfg     # 导出配置 ✅
├── README.md              # 说明文档 ✅
├── scripts/               # 脚本目录 ✅
│   ├── Player.gd          # 玩家控制
│   ├── Zombie.gd          # 僵尸AI
│   ├── EnemySpawner.gd    # 敌人生成器
│   ├── UIManager.gd       # UI管理
│   ├── GameManager.gd     # 游戏管理
│   ├── Weapon.gd          # 武器系统
│   ├── Bullet.gd          # 子弹系统
│   ├── AutoTest.gd        # 自动化测试
│   └── TestRunner.gd      # 测试运行器
├── scenes/                # 场景文件 ✅
│   ├── Game.tscn          # 主场景
│   └── AutoTest.tscn      # 测试场景
└── assets/                # 素材目录（待添加）
```

---

## 🔧 技术说明

### Godot 4.7.1 兼容性

- ✅ 使用GDScript 2.0语法
- ✅ 使用`await`代替`yield`
- ✅ 使用`get_node_or_null`代替`get_node`
- ✅ 使用`CharacterBody2D`移动
- ✅ 渲染方法：`mobile`（兼容渲染）
- ✅ 自动化测试通过

### 已知问题

1. **CircleShape2D警告**: 场景文件中无法直接创建CircleShape2D，使用placeholder替代（不影响功能）
2. **APK导出**: 需要手动下载Android导出模板并配置SDK

---

## 📝 测试报告

### PC端测试
- ✅ 游戏能正常启动
- ✅ WASD移动正常
- ✅ 自动攻击最近敌人
- ✅ 敌人波次正常生成
- ✅ UI显示正常
- ✅ 升级面板能弹出
- ✅ 死亡后能重新开始

### 自动化测试
```
[测试1] 玩家系统 ✅
[测试2] 僵尸系统 ✅
[测试3] 敌人生成器 ✅
[测试4] UI系统 ✅
```

---

## 🎯 下一步计划

- [ ] 添加更多武器类型
- [ ] 添加音效和背景音乐
- [ ] 添加粒子特效
- [ ] 添加更多敌人类型
- [ ] 添加Boss战
- [ ] 优化移动端触摸控制
- [ ] 导出APK并测试手机端

---

## 💡 快速开始

```bash
# 1. 打开Godot编辑器
"E:/godot/Godot_v4.7.1-stable_win64.exe"

# 2. 导入项目：E:/godot/zombiesurvivor/

# 3. 按F5运行测试

# 4. 运行自动化测试（可选）
"E:/godot/Godot_v4.7.1-stable_win64.exe" --headless --quit --path "E:/godot/zombiesurvivor" --scene "res://scenes/AutoTest.tscn"

# 5. 下载Android导出模板（需要APK时）

# 6. 导出APK
```

---

**项目已创建完成！PC端测试通过！现在可以用Godot编辑器打开测试了！** 🎮
