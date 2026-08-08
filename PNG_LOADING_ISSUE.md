# PNG加载问题详解

## 问题
`littleboss.png` 无法在游戏运行时动态加载

## 原因分析

### 1. PNG格式问题
```
littleboss.png:
- 尺寸: 512x512
- 模式: 8-bit colormap (P模式)
- 文件大小: 59,298 字节
- 问题: Godot 4.x 不支持动态加载 colormap PNG
```

**PNG颜色模式:**
- **RGB (TrueColor)**: 24-bit, 1670万色 - ✅ Godot支持
- **RGBA (TrueColor+Alpha)**: 32-bit, 含透明度 - ✅ Godot支持
- **P (Palette/Colormap)**: 8-bit, 最多256色 - ❌ Godot不支持
- **L (Grayscale)**: 8-bit, 灰度 - ⚠️ 部分支持

### 2. Godot资源加载机制
Godot 加载资源有两条路径:

**路径A: 编辑器导入 (推荐)**
```
PNG文件 → Godot编辑器导入 → .import文件 + .ctex文件
                                    ↓
                            运行时加载 ✅
```

**路径B: 动态加载 (限制)**
```
load("res://.../file.png") 
    ↓
Godot直接读取PNG文件
    ↓
只支持: RGB, RGBA
不支持: P (colormap), 其他特殊格式 ❌
```

### 3. 为什么转换RGBA后仍失败?

转换后的 `boss.png`:
- 文件大小: 173,441 字节 (比原来大3倍)
- 格式: RGBA (应该可以加载)
- 但报错: `ERROR: No loader found for resource`

**原因**: Godot 4.x 改进了资源管理系统，动态加载PNG时需要对应的 `.import` 文件。没有 `.import` 文件，Godot 不知道如何解析该PNG。

## 解决方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| **程序化生成** ✅ | 无需外部文件，完全可控 | 只能画简单图形 |
| 编辑器导入PNG | 可用任意图片 | 需要每次在Godot编辑器中打开项目 |
| 创建.import文件 | 可动态加载 | 需要知道MD5 hash，格式复杂 |

## 当前实现

```gdscript
func _setup_boss_sprite():
    # 1. 尝试加载 boss.png (会失败)
    var texture = load("res://assets/downloads/boss.png")
    if texture:
        sprite.texture = texture
        return
    
    # 2. Fallback: 程序化生成红色圆形
    print("⚠️ 使用程序化纹理")
    var img = Image.create(128, 128, false, Image.FORMAT_RGBA8)
    # ... 画红色圆形和黄色眼睛 ...
    sprite.texture = ImageTexture.create_from_image(img)
```

## 如何让玩家使用真正的PNG?

**方法: 在Godot编辑器中导入**

1. 打开 Godot 编辑器
2. 导入项目: `E:/godot/zombiesurvivor/`
3. 在 FileSystem 面板中找到 `assets/downloads/littleboss.png`
4. 右键 → `Reimport` (如果已导入) 或直接导入
5. Godot 会自动创建 `.import` 文件和 `.ctex` 文件
6. 运行游戏即可加载

**或者** 把 PNG 放到项目根目录并重新导入:
```bash
cp assets/downloads/boss.png .
# 在Godot编辑器中重新导入
```

## 技术细节

**PNG文件头分析:**
```
littleboss.png 前16字节:
89 50 4E 47 0D 0A 1A 0A  # PNG签名
00 00 00 0D 49 48 44 52  # IHDR chunk (13 bytes)
00 00 02 00 00 00 02     # 宽度=512, 高度=512
08 03                    # 位深=8, 类型=3 (Palette/Colormap) ← 问题所在!
```

- `08` = 8-bit (每像素1字节，索引颜色)
- `03` = 类型3 (Palette/Colormap)
- Godot 的 PNG 解码器不支持类型3

**正确的PNG头应该是:**
```
08 06  # 位深=8, 类型=6 (RGBA TrueColor)
```
