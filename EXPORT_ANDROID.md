# Android导出配置

## 导出步骤

### 1. 准备导出模板
- 打开Godot编辑器
- 菜单：Project → Export
- 点击 "Add..." → 选择 "Android"
- 等待下载导出模板

### 2. 配置导出设置
```
General:
  - Application/Name: ZombieSurvivor
  - Application/Version: 1.0
  - Layout/Resolution/Width: 720
  - Layout/Resolution/Height: 1280
  - Layout/Stretch/Mode: canvas_items
  - Layout/Stretch/Aspect: keep

Graphics:
  - Rendering/Driver/GLES3: 启用
  - Rendering/Environment/Default Clear Color: 深色背景

Export:
  - Package/Icon: 添加图标（可选）
  - Permissions: 无需特殊权限
  - APK Expansion: 无需
```

### 3. 导出APK
- 点击 "Export Project"
- 选择导出路径
- 等待导出完成

### 4. 安装到手机
- 通过USB、微信、QQ等方式传输APK到手机
- 在手机上打开APK安装
- 允许安装未知来源应用（首次需要）

## 触摸控制说明

- **移动**: 触摸屏幕任意位置，角色朝触摸方向移动
- **攻击**: 自动攻击最近敌人
- **暂停**: 点击暂停按钮

## 性能优化建议

- 降低分辨率到720p
- 减少同时存在的敌人数量
- 关闭阴影效果
- 使用简单的几何体代替复杂模型
