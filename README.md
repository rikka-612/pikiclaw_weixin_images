# Pikiclaw Weixin Image Support

让 Pikiclaw 的微信接入支持接收和解析图片消息。

## 问题

使用 Pikiclaw 接入微信时，用户发送图片会报错：
```
This Weixin channel currently supports text input only.
```

或者 Claude Code 报错：
```
API Error: 400 - unsupported image format: application/octet-stream
```

## 原因

微信 iLink API 返回的图片是 **AES-128-ECB 加密**的数据流，需要解密后才能使用。

## 解决方案

本项目提供对 Pikiclaw 的补丁，实现：
1. 自动下载加密的图片数据
2. 使用 AES-128-ECB PKCS7 解密
3. 自动识别图片格式 (JPG/PNG/GIF/WebP)
4. 将解密后的图片传递给 AI 处理

## 快速开始

### 方法一：自动安装（推荐）

```powershell
# 1. 克隆本仓库
git clone https://github.com/rikka-612/pikiclaw_weixin_images.git
cd pikiclaw_weixin_images

# 2. 运行安装脚本
.\install.ps1 -PikiclawPath "$env:APPDATA\npm\node_modules\pikiclaw"

# 3. 重启 Pikiclaw
pikiclaw restart
```

### 方法二：手动打补丁

```powershell
# 1. 备份原文件
cd $env:APPDATA\npm\node_modules\pikiclaw

# 2. 应用补丁
git apply patches/api.js.patch
git apply patches/channel.js.patch
git apply patches/bot.js.patch

# 3. 重启 Pikiclaw
pikiclaw restart
```

### 方法三：完整文件替换

直接复制 `patches/` 目录下的文件到对应位置：
- `patches/api.js` → `pikiclaw/dist/channels/weixin/api.js`
- `patches/channel.js` → `pikiclaw/dist/channels/weixin/channel.js`
- `patches/bot.js` → `pikiclaw/dist/channels/weixin/bot.js`

## 文件修改说明

| 文件 | 修改内容 |
|------|---------|
| `api.js` | 添加 `downloadAndDecryptWeixinImage()` 函数，实现 AES 解密 |
| `channel.js` | 集成图片解密逻辑，遍历消息中的图片并解密 |
| `bot.js` | 添加纯图片消息的默认提示词 |

详细技术文档：[docs/weixin-image-decryption.md](./docs/weixin-image-decryption.md)

## 使用效果

### 之前
```
用户: [发送图片]
Claude: This Weixin channel currently supports text input only.
```

### 之后
```
用户: [发送图片]
Claude: 我看到这是一张照片，显示了...（详细描述图片内容）
```

## 系统要求

- Pikiclaw >= 1.x
- Claude Code / Codex / 其他 Agent
- Node.js >= 18

## 技术细节

- **加密算法**: AES-128-ECB
- **填充方式**: PKCS7
- **密钥来源**: `image_item.aeskey` (16字节十六进制字符串)
- **数据来源**: `image_item.media.full_url`
- **临时文件**: 保存在系统临时目录，自动清理

## 常见问题

### Q: 补丁应用失败？
A: 确保 Pikiclaw 版本与补丁匹配。如果版本不同，可以手动参考 `docs/weixin-image-decryption.md` 修改。

### Q: 图片解密失败？
A: 检查控制台日志，可能是网络下载失败或 AES key 格式错误。

### Q: 支持视频/语音吗？
A: 当前仅支持图片。视频和语音有另外的加密机制，如有需求可以开 issue。

## 贡献

欢迎提交 Pull Request！建议的贡献方向：
- 支持更多微信消息类型（视频、语音、文件）
- 添加临时文件自动清理机制
- 优化图片下载性能

## 许可证

本项目：MIT License

原始 Pikiclaw：MIT License (Copyright 2026 pikiclaw contributors)

## 免责声明

本项目仅用于学习和研究目的。使用微信 iLink API 需遵守[微信开放平台服务协议](https://open.weixin.qq.com/cgi-bin/readtemplate?t=opensm/protocol)。

作者不对因使用本项目导致的任何账号封禁、数据丢失或其他损失负责。

## 相关链接

- [Pikiclaw 官方仓库](https://github.com/xiaotonng/pikiclaw)
- [微信 iLink API 文档](https://www.wechatbot.dev/zh/protocol)
- [技术详解文档](./docs/weixin-image-decryption.md)
