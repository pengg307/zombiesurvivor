# 🎮 Godot导入Kenney素材指南

## 问题：素材无法加载

**错误信息：**
```
ERROR: No loader found for resource: res://assets/kenney_top-down-shooter/PNG/Man Blue/manBlue_stand.png
```

**原因：** Godot需要在编辑器中导入素材，命令行无法自动导入。

---

## ✅ 解决方案（3步）

### 第1步：打开Godot编辑器
```
双击：E:\godot\Godot_v4.7.1-stable_win64.exe
```

### 第2步：导入项目
```
1. 点击 "Import" 按钮
2. 选择文件夹：E:\godot\zombiesurvivor\
3. 点击 "Import & Edit"
```

### 第3步：导入素材
```
1. 在FileSystem面板中，找到 assets/kenney_top-down-shooter/
2. 右键点击 PNG 文件夹
3. 选择 "Import"
4. Godot会自动导入所有PNG文件
5. 等待导入完成（约30秒）
```

---

## 📁 素材结构

```
E:\godot\zombiesurvivor\assets\kenney_top-down-shooter\
├── PNG\
│   ├── Man Blue\          ← 玩家素材
│   │   ├── manBlue_stand.png
│   │   ├── manBlue_hold.png
│   │   ├── manBlue_gun.png
│   │   └── ...
│   ├── Hitman 1\         ← 敌人素材
│   │   ├── hitman1_stand.png
│   │   ├── hitman1_gun.png
│   │   └── ...
│   ├── Survivor 1\
│   ├── Soldier 1\
│   └── Tiles\             ← 地面素材
└── License.txt
```

---

## 🎯 导入后测试

1. 按 F5 运行游戏
2. 应该看到：
   - 玩家：蓝色像素人
   - 敌人：Hitman角色
   - 正常移动和攻击

---

## 💡 常见问题

**Q: 导入后还是看不到素材？**
```
A: 检查路径是否正确
   res://assets/kenney_top-down-shooter/PNG/Man Blue/manBlue_stand.png
```

**Q: 素材显示错误？**
```
A: 在FileSystem面板中点击素材，检查Inspector中的Texture属性
```

**Q: 想要不同的角色？**
```
A: 修改Player.gd中的路径：
   - Man Blue: 普通玩家
   - Survivor 1: 幸存者风格
   - Soldier 1: 士兵风格
   - Robot 1: 机器人风格
```

---

## 🎨 可选：添加Tileset背景

```
1. 在场景中创建Ground节点
2. 使用Kenney的Tileset素材
3. 创建TileMap节点
4. 绘制地面
```

---

**现在请打开Godot编辑器导入素材！** 🎮
