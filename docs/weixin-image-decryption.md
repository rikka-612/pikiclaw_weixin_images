# 微信 iLink API 图片解密方案

## 问题背景

Pikiclaw 通过 iLink API 接入微信时，用户发送的图片无法正常传递给 Claude Code。

错误信息：
```
API Error: 400 - unsupported image format: application/octet-stream
```

## 根本原因

iLink API 返回的图片消息包含 AES 加密的数据：

```json
{
  "item_list": [{
    "type": 2,
    "image_item": {
      "aeskey": "91c1db408d03b2c6ac5f56b3bb950697",
      "media": {
        "full_url": "https://novac2c.cdn.weixin.qq.com/c2c/download?...",
        "aes_key": "OTFjMWRiNDA4ZDAzYjJjNmFjNWY1NmIzYmI5NTA2OTc=",
        "encrypt_query_param": "..."
      }
    }
  }]
}
```

- `full_url` 返回的是 **AES 加密的数据流**，不是直接的图片文件
- 必须使用 `aeskey` 进行 **AES-128-ECB PKCS7** 解密
- 解密后才是真正的 JPG/PNG 图片数据

## 解决方案

### 1. 添加解密函数 (`api.js`)

```javascript
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

export async function downloadAndDecryptWeixinImage(imageItem) {
    const media = imageItem.media;
    const aesKeyHex = imageItem.aeskey;
    
    if (!media?.full_url || !aesKeyHex) {
        throw new Error('Missing required image data');
    }
    
    // 1. 下载加密数据
    const response = await fetch(media.full_url);
    if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
    }
    const encryptedData = Buffer.from(await response.arrayBuffer());
    
    // 2. AES-128-ECB 解密 (PKCS7 填充)
    const key = Buffer.from(aesKeyHex, 'hex');
    const decipher = crypto.createDecipheriv('aes-128-ecb', key, null);
    decipher.setAutoPadding(true);
    let decrypted = decipher.update(encryptedData);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    
    // 3. 识别图片格式
    const magic = decrypted.slice(0, 4).toString('hex');
    let ext = 'jpg';
    if (magic.startsWith('89504e47')) ext = 'png';
    else if (magic.startsWith('47494638')) ext = 'gif';
    else if (magic.startsWith('52494646')) ext = 'webp';
    
    // 4. 保存到临时文件
    const tempPath = path.join(
        os.tmpdir(), 
        `weixin_img_${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`
    );
    fs.writeFileSync(tempPath, decrypted);
    
    return tempPath;
}
```

### 2. 修改消息处理逻辑 (`channel.js`)

```javascript
import { 
    extractWeixinTextBody, 
    downloadAndDecryptWeixinImage,
    WeixinMessageItemType 
} from './api.js';

async dispatchInboundMessage(message) {
    // ... 原有代码 ...
    
    // 下载并解密图片
    const localFiles = [];
    const items = message.item_list || [];
    
    for (const item of items) {
        if (item.type === WeixinMessageItemType.IMAGE && item.image_item) {
            try {
                const localPath = await downloadAndDecryptWeixinImage(item.image_item);
                localFiles.push(localPath);
            } catch (err) {
                console.error('[WeixinChannel] Failed to decrypt image:', err);
            }
        }
    }
    
    const payload = {
        text: extractWeixinTextBody(message),
        files: localFiles,
    };
    
    // ... 传递给 handler ...
}
```

### 3. 处理纯图片消息 (`bot.js`)

```javascript
async handleMessage(msg, ctx) {
    let text = msg.text.trim();
    
    // 如果只有图片没有文字，添加默认提示词
    if (!text && msg.files.length > 0) {
        text = 'Please describe what you see in the image(s).';
    }
    
    // ... 后续处理 ...
}
```

## 修改文件列表

| 文件路径 | 修改类型 | 说明 |
|---------|---------|------|
| `pikiclaw/dist/channels/weixin/api.js` | 新增 | 添加解密函数和必要的模块导入 |
| `pikiclaw/dist/channels/weixin/channel.js` | 修改 | 集成图片解密逻辑 |
| `pikiclaw/dist/channels/weixin/bot.js` | 修改 | 添加纯图片消息的默认提示词 |

## 技术细节

### 加密算法
- **算法**: AES-128-ECB
- **填充**: PKCS7
- **Key**: 16 字节（从 `aeskey` 字段获取，十六进制字符串）

### 图片格式识别
通过文件头的 magic bytes 识别：

| 格式 | Magic Bytes |
|------|-------------|
| PNG | `89504e47` |
| JPG | `ffd8ff` |
| GIF | `47494638` |
| WebP | `52494646` |

### 数据流大小
- 加密数据: ~135KB (与原始图片大小相近)
- 解密数据: 与原始图片大小相同

## 调试方法

创建测试脚本验证解密逻辑：

```javascript
const crypto = require('crypto');

// 测试数据
const aesKeyHex = '91c1db408d03b2c6ac5f56b3bb950697';
const encryptedData = Buffer.from(await fetch(imageUrl).then(r => r.arrayBuffer()));

// 解密
const key = Buffer.from(aesKeyHex, 'hex');
const decipher = crypto.createDecipheriv('aes-128-ecb', key, null);
decipher.setAutoPadding(true);
let decrypted = decipher.update(encryptedData);
decrypted = Buffer.concat([decrypted, decipher.final()]);

// 验证
console.log('Magic bytes:', decrypted.slice(0, 4).toString('hex'));
fs.writeFileSync('test.jpg', decrypted);
```

## 注意事项

1. **临时文件清理**: 解密后的图片保存在系统临时目录，需要定期清理
2. **错误处理**: 网络下载失败或解密失败时需要优雅降级
3. **性能**: 图片下载+解密会增加消息处理时间（约 1-3 秒）
4. **兼容性**: 此方案仅适用于 iLink API 的微信接入方式

## 相关链接

- iLink API 文档: https://ilinkai.weixin.qq.com
- Node.js crypto 模块: https://nodejs.org/api/crypto.html
- AES 加密标准: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
