# 🎮 音效系统说明

## ✅ 已添加的音效

### 音效类型
```
• 射击音效 (shoot_sound)
• 爆炸音效 (explosion_sound)
• 受伤音效 (hit_sound)
• 手雷投掷音效 (grenade_sound)
• 升级音效 (upgrade_sound)
• 升级成功音效 (level_up_sound)
• Boss出现音效 (boss_spawn_sound)
• 游戏结束音效 (game_over_sound)
• 胜利音效 (victory_sound)
```

### 背景音乐
```
• BGM: 循环播放的背景音乐
• 音量: 30%（可调整）
```

---

## 📁 音效资源

### 推荐来源（免费）
```
1. Kenney.nl（CC0授权）
   • https://kenney.nl/assets/sound-effects
   • https://kenney.nl/assets/free-music-pack

2. Freesound.org
   • https://freesound.org/
   • 需要注册账号

3. OpenGameArt.org
   • https://opengameart.org/
   • 免费游戏音效
```

---

## 🔧 使用方法

### 1. 下载音效素材
```
1. 访问 Kenney.nl 音效页面
2. 点击 Download 按钮
3. 保存到：E:\godot\zombiesurvivor\assets\audio\
4. 解压到：E:\godot\zombiesurvivor\assets\audio\sfx\
```

### 2. 导入到Godot
```
1. 打开Godot编辑器
2. 右键 assets/audio/sfx/ 文件夹
3. 选择 Import
4. 等待导入完成
```

### 3. 关联音效到AudioManager
```
1. 在场景树中找到 AudioManager 节点
2. 在 Inspector 面板中，将音效文件拖拽到对应字段
   • shoot_sound → 射击音效
   • explosion_sound → 爆炸音效
   • hit_sound → 受伤音效
   • ...等等
```

---

## 🎵 推荐音效文件

### 射击音效
```
• shoot_001.wav - 步枪射击
• shoot_002.wav - 手枪射击
• bullet_01.ogg - 子弹飞行
```

### 爆炸音效
```
• explosion_01.wav - 大型爆炸
• explosion_02.wav - 小型爆炸
• blast_01.ogg - 冲击波
```

### 受伤音效
```
• hurt_01.wav - 玩家受伤
• hit_01.ogg - 被击中
• pain_01.wav - 痛苦叫声
```

### 手雷音效
```
• grenade_throw.wav - 投掷手雷
• grenade_explode.wav - 手雷爆炸
```

### 升级音效
```
• level_up.wav - 升级成功
• power_up.wav - 能力提升
• ding.ogg - 升级提示音
```

### Boss音效
```
• boss_appear.wav - Boss出现
• boss_music.ogg - Boss背景音乐
```

---

## 💡 音效配置建议

### 音量设置
```
• BGM音量：30%（不会盖过音效）
• 音效音量：80%（清晰可闻）
• 总音量：100%
```

### 音效优先级
```
1. 手雷爆炸（最高）
2. 射击
3. 受伤
4. 升级
5. BGM（最低）
```

---

## 📝 下一步

### 当前状态
```
✅ 音效系统代码已添加
✅ AudioManager脚本已创建
⚠️ 需要下载音效素材
⚠️ 需要在Godot编辑器中关联音效
```

### 快速测试方案
```
1. 使用Godot内置音效测试
   • 创建空AudioStreamPlayer
   • 播放测试音

2. 使用简单音效
   • 下载免费的WAV文件
   • 导入项目测试
```

---

**音效系统已准备就绪！需要下载音效素材并导入到Godot中！** 🎮
