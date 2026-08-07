# 📱 Godot 4.7.1 Android APK导出完整指南

## 问题诊断

**当前错误：**
```
No export template found at:
C:/Users/Pactera/AppData/Roaming/Godot/export_templates/4.7.1.stable/android_debug.apk

Unable to find the 'apksigner' tool.
```

**原因：**
1. 缺少Android导出模板
2. Android SDK版本太旧（只有android-23，需要android-34）
3. build-tools版本太旧（只有23.0.2）

---

## 解决方案

### 方案A：使用Godot编辑器（推荐，最简单）

#### 步骤1：打开Godot编辑器

```
双击：E:\godot\Godot_v4.7.1-stable_win64.exe
```

#### 步骤2：导入项目

1. 点击 "Import" 按钮
2. 选择文件夹：`E:\godot\zombiesurvivor\`
3. 点击 "Import & Edit"

#### 步骤3：下载Android导出模板

1. 菜单：`Editor → Manage Export Templates`
2. 点击 "Download" 按钮
3. 在弹出窗口中：
   - 选择版本：**Godot Engine v4.7.1.stable**
   - 点击 "Download"
   - 等待下载完成（约100MB）
   - 点击 "Install"
4. 关闭模板管理器

#### 步骤4：配置Android SDK

**检查当前SDK：**
```
路径：C:\NVPACK\android-sdk-windows
版本：android-23（太旧！）
```

**需要更新到android-34**

**方法1：使用SDK Manager（推荐）**
```
1. 打开：C:\NVPACK\android-sdk-windows\SDK Manager.exe
   （或：C:\NVPACK\android-sdk-windows\tools\android.bat）

2. 在 "Packages" 标签页，找到并勾选：
   ☑ Android SDK Platform 34
   ☑ Android SDK Build-Tools 34.0.0
   ☑ Android SDK Platform-Tools

3. 点击 "Install Packages"
4. 接受许可协议
5. 等待下载安装完成（约500MB）
```

**方法2：手动下载（如果SDK Manager无法使用）**

1. 访问：https://developer.android.com/tools/releases/platforms
2. 下载：
   - platform-34.rar → 解压到 `C:\NVPACK\android-sdk-windows\platforms\`
   - build-tools_r34-windows.zip → 解压到 `C:\NVPACK\android-sdk-windows\build-tools\`
3. 验证安装：
   ```
   dir C:\NVPACK\android-sdk-windows\platforms\
   dir C:\NVPACK\android-sdk-windows\build-tools\
   ```

#### 步骤5：配置Godot

1. 在Godot编辑器中：
   - 菜单：`Project → Project Settings`
   - 左侧搜索：`android`
   - 找到以下设置并设置路径：

   ```
   General → Export → Android → SDK Path
   值：C:\NVPACK\android-sdk-windows
   
   General → Export → Android → NDK Path
   值：C:\NVPACK\android-ndk-r10e
   
   General → Export → Android → JDK Path
   值：C:\NVPACK\jdk1.7.0_71
   ```

2. 点击 "Apply and Close"

#### 步骤6：导出APK

1. 菜单：`Project → Export`
2. 点击 "Add..." 按钮
3. 选择 "Android"
4. 配置导出参数：

   **General标签页：**
   ```
   Application/Name: ZombieSurvivor
   Application/Version: 1.0
   Application/Package: org.godotengine.zombiesurvivor
   Application/Install Location: Auto
   ```

   **Layout标签页：**
   ```
   Resolution/Width: 720
   Resolution/Height: 1280
   Orientation: Portrait
   Stretch Mode: canvas_items
   Stretch Aspect: keep
   ```

   **Graphics标签页：**
   ```
   Rendering Method: mobile
   Rendering Thread: safe
   ```

   **Export标签页：**
   ```
   Export Path: E:\godot\zombiesurvivor.apk
   ```

5. 点击 "Export Project"
6. 等待导出完成（约1-2分钟）
7. APK生成在：`E:\godot\zombiesurvivor.apk`

---

### 方案B：使用命令行导出（高级）

#### 前置条件

必须先完成方案A的步骤1-5（下载模板和配置SDK）

#### 导出命令

```bash
# 设置环境变量
set ANDROID_HOME=C:\NVPACK\android-sdk-windows
set JAVA_HOME=C:\NVPACK\jdk1.7.0_71

# 导出APK
"E:/godot/Godot_v4.7.1-stable_win64.exe" --headless --export-release "Android" "E:/godot/zombiesurvivor.apk" --path "E:/godot/zombiesurvivor"
```

---

### 方案C：使用在线转换（如果本地无法导出）

如果上述方法都无法使用，可以使用在线转换工具：

1. 在Godot编辑器中导出为PC可执行文件：
   - 菜单：`Project → Export`
   - 添加 "Windows Desktop" 平台
   - 导出为 .exe

2. 使用第三方工具转换（不推荐，功能可能受限）

---

## 验证安装

### 检查Android SDK

```bash
# 检查平台版本
dir C:\NVPACK\android-sdk-windows\platforms\
# 应该看到：android-34

# 检查构建工具
dir C:\NVPACK\android-sdk-windows\build-tools\
# 应该看到：34.0.0

# 检查apksigner
dir C:\NVPACK\android-sdk-windows\build-tools\34.0.0\apksigner.exe
# 应该存在
```

### 检查导出模板

```bash
# 检查Godot导出模板
dir "C:\Users\Pactera\AppData\Roaming\Godot\export_templates\4.7.1.stable\"
# 应该看到：
# - android_debug.apk
# - android_release.apk
```

---

## 安装到手机测试

### 方法1：USB传输
```
1. 用手机USB线连接电脑
2. 传输APK到手机
3. 在手机上打开文件管理器
4. 点击APK安装
5. 允许安装未知来源应用（首次）
```

### 方法2：微信/QQ传输
```
1. 发送APK到手机
2. 在微信/QQ中点击APK
3. 允许安装未知来源应用
4. 安装完成
```

### 方法3：云盘下载
```
1. 上传APK到百度网盘/阿里云盘
2. 手机下载APK
3. 安装
```

---

## 游戏控制

### PC端控制
```
WASD 或 方向键：移动
自动攻击：最近敌人
ESC：暂停
```

### 移动端控制
```
触摸屏幕：移动（朝触摸方向）
自动攻击：最近敌人
```

---

## 常见问题

### Q1: 导出失败，提示"找不到apksigner"
**解决：**
```
1. 检查Android SDK Build-Tools是否安装
2. 确保build-tools版本≥30
3. 重启Godot编辑器
```

### Q2: 导出失败，提示"No export template found"
**解决：**
```
1. 重新下载Android导出模板
2. Editor → Manage Export Templates → Download
3. 选择4.7.1.stable版本
```

### Q3: APK安装后闪退
**解决：**
```
1. 检查手机Android版本（需要Android 5.0+）
2. 检查是否允许安装未知来源应用
3. 重新导出APK，确保配置正确
```

### Q4: 游戏在手机上运行缓慢
**解决：**
```
1. 降低分辨率（如640x1138）
2. 减少同时存在的敌人数量
3. 关闭阴影效果
```

---

## 预估APK大小

| 配置 | 大小 |
|------|------|
| 仅脚本（无音效） | ~5 MB |
| 基础音效 | ~8 MB |
| 完整音效+图标 | ~12 MB |
| 带粒子特效 | ~15 MB |

**我们的游戏预估：~10-12 MB**

---

## 下一步

1. ✅ **现在**：打开Godot编辑器
2. ✅ **步骤1**：导入项目
3. ✅ **步骤2**：下载Android模板
4. ✅ **步骤3**：更新Android SDK
5. ✅ **步骤4**：配置Godot
6. ✅ **步骤5**：导出APK
7. ✅ **步骤6**：传输到手机测试

---

**按照以上步骤操作，你应该能在10分钟内导出APK！** 📱

有任何问题随时问我！
