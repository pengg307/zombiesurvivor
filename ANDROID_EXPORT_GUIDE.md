# Android导出指南

## 问题：缺少导出模板

### 解决方案1：手动导出（推荐）

#### 步骤：
1. **打开Godot编辑器**
   ```
   E:/godot/Godot_v4.7.1-stable_win64.exe
   ```

2. **导入项目**
   - 点击 "Import"
   - 选择文件夹：`E:/godot/zombiesurvivor/`
   - 点击 "Import & Edit"

3. **下载Android导出模板**
   - 菜单：Editor → Manage Export Templates
   - 点击 "Download"
   - 选择 "Add From Local..."
   - 或者从Godot官网下载：
     https://godotengine.org/article/dev-snapshot-4-3-stable-android-exports

4. **配置Android导出**
   - 菜单：Project → Export
   - 点击 "Add..." → 选择 "Android"
   - 等待模板加载完成

5. **配置Android SDK路径**
   - 菜单：Project → Project Settings → General → Export
   - Android SDK Path: `C:/NVPACK/android-sdk-windows`
   - Android NDK Path: `C:/NVPACK/android-ndk-r10e`

6. **导出APK**
   - 点击 "Export Project"
   - 选择保存位置：`E:/godot/zombiesurvivor.apk`
   - 等待导出完成

---

### 解决方案2：使用命令行（高级）

```bash
# 设置环境变量
set ANDROID_HOME=C:\NVPACK\android-sdk-windows
set JAVA_HOME=C:\NVPACK\jdk1.7.0_71

# 导出（需要先有模板）
"E:/godot/Godot_v4.7.1-stable_win64.exe" --headless --export-release "Android" "E:/godot/zombiesurvivor.apk" --path "E:/godot/zombiesurvivor"
```

---

### 解决方案3：使用Android设备测试

#### 通过USB调试：
1. 手机开启开发者模式 + USB调试
2. 用USB连接电脑
3. Godot编辑器：Editor → Run Target → Add Device
4. 选择手机，点击运行

#### 通过WiFi调试：
1. 手机和电脑同一WiFi
2. Godot编辑器：Editor → Run Target → Add Device
3. 点击"Wireless Debugging"

---

## 当前项目状态

### ✅ 已完成：
- [x] 基础游戏框架
- [x] 玩家移动系统
- [x] 自动攻击系统
- [x] 敌人生成系统
- [x] 波次系统
- [x] UI系统（血条、等级、波次）
- [x] 升级选择面板
- [x] PC端测试通过

### ⚠️ 待完成：
- [ ] Android导出模板配置
- [ ] APK导出
- [ ] 手机端测试

---

## 文件位置

```
E:/godot/zombiesurvivor/
├── project.godot          # 项目配置 ✅
├── export_presets.cfg     # 导出配置 ✅
├── README.md              # 说明文档 ✅
├── EXPORT_ANDROID.md      # Android导出指南 ✅
├── scripts/               # 脚本目录 ✅
│   ├── Player.gd          # 玩家脚本 ✅
│   ├── Zombie.gd          # 僵尸脚本 ✅
│   ├── EnemySpawner.gd    # 敌人生成器 ✅
│   ├── UIManager.gd       # UI管理 ✅
│   ├── GameManager.gd     # 游戏管理 ✅
│   ├── Weapon.gd          # 武器系统 ✅
│   └── Bullet.gd          # 子弹系统 ✅
├── scenes/                # 场景文件 ✅
│   ├── Game.tscn          # 主场景 ✅
│   └── Game.gd            # 场景脚本 ✅
└── assets/                # 素材目录（待添加）
```

---

## 游戏操作说明

### PC端：
- **WASD** 或 **方向键** 移动
- **自动攻击** 最近敌人
- **ESC** 暂停

### 移动端：
- **触摸屏幕** 移动（朝触摸方向）
- **自动攻击** 最近敌人

---

## 下一步操作

1. **手动导出APK**：按照上述步骤1-6操作
2. **或USB调试测试**：按照解决方案2操作
3. **或WiFi调试测试**：按照解决方案3操作

---

## 快速测试命令

```bash
# 检查项目是否能运行
"E:/godot/Godot_v4.7.1-stable_win64.exe" --headless --quit --path "E:/godot/zombiesurvivor"

# 检查结果（应该看到WARNING而不是ERROR）
```

---

**项目已创建完成！现在需要手动配置Android导出模板来生成APK。**
