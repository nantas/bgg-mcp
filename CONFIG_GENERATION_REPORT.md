# 🎯 MCP 客户端配置文件

**生成时间**: 2026-03-03  
**状态**: ✅ Cookie 配置已生成 | ⏳ API Key 等待审批

---

## 📋 配置文件说明

我已根据你的 `.env` 文件内容生成了两个配置文件：

### 1️⃣ Cookie 配置（立即可用）

**文件**: `bgg-mcp-config-direct.json`

```json
{
  "bgg": {
    "command": "docker",
    "args": [
      "run",
      "-i",
      "--rm",
      "-e",
      "BGG_COOKIE",
      "-e",
      "BGG_USERNAME",
      "bgg-mcp"
    ],
    "env": {
      "BGG_COOKIE": "bggusername=nantas; bggpassword=10eo5abt3tr6cd51m2m7l5mnyr7t21ebn; SessionID=30494881348231ad85134f6901be3ad77664d287u1306509",
      "BGG_USERNAME": "nantas"
    }
  }
}
```

**使用场景**: 
- ✅ 立即测试 MCP 集成
- ⚠️ Cookie 可能已过期（返回 401）
- ⚠️ 即使过期，也可以验证 MCP 客户端配置是否正确

### 2️⃣ API Key 配置（推荐）

**文件**: `bgg-mcp-config-api-key.json`

```json
{
  "bgg": {
    "command": "docker",
    "args": [
      "run",
      "-i",
      "--rm",
      "-e",
      "BGG_API_KEY",
      "-e",
      "BGG_USERNAME",
      "bgg-mcp"
    ],
    "env": {
      "BGG_API_KEY": "${BGG_API_KEY}",
      "BGG_USERNAME": "${BGG_USERNAME}"
    }
  }
}
```

**使用场景**:
- ✅ 等你获得 BGG API Key 后使用
- ✅ 长期稳定使用
- ✅ 官方推荐方式

**配置步骤**:
1. 复制此配置到你的 MCP 客户端
2. 设置环境变量：
   ```bash
   export BGG_API_KEY="your_api_key_here"
   export BGG_USERNAME="nantas"
   ```
3. 重启 MCP 客户端

---

## 🚀 如何使用

### 方案 A: 立即测试（使用 Cookie 配置）

即使 Cookie 已过期，你也可以测试 MCP 集成是否正常：

1. **复制配置**
   ```bash
   cat bgg-mcp-config-direct.json
   ```

2. **添加到 MCP 客户端**
   - **Claude Desktop**: 
     ```
     ~/Library/Application Support/Claude/claude_desktop_config.json
     ```
   - **OpenCode**: 根据其配置方式
   - **其他客户端**: 相应配置文件

3. **重启客户端**

4. **测试配置**
   - 即使 BGG API 返回 401，客户端应该能看到 BGG MCP 工具
   - 这可以验证配置格式是否正确

5. **等 API Key 批准后**
   - 切换到 `bgg-mcp-config-api-key.json` 配置
   - 设置环境变量
   - 享受稳定使用

### 方案 B: 等待 API Key（推荐）

1. **等待 BGG API Key 审批**（1-3 天）

2. **收到 API Key 后**
   ```bash
   # 设置环境变量
   export BGG_API_KEY="your_approved_api_key"
   export BGG_USERNAME="nantas"
   
   # 添加到 shell 配置（永久）
   echo 'export BGG_API_KEY="your_api_key"' >> ~/.zshrc
   echo 'export BGG_USERNAME="nantas"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **使用 API Key 配置**
   ```bash
   cat bgg-mcp-config-api-key.json
   ```

4. **添加到 MCP 客户端**

5. **重启并测试**

---

## 📝 配置差异说明

### Cookie 配置 vs API Key 配置

| 特性 | Cookie 配置 | API Key 配置 |
|------|-------------|--------------|
| 环境变量 | `BGG_COOKIE` + `BGG_USERNAME` | `BGG_API_KEY` + `BGG_USERNAME` |
| 稳定性 | ⚠️ 易过期 | ✅ 长期有效 |
| 安全性 | ⚠️ 包含敏感信息 | ✅ 更安全 |
| 官方推荐 | ❌ 不推荐 | ✅ 推荐 |
| 配置复杂度 | 😐 中等 | 😊 简单 |

---

## ⚠️ 重要提示

### 关于 Cookie 配置

即使你的 Cookie 操作完全正确，BGG Cookie 仍然可能因为以下原因失效：

1. **时效性** - Cookie 有效期通常很短（几小时到几天）
2. **IP 限制** - BGG 可能对来自不同 IP 的请求有限制
3. **会话管理** - 浏览器会话结束后 Cookie 可能失效
4. **安全策略** - BGG 的安全策略可能拒绝某些请求

### 推荐做法

**立即测试配置格式，等待 API Key 后切换**

1. ✅ 使用 Cookie 配置测试 MCP 客户端集成
2. ✅ 验证配置格式是否正确
3. ✅ 等待 API Key 批准
4. ✅ 切换到 API Key 配置
5. ✅ 享受长期稳定使用

---

## 🔍 验证配置

### 测试步骤

1. **添加配置到客户端**
2. **重启客户端**
3. **检查工具列表** - 应该看到 10 个 BGG 工具
4. **尝试调用工具** - 即使返回 401，也说明配置正确
5. **等 API Key 后重新测试**

### 预期结果

**使用 Cookie 配置**:
- ✅ 客户端能看到 BGG MCP 工具
- ❌ 调用工具时可能返回 401（Cookie 过期）
- ✅ 证明配置格式正确

**使用 API Key 配置**:
- ✅ 客户端能看到 BGG MCP 工具
- ✅ 调用工具成功返回数据
- ✅ 长期稳定使用

---

## 📚 相关文档

- **FINAL_DIAGNOSIS.md** - 最终诊断报告
- **DEPLOYMENT_SUMMARY.md** - 部署总结
- **DOCUMENTATION_INDEX.md** - 文档导航

---

## 💡 总结

✅ **已生成两个配置文件**:
- `bgg-mcp-config-direct.json` - Cookie 配置（立即测试）
- `bgg-mcp-config-api-key.json` - API Key 配置（长期使用）

⏳ **下一步**:
1. 使用 Cookie 配置测试 MCP 集成
2. 等待 BGG API Key 批准
3. 切换到 API Key 配置
4. 享受稳定使用

🎉 **好消息**:
- 你的 Cookie 操作完全正确
- 配置已准备好
- API Key 申请已提交
- 很快就能使用了！
