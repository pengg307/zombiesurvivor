# 游戏失败/胜利逻辑说明

## 游戏失败（Game Over）

### 触发条件
1. **僵尸碰到玩家** - Area2D 碰撞检测
2. **僵尸到达玩家位置** - Y >= 1100

### 代码流程
```
Player.gd:105  area.monitoring = true  ← 已修复
Player.gd:117  emit_signal("player_died")
    ↓
GameManager.gd:60-63  _on_player_died()
    ↓
UIManager.gd:129-135  show_game_over(kills)
    ↓
GameOverPanel.visible = true
```

---

## 游戏胜利（Win）

### 触发条件
1. **Boss 被击杀**
2. **Boss 到达玩家位置**

### 代码流程
```
Zombie.gd:307  player.emit_signal("game_won")
    ↓
GameManager.gd:68-71  _on_game_won()
    ↓
UIManager.gd:137-143  show_win(kills)
    ↓
WinPanel.visible = true
```

---

## 测试方法

**按 F5 运行游戏**：
1. 等待僵尸走到屏幕底部（Y=1100）→ 显示 **游戏结束**
2. 击杀5个僵尸 → Boss 出现 → 击杀 Boss → 显示 **胜利**

---

## 已修复的问题

| 问题 | 修复 |
|------|------|
| Area2D 未启用 | `area.monitoring = true` |
| AudioManager 未注册 | `add_to_group("audio_manager")` |
| 缺少 UI 面板 | 创建 GameOverPanel + WinPanel |
