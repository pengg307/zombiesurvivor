# Android APK导出指南

## ⚠️ 当前状态

**无法直接导出APK**，原因：
1. ❌ 缺少Android导出模板
2. ❌ Android SDK版本太旧（只有android-23，需要android-34）
3. ❌ build-tools版本太旧（只有23.0.2，需要34+）

---

## 📥 解决方案

### 方案1：手动下载模板和SDK（推荐）

#### 步骤1：下载Android导出模板

1. 打开Godot编辑器
   ```
   E:\godot\Godot_v4.7.1-stable_win64.exe
   ```

2. 菜单：`Editor → Manage Export Templates`

3. 点击 "Download"

4. 选择 "Godot Engine v4.7.1.stable"

5. 点击 "Download and Install"

#### 步骤2：更新Android SDK

需要Android SDK 34（Android 14）

**方法A：使用SDK Manager**
```
打开：C:\NVPACK\android-sdk-windows\SDK Manager.exe
安装：
- Android SDK Platform 34
- Android SDK Build-Tools 34.0.0
- Android SDK Platform-Tools
```

**方法B：手动下载**
1. 访问：https://developer.android.com/tools/releases/platforms
2. 下载 Platform 34
3. 下载 Build-Tools 34.0.0
4. 解压到 SDK目录

#### 步骤3：配置Godot

1. 菜单：`Project → Project Settings → General → Export`

2. 设置路径：
   ```
   Android SDK Path: C:\NVPACK\android-sdk-windows
   Android NDK Path: C:\NVPACK\android-ndk-r10e
   Java SDK Path: C:\NVPACK\jdk1.7.0_71
   ```

3. 点击 "Apply"

#### 步骤4：导出APK

1. 菜单：`Project → Export`

2. 点击 "Add..." → 选择 "Android"

3. 配置导出参数：
   ```
   General:
     Application/Name: ZombieSurvivor
     Application/Version: 1.0
   
   Layout:
     Resolution/Width: 720
     Resolution/Height: 1280
     Orientation: Portrait
   
   Graphics:
     Rendering Method: mobile
   ```

4. 点击 "Export Project"

5. 保存位置：`E:\godot\zombiesurvivor.apk`

---

### 方案2：使用命令行导出（高级）

```bash
# 设置环境变量
set ANDROID_HOME=C:\NVPACK\android-sdk-windows
set JAVA_HOME=C:\NVPACK\jdk1.7.0_71

# 导出（需要先下载模板和更新SDK）
"E:/godot/Godot_v4.7.1-stable_win64.exe" --headless --export-release "Android" "E:/godot/zombiesurvivor.apk" --path "E:/godot/zombiesurvivor"
```

---

## 📊 APK大小预估

| 类型 | 大小 |
|------|------|
| 最小APK（仅脚本） | ~5 MB |
| 完整APK（含资源） | ~10-15 MB |
| 带图标和音效 | ~20-30 MB |

---

## ✅ 检查清单

导出前确认：
- [ ] Android导出模板已下载
- [ ] Android SDK Platform 34已安装
- [ ] Android SDK Build-Tools 34已安装
- [ ] SDK路径已配置到Godot
- [ ] NDK路径已配置到Godot
- [ ] Java路径已配置到Godot

---

## 🔧 故障排除

### 问题1：找不到apksigner
**解决**：确保Android SDK Build-Tools已安装，且路径正确

### 问题2：找不到导出模板
**解决**：下载并安装Android导出模板

### 问题3：SDK版本太低
**解决**：安装Android SDK Platform 34

---

## 📱 安装测试

导出成功后：
1. 通过USB、微信、QQ传输APK到手机
2. 在手机上打开APK安装
3. 允许安装未知来源应用（首次需要）
4. 运行游戏测试

---

**建议：先在Godot编辑器中配置好所有设置，然后再导出APK。**
