# 项目文件结构说明

```
pikiclaw-weixin-images/
├── README.md                       # 项目主页文档
├── LICENSE                         # MIT 许可证
├── GITHUB_TUTORIAL.md              # GitHub 完整使用教程
├── PROJECT_STRUCTURE.md            # 本文件
├── .gitignore                      # Git 忽略文件配置
│
├── install.ps1                     # 自动安装脚本（PowerShell）
│
├── patches/                        # 补丁文件目录
│   ├── api.js.patch               # api.js 的修改
│   ├── channel.js.patch           # channel.js 的修改
│   └── bot.js.patch               # bot.js 的修改
│
├── docs/                           # 文档目录
│   ├── README.md                  # 文档首页
│   └── weixin-image-decryption.md # 详细技术文档
│
└── wechat-bridge/                 # 独立桥接服务（备选方案）
    ├── ilink_bridge.py            # Python 桥接服务
    ├── send_reply.py              # 快捷发送脚本
    ├── README.md                  # 使用说明
    ├── inbox.json                 # 收到的消息（运行时生成）
    └── outbox.json                # 待发送消息（运行时生成）
```

## 各文件用途

### 根目录文件

| 文件 | 用途 | 是否必需 |
|------|------|----------|
| `README.md` | GitHub 主页显示的项目说明 | ✅ 必需 |
| `LICENSE` | MIT 许可证声明 | ✅ 必需 |
| `GITHUB_TUTORIAL.md` | 教你如何使用 GitHub | 📖 教程 |
| `.gitignore` | 告诉 Git 哪些文件不要上传 | ✅ 必需 |
| `install.ps1` | 一键安装补丁的脚本 | 🔧 工具 |

### patches/ 目录

包含 3 个补丁文件，这是项目的核心：

| 补丁文件 | 作用 | 修改行数 |
|---------|------|---------|
| `api.js.patch` | 添加 AES 解密函数 | +45 行 |
| `channel.js.patch` | 集成解密逻辑到消息处理 | +68 行 |
| `bot.js.patch` | 添加纯图片消息默认提示 | +7 行 |

### docs/ 目录

技术文档，帮助理解原理：

- `weixin-image-decryption.md`: 详细的技术实现说明

### wechat-bridge/ 目录

备选方案，如果不想修改 Pikiclaw，可以用这个独立的 Python 服务：

- 接收微信消息保存到 `inbox.json`
- 你手动问 Kimi 时，Kimi 读取文件并处理

---

## 发布前的准备清单

在发布到 GitHub 之前，你需要：

### 1. 修改个人信息

- [ ] `LICENSE`: 替换 `[Your Name]` 为你的名字
- [ ] `README.md`: 替换所有 `YOUR_USERNAME` 为你的 GitHub 用户名
- [ ] `README.md`: 修改描述文字（可选）

### 2. 选择发布方式

**方式 A：只发补丁（推荐）**
- 保留 `patches/` 目录
- 保留 `install.ps1`
- 用户自己下载 Pikiclaw，你提供补丁

**方式 B：完整 Fork**
- 删除 `patches/` 目录
- 添加 `modified-files/` 目录（放完整的修改后文件）
- 用户直接下载你的版本使用

### 3. 测试安装脚本

```powershell
# 测试安装脚本是否能正常运行
.\install.ps1
```

### 4. 上传到 GitHub

按照 `GITHUB_TUTORIAL.md` 的步骤操作。

---

## 后续维护

如果 Pikiclaw 更新了，你可能需要：

1. 重新生成补丁文件
2. 更新版本兼容性说明
3. 发布新的 Release

---

## 给使用者的说明

当有人使用你的项目时，他们只需要：

1. 克隆仓库
2. 运行 `.\install.ps1`
3. 重启 Pikiclaw
4. 测试发送图片

就这么简单！
