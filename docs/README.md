# WeChat Bridge 文档

本目录包含 wechat-bridge 和 Pikiclaw 微信接入的相关文档。

## 文档列表

| 文档 | 说明 |
|------|------|
| [weixin-image-decryption.md](./weixin-image-decryption.md) | 微信 iLink API 图片解密方案详解 |

## 项目结构

```
wechat-bridge/
├── ilink_bridge.py      # 独立的微信桥接服务（备用方案）
├── send_reply.py          # 快捷发送回复脚本
├── inbox.json             # 收到的消息（独立方案使用）
├── outbox.json            # 待发送的回复（独立方案使用）
└── docs/                  # 文档目录
    ├── README.md
    └── weixin-image-decryption.md
```

## 两种方案对比

### 方案 A: Pikiclaw 集成（当前使用）
- **优点**: Claude Code 直接接收消息，自动处理
- **缺点**: 需要修改 Pikiclaw 源码
- **适用场景**: 主要使用 Claude Code 处理微信消息

### 方案 B: 独立桥接服务
- **优点**: 不修改 Pikiclaw，Kimi 直接处理
- **缺点**: 需要手动询问 Kimi，Claude 不自动接收
- **适用场景**: 主要使用 Kimi 处理微信消息

## 快速开始

### 使用 Pikiclaw 集成方案

1. 确保已修改 Pikiclaw 源码（见 `weixin-image-decryption.md`）
2. 启动 Pikiclaw:
   ```powershell
   cd D:\AI\pikiclaw
   .\start-pikiclaw.ps1
   ```
3. 微信发送图片，Claude Code 自动接收并分析

### 使用独立桥接服务

1. 启动桥接服务:
   ```powershell
   cd wechat-bridge
   python ilink_bridge.py
   ```
2. 询问 Kimi:
   ```
   微信有什么新消息？
   ```
3. Kimi 读取 `inbox.json` 并回复

## 配置文件

### Pikiclaw 配置
文件: `.pikiclaw/setting.json`
```json
{
  "channels": ["weixin"],
  "defaultAgent": "claude",
  "weixinBotToken": "your_token",
  "weixinBaseUrl": "https://ilinkai.weixin.qq.com",
  "weixinAccountId": "your_account"
}
```

### Claude Code 凭证
文件: `.claude/channels/weixin/credentials.json`
```json
{
  "token": "your_token",
  "baseUrl": "https://ilinkai.weixin.qq.com",
  "accountId": "your_account"
}
```

## 常见问题

### Q: 图片无法接收？
A: 检查 Pikiclaw 是否使用了修改后的源码，重启 Pikiclaw 查看控制台日志。

### Q: 显示 "This Weixin channel currently supports text input only"？
A: 说明图片解密逻辑未生效，检查 `channel.js` 是否正确调用了解密函数。

### Q: 图片解密失败？
A: 可能是 AES key 格式错误，检查 `aeskey` 字段是否为 32 字符的十六进制字符串。

## 技术栈

- **iLink API**: 微信官方机器人接口
- **Pikiclaw**: 多 Agent 消息接入框架
- **Node.js**: Pikiclaw 运行环境
- **Python**: 独立桥接服务
- **AES-128-ECB**: 微信图片加密算法
