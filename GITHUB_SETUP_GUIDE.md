# 🚀 GitHub Actions 配置完成！

## ✅ 已创建的文件

```
E:/godot/zombiesurvivor/
├── .github/
│   └── workflows/
│       ├── build-android.yml  ✅ Android构建
│       └── build-ios.yml      ✅ iOS构建
├── .gitignore                 ✅ Git忽略规则
└── GITHUB_ACTIONS_GUIDE.md    ✅ 详细指南
```

---

## 📋 现在你需要做的（3步）

### 第1步：初始化Git仓库
```bash
cd E:/godot/zombiesurvivor
git init
git add .
git commit -m "Initial commit: Zombie Survivor game"
```

### 第2步：创建GitHub仓库
```
1. 打开 https://github.com/new
2. 填写：
   - Repository name: zombie-survivor
   - Description: A Godot survivor game
   - Visibility: Public（推荐）
   - 勾选 "Add a README file"
3. 点击 "Create repository"
4. 复制仓库地址（如：https://github.com/你的用户名/zombie-survivor.git）
```

### 第3步：推送代码
```bash
git remote add origin https://github.com/你的用户名/zombie-survivor.git
git branch -M main
git push -u origin main
```

---

## 🎉 推送后会发生什么？

```
1. GitHub自动检测到push
2. 触发Actions工作流
3. 运行build-android.yml
4. 下载Godot 4.7.1
5. 导出Android APK
6. 上传APK到Artifacts
7. 发送通知给你
```

---

## 📥 如何下载APK

### 方法1：GitHub网页
```
1. 打开你的GitHub仓库
2. 点击 "Actions" 标签
3. 选择最近的运行（Build Android APK）
4. 左侧点击 "Artifacts"
5. 下载 ZombieSurvivor-Android.zip
6. 解压得到APK
```

### 方法2：命令行
```bash
# 安装GitHub CLI
winget install GitHub.cli

# 登录
gh auth login

# 下载APK
gh run download --repo 你的用户名/zombie-survivor --name ZombieSurvivor-Android
```

---

## ⚙️ 可选配置

### 设置GitHub Secrets（如果需要签名）
```
1. 仓库 → Settings → Secrets and variables → Actions
2. 点击 "New repository secret"
3. 添加：
   - ANDROID_KEYSTORE：你的密钥库文件
   - KEYSTORE_PASSWORD：密钥库密码
   - KEY_ALIAS：密钥别名
   - KEY_PASSWORD：密钥密码
```

### 手动触发构建
```
1. Actions → Build Android APK
2. 点击 "Run workflow"
3. 选择分支（main）
4. 点击绿色按钮确认
```

---

## 💰 费用说明

| 项目 | 费用 |
|------|------|
| Android构建 | **免费** |
| iOS构建 | $0.08/分钟（macOS runner）|
| Artifact存储 | 免费（30天）|
| 私有仓库 | **免费** |

**建议：**
- 先用Android版本测试
- iOS版本等需要时再启用
- 使用Private仓库保护代码

---

## 🔔 通知设置（可选）

### 接收构建通知
```
1. GitHub → Settings → Notifications
2. 选择通知方式：
   - Email（默认）
   - Mobile push
   - SMS
3. 勾选 "Participating" 或 "All"
```

---

## 📊 成功标志

```
✅ Actions标签页显示绿色勾
✅ Artifacts中有APK文件
✅ Release自动创建（如果推了Tag）
✅ 邮件/通知收到成功消息
```

---

## ❓ 常见问题

### Q: 构建失败？
```
1. 查看Actions运行日志
2. 确认GODOT_VERSION正确
3. 检查export-preset名称
4. 确保项目文件完整
```

### Q: 如何更新版本？
```bash
# 修改版本号
# 编辑 project.godot
config/version="1.0.1"

# 创建新Tag
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin v1.0.1
```

### Q: 如何删除旧APK？
```
1. Actions → 选择运行
2. 右侧点击 "Delete artifact"
3. 或等待30天自动删除
```

---

## 🎯 下一步

```
1. ✅ 按照上面的3步操作
2. ✅ 等待构建完成（约2-5分钟）
3. ✅ 下载APK测试
4. ✅ 分享给你朋友！
```

---

**有问题随时问我！** 🚀
