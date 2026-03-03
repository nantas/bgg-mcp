# 🔍 BGG Cookie 详细检查指南

**当前状态**: ❌ 仍然返回 401 Unauthorized  
**可能原因**: Cookie 字段名称不正确或不完整

---

## 📋 请仔细检查浏览器中的 Cookie

### 步骤 1: 登录 BGG 网站

1. 访问: https://boardgamegeek.com/
2. 确保已登录

### 步骤 2: 打开开发者工具

1. 按 `F12` 键
2. 切换到 **Application** 标签（Chrome/Edge）或 **Storage** 标签（Firefox）

### 步骤 3: 查看 Cookies

1. 左侧菜单：展开 **Cookies**
2. 点击 **https://boardgamegeek.com**

### 步骤 4: 截图并检查所有 Cookie

**重要**：请列出所有可见的 Cookie 名称和值

#### 常见的 BGG Cookie 字段

请检查是否存在以下字段：

| 字段名 | 说明 | 你的值 |
|--------|------|--------|
| `bggusername` | 用户名 | ✅ 已确认 |
| `SessionID` | 会话ID | ✅ 已确认 |
| **`bggpassword`** | **密码字段** | ⚠️ **请确认名称** |
| `password` | 可能的密码字段 | ❓ 请检查 |
| `pass` | 可能的密码字段 | ❓ 请检查 |
| `auth` | 可能的认证字段 | ❓ 请检查 |
| `rememberme` | 记住登录 | ❓ 请检查 |

### 步骤 5: 检查 bggpassword 的实际名称

**重要**：浏览器中的 Cookie 名称可能不是 `bggpassword`

请仔细查看：
- Cookie 列表中是否有 **包含 "pass" 或 "auth" 的字段**？
- 完整的 Cookie 名称是什么？
- 是否有多个与认证相关的 Cookie？

### 步骤 6: 复制完整的 Cookie 字符串

**方法 A: 复制单个 Cookie 值**

如果你找到了正确的密码字段：
1. 复制该 Cookie 的名称（例如：`bggpassword` 或其他）
2. 复制该 Cookie 的值（很长的字符串）
3. 更新 `.env` 文件

**方法 B: 复制完整 Cookie 字符串**

1. 在开发者工具的 **Network** 标签
2. 刷新页面
3. 点击任意一个请求
4. 在 **Headers** 部分找到 **Request Headers**
5. 找到 **Cookie:** 字段
6. 复制完整的 Cookie 字符串

示例格式：
```
bggusername=nantas; SessionID=30494881348231ad85134f6901be3ad77664d287u1306509; bggpassword=很长的字符串
```

**注意**：Cookie 字段的顺序可能不同，但格式应该用分号和空格分隔。

---

## ⚠️ 常见问题

### 问题 1: Cookie 名称不匹配

**症状**: Cookie 格式看起来正确，但 BGG API 返回 401

**原因**: 密码字段的名称可能不是 `bggpassword`

**解决**: 
- 仔细检查浏览器中的实际 Cookie 名称
- 可能是 `password`、`pass`、`auth` 或其他名称

### 问题 2: Cookie 值不完整

**症状**: Cookie 值看起来很短或不完整

**原因**: 没有完整复制整个值

**解决**:
- 双击 Cookie 值，确保选中整个字符串
- 或者使用复制按钮（如果有）

### 问题 3: Cookie 已过期

**症状**: Cookie 格式和值都正确，但仍然 401

**原因**: Cookie 已过期

**解决**:
- 完全退出 BGG 网站
- 清除浏览器 Cookie
- 重新登录
- 获取新 Cookie

---

## 💡 推荐：使用 BGG API Key

**为什么推荐 API Key？**

1. ✅ **更稳定** - 不易过期，长期有效
2. ✅ **更简单** - 只需要一个密钥，不需要多个 Cookie 字段
3. ✅ **更安全** - 官方推荐方式
4. ✅ **更可靠** - 不会因为浏览器会话过期而失效

**如何申请？**

1. **访问申请页面**
   ```
   https://boardgamegeek.com/applications
   ```

2. **填写申请表单**
   - 应用名称: `BGG MCP for Personal Research`
   - 描述: `Personal research tool for board game design analysis using Model Context Protocol`
   - 用途: Research and development

3. **等待审批**
   - 通常 1-3 个工作日
   - 会通过邮件通知

4. **获取 API Key 后配置**
   ```bash
   # 编辑 .env 文件
   BGG_API_KEY="your_api_key_here"
   BGG_USERNAME="nantas"
   # 删除或注释 BGG_COOKIE
   ```

5. **测试**
   ```bash
   ./test-api.sh
   ```

---

## 🎯 立即行动建议

### 方案 A: 继续调试 Cookie（需要更多时间）

1. ✅ 检查浏览器中的所有 Cookie 名称
2. ✅ 确认密码字段的实际名称
3. ✅ 复制完整的 Cookie 字符串
4. ✅ 更新 `.env` 文件
5. ✅ 运行 `./test-cookie-local.sh` 测试

**预计时间**: 10-20 分钟  
**成功率**: 取决于 Cookie 是否有效

### 方案 B: 申请 API Key（推荐）

1. ✅ 访问 https://boardgamegeek.com/applications
2. ✅ 填写申请表单
3. ✅ 等待审批（1-3 天）
4. ✅ 配置 API Key
5. ✅ 享受长期稳定使用

**预计时间**: 1-3 天  
**成功率**: 100%（官方支持）

---

## 📊 当前诊断结果

| 项目 | 状态 | 说明 |
|------|------|------|
| Cookie 格式 | ✅ | 格式正确（125 字符） |
| bggusername | ✅ | 存在 |
| SessionID | ✅ | 存在 |
| bggpassword | ⚠️ | 存在，但名称可能不正确 |
| BGG API 响应 | ❌ | 401 Unauthorized |
| 建议方案 | 💡 | 申请 API Key |

---

## 📞 需要帮助？

如果你：
- 找到了正确的 Cookie 字段名称
- 确认 Cookie 格式和值都正确
- 但仍然返回 401

那么：
- **Cookie 已过期**，需要重新获取
- 或者**直接申请 API Key**（推荐）

---

**下一步**: 
- 检查浏览器中的实际 Cookie 字段名称
- 或申请 BGG API Key 用于长期稳定使用
