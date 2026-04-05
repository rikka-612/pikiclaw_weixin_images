# GitHub 完整使用教程

从零开始，将本项目发布到 GitHub。

---

## 第一部分：准备工作

### 1.1 注册 GitHub 账号

1. 访问 https://github.com
2. 点击右上角 **Sign up**
3. 填写信息：
   - Email：你的邮箱
   - Password：密码（建议包含大小写+数字+符号）
   - Username：用户名（全网唯一，谨慎选择）
4. 验证邮箱（查收邮件点击链接）

### 1.2 安装 Git 工具

**Windows 用户：**
```powershell
# 方法1：winget 安装（推荐）
winget install Git.Git

# 方法2：官网下载
# 访问 https://git-scm.com/download/win
```

**验证安装：**
```powershell
git --version
# 输出类似：git version 2.43.0
```

### 1.3 配置 Git 身份

```powershell
# 设置用户名（替换为你的名字）
git config --global user.name "Your Name"

# 设置邮箱（必须与 GitHub 注册邮箱一致）
git config --global user.email "your.email@example.com"
```

---

## 第二部分：创建仓库

### 2.1 在 GitHub 网页创建

1. 登录 https://github.com
2. 点击右上角 **+** 号 → **New repository**
3. 填写仓库信息：
   - **Repository name**: `pikiclaw-weixin-images`
   - **Description**: `让 Pikiclaw 支持微信图片消息（AES解密）`
   - **Public** （公开，任何人可见）或 **Private** （仅自己可见）
   - ✅ 勾选 **Add a README file**（自动生成 README）
4. 点击 **Create repository**

### 2.2 理解仓库地址

创建后，你的仓库会有两个地址：

- **HTTPS**: `https://github.com/你的用户名/pikiclaw-weixin-images.git`
  - 适合新手，需要输入密码
  
- **SSH**: `git@github.com:你的用户名/pikiclaw-weixin-images.git`
  - 适合进阶，需要配置密钥，但更方便

---

## 第三部分：上传代码（两种方式）

## 方式一：命令行方式（推荐学习）

### 步骤1：在本地初始化项目

```powershell
# 进入项目文件夹
cd C:\Users\25492\pikiclaw-weixin-images

# 初始化 Git 仓库
git init

# 会看到提示：Initialized empty Git repository
```

### 步骤2：添加文件到 Git

```powershell
# 查看当前状态
git status
# 会看到红色字体的未跟踪文件

# 添加所有文件
git add .

# 再次查看状态
git status
# 现在文件变成绿色，表示已暂存
```

### 步骤3：提交更改

```powershell
# 提交并写注释
git commit -m "初始提交：添加微信图片 AES 解密支持"

# 会看到类似输出：
# [main (root-commit) abc1234] 初始提交：添加微信图片 AES 解密支持
#  5 files changed, 500 insertions(+)
```

### 步骤4：关联远程仓库

```powershell
# 添加远程仓库（替换为你的用户名）
git remote add origin https://github.com/你的用户名/pikiclaw-weixin-images.git

# 验证关联成功
git remote -v
# 输出：
# origin  https://github.com/.../pikiclaw-weixin-images.git (fetch)
# origin  https://github.com/.../pikiclaw-weixin-images.git (push)
```

### 步骤5：推送到 GitHub

```powershell
# 第一次推送（建立关联）
git push -u origin main

# 或如果默认分支是 master：
git push -u origin master

# 会提示输入用户名和密码
# 用户名：你的 GitHub 用户名
# 密码：不是登录密码！而是 Personal Access Token（见下方）
```

### 关于 Personal Access Token

GitHub 不再支持密码登录，需要创建 Token：

1. 访问 https://github.com/settings/tokens
2. 点击 **Generate new token (classic)**
3. 填写 Note: `Pikiclaw Project`
4. 勾选权限：
   - ✅ `repo` （完整仓库访问）
5. 点击 **Generate token**
6. **立即复制 token**（只显示一次！）
7. 在 `git push` 时，用这个 token 代替密码

---

## 方式二：网页拖拽方式（最简单）

适合不想用命令行的用户：

1. 打开 GitHub 仓库页面
2. 点击 **Add file** → **Upload files**
3. 将本地 `pikiclaw-weixin-images` 文件夹中的文件拖拽到网页
4. 填写提交信息：`添加微信图片 AES 解密补丁`
5. 点击 **Commit changes**

---

## 第四部分：后续更新

### 修改代码后如何更新？

```powershell
# 1. 查看修改了哪些文件
git status

# 2. 添加修改的文件
git add README.md
git add patches/api.js.patch

# 或添加所有修改
git add .

# 3. 提交更改
git commit -m "修复：支持 PNG 格式图片"

# 4. 推送到 GitHub
git push
```

### 常用 Git 命令速查

| 命令 | 作用 |
|------|------|
| `git status` | 查看当前状态 |
| `git add 文件名` | 添加文件到暂存区 |
| `git add .` | 添加所有修改 |
| `git commit -m "注释"` | 提交更改 |
| `git push` | 推送到远程仓库 |
| `git pull` | 从远程拉取更新 |
| `git log` | 查看提交历史 |
| `git clone 地址` | 克隆别人的仓库 |

---

## 第五部分：Pull Request（进阶）

如果你想把修改贡献给 Pikiclaw 官方：

### 5.1 Fork 官方仓库

1. 访问 https://github.com/pikiclaw/pikiclaw
2. 点击右上角 **Fork** 按钮
3. 等待复制完成（这会创建一个你的副本）

### 5.2 克隆你的 Fork

```powershell
git clone https://github.com/你的用户名/pikiclaw.git
cd pikiclaw
```

### 5.3 创建新分支

```powershell
# 创建并切换到新分支
git checkout -b weixin-image-support

# 现在你在新分支上工作，不影响主分支
```

### 5.4 修改代码并提交

```powershell
# 修改文件...

# 提交
git add .
git commit -m "feat(weixin): Add AES decryption for image messages"

# 推送到你的 Fork
git push origin weixin-image-support
```

### 5.5 创建 Pull Request

1. 访问你的 Fork 页面
2. 点击 **Compare & pull request**
3. 填写 PR 信息：
   - **Title**: `feat(weixin): Add AES decryption for image messages`
   - **Description**: 
     ```
     ## 问题
     微信图片消息无法正确处理...
     
     ## 解决方案
     添加 AES-128-ECB 解密...
     
     ## 测试
     已测试 JPG/PNG 格式...
     ```
4. 点击 **Create pull request**

---

## 第六部分：GitHub 其他功能

### 6.1 Issues（问题跟踪）

- 用户可以在你的项目提 issue 报告 bug
- 你也可以给官方项目提 issue

### 6.2 Releases（发布版本）

1. 点击仓库页面的 **Releases**
2. 点击 **Create a new release**
3. 填写版本号：`v1.0.0`
4. 上传补丁文件作为附件
5. 发布

### 6.3 GitHub Pages（免费网站）

可以用 GitHub 免费搭建项目文档网站。

---

## 完整操作流程图

```
第一次发布：
1. 注册 GitHub 账号
2. 在网页创建仓库
3. 本地 git init
4. git add .
5. git commit -m "初始提交"
6. git remote add origin ...
7. git push -u origin main

日常更新：
1. 修改代码
2. git add .
3. git commit -m "更新说明"
4. git push
```

---

## 遇到问题？

常见错误：

```
# 错误： refusing to merge unrelated histories
git pull origin main --allow-unrelated-histories

# 错误： Updates were rejected
git pull origin main  # 先拉取更新
git push  # 再推送

# 错误： Please tell me who you are
git config user.name "Your Name"
git config user.email "your@email.com"
```

---

## 下一步

现在你已经掌握了 GitHub 的基本使用：

1. ✅ 发布本项目到 GitHub
2. ✅ 分享给其他人使用
3. ✅ 给 Pikiclaw 官方提交 PR
4. ✅ 参与开源社区

有任何问题，可以在 GitHub 上开 issue 问我！
