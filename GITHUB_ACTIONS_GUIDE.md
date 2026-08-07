# GitHub Actions配置指南

## 快速开始

### 第1步：初始化Git仓库
```bash
cd E:/godot/zombiesurvivor
git init
git add .
git commit -m "Initial commit: Zombie Survivor game"
```

### 第2步：创建GitHub仓库

**方法A：网页创建（推荐）**
1. 访问 https://github.com/new
2. 填写仓库信息：
   - Repository name: `zombie-survivor`
   - Description: `A Godot 4.7.1 survivor game similar to "面向僵尸开炮"`
   - Visibility: Public（推荐）或 Private
   - 勾选 "Add a README file"
3. 点击 "Create repository"

**方法B：命令行创建**
```bash
# 使用GitHub CLI
gh repo create zombie-survivor --public --description "A Godot survivor game" --push
```

### 第3步：推送代码
```bash
# 添加远程仓库
git remote add origin https://github.com/你的用户名/zombie-survivor.git
git branch -M main
git push -u origin main
```

### 第4步：查看Actions
```
1. 打开GitHub仓库
2. 点击 "Actions" 标签
3. 查看自动触发的构建
4. 等待构建完成（约2-5分钟）
5. 下载APK：Artifacts → ZombieSurvivor-Android
```

---

## 工作流说明

### build-android.yml
```yaml
name: Build Android APK

on:
  push:              # 推送到main/master分支时触发
    branches: [ main, master ]
  workflow_dispatch: # 允许手动触发
```

**触发条件：**
- Push代码到main/master分支
- 创建Pull Request
- 手动点击 "Run workflow" 按钮
- 创建Tag（如 v1.0.0）时自动生成Release

**构建步骤：**
1. 检出代码
2. 安装Godot 4.7.1
3. 导出Android APK
4. 上传APK作为Artifact
5. （如果有Tag）创建GitHub Release

### build-ios.yml
```yaml
name: Build iOS IPA

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:
```

**注意：**
- 使用 macOS runner（$0.08/分钟）
- 需要iOS签名证书（可选，用于测试）
- 生成的IPA需要测试分发

---

## 手动触发构建

### 方法1：GitHub网页
```
1. 打开仓库 → Actions
2. 选择工作流（Build Android APK）
3. 点击 "Run workflow"
4. 选择分支（可选）
5. 点击绿色按钮确认
```

### 方法2：GitHub CLI
```bash
gh workflow run build-android.yml
```

### 方法3：API调用
```bash
gh api -X POST repos/你的用户名/zombie-survivor/actions/workflows/build-android.yml/dispatches \
  --field ref=main
```

---

## 下载APK

### 方法1：GitHub网页
```
1. Actions → 选择最近的运行
2. 左侧点击 "Artifacts"
3. 下载 ZombieSurvivor-Android.zip
4. 解压获取APK
```

### 方法2：命令行
```bash
# 安装 act（本地运行GitHub Actions）
brew install act

# 本地运行（需要Docker）
act -j build-android

# 下载Artifact
gh run download --repo 你的用户名/zombie-survivor --name ZombieSurvivor-Android
```

### 方法3：API
```bash
# 获取运行列表
gh run list --repo 你的用户名/zombie-survivor

# 下载特定运行
gh run download <run_id> --repo 你的用户名/zombie-survivor
```

---

## 创建Release（带Tag）

### 方法1：自动创建
```bash
# 创建Tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 自动触发构建并创建Release
```

### 方法2：手动创建
```bash
# GitHub网页
1. Releases → Create new release
2. Tag version: v1.0.0
3. Title: Zombie Survivor v1.0.0
4. 描述：更新日志
5. 附加APK文件
6. 点击 "Publish release"
```

---

## 常见问题

### Q1: Actions运行失败？
**检查：**
```
1. 查看Workflow运行日志
2. 确认GODOT_VERSION正确（4.7.1.stable）
3. 检查export-preset名称（Android）
4. 确认项目路径正确
```

### Q2: 如何添加Android签名？
```yaml
# 在workflow中添加
- name: Sign APK
  run: |
    apksigner sign \
      --ks ${{ secrets.ANDROID_KEYSTORE }} \
      --ks-pass pass:${{ secrets.KEYSTORE_PASSWORD }} \
      --key-pass pass:${{ secrets.KEY_PASSWORD }} \
      --out signed.apk \
      unsigned.apk
```

### Q3: 如何设置自定义Export Preset？
```
1. 在Godot编辑器中配置Export Preset
2. 导出到项目目录
3. 提交export_presets.cfg到Git
4. Actions会自动使用
```

### Q4: 如何只构建特定分支？
```yaml
on:
  push:
    branches: [ main ]  # 只构建main分支
```

---

## 最佳实践

### 1. 分支策略
```
main        → 稳定版本，自动构建Release
develop     → 开发版本，自动构建测试APK
feature/*   → 功能分支，手动触发构建
```

### 2. Tag规范
```
v1.0.0      → 正式版本
v1.0.0-beta → 测试版本
v1.0.0-rc   → 候选版本
```

### 3. 版本管理
```yaml
# 在project.godot中设置版本号
config/version="1.0.0"

# 在workflow中使用
env:
  GAME_VERSION: "1.0.0"
```

### 4. 安全建议
```
1. 不要提交密钥到Git
2. 使用GitHub Secrets存储敏感信息
3. 使用Private仓库（免费）
4. 定期清理旧的Artifact
```

---

## 进阶配置

### 多平台构建
```yaml
jobs:
  build:
    strategy:
      matrix:
        platform: [android, ios, windows, web]
    runs-on: ubuntu-latest
    steps:
      - uses: godotengine/godot-action/export@v4
        with:
          export-preset: ${{ matrix.platform }}
```

### 自动化发布
```yaml
- name: Publish to Itch.io
  uses: muety/itch.io-github-action@v1
  with:
    url: https://yourname.itch.io/zombie-survivor
    credentials: ${{ secrets.ITCH_IO_CREDENTIALS }}
    build_path: export_output/android
```

### 通知设置
```yaml
- name: Notify
  if: always()
  run: |
    if [ "${{ job.status }}" == "success" ]; then
      echo "✅ Build successful!"
    else
      echo "❌ Build failed!"
    fi
```

---

## 参考资料

- [Godot GitHub Action](https://github.com/godotengine/godot-action)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Android APK签名指南](https://developer.android.com/studio/command-line/apksigner)
- [GitHub Releases](https://docs.github.com/en/releases)
