# BGG MCP 快速配置指南

## 🚀 快速开始（3步完成）

### 步骤 1: 运行配置脚本

```bash
./setup-env.sh
```

按提示输入你的 BGG Cookie 信息。

### 步骤 2: 加载环境变量

**临时加载（推荐用于测试）:**
```bash
source .env
```

**永久加载:**
```bash
echo "source $(pwd)/.env" >> ~/.zshrc
source ~/.zshrc
```

### 步骤 3: 配置 MCP 客户端

将 `bgg-mcp-config.json` 的内容添加到你的 MCP 客户端配置文件中。

## 📖 手动配置（详细步骤）

### 1. 获取 BGG Cookie

1. 登录 https://boardgamegeek.com/
2. 按 `F12` 打开开发者工具
3. **Application** 标签 → **Cookies** → **https://boardgamegeek.com**
4. 复制以下值：
   - `bggusername`
   - `bggpassword`
   - `SessionID`

### 2. 创建 .env 文件

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```bash
BGG_COOKIE="bggusername=你的用户名; bggpassword=你的密码; SessionID=你的会话ID"
BGG_USERNAME="你的BGG用户名"
```

### 3. 设置环境变量

```bash
export BGG_COOKIE="bggusername=你的用户名; bggpassword=你的密码; SessionID=你的会话ID"
export BGG_USERNAME="你的BGG用户名"
```

### 4. 验证配置

```bash
echo $BGG_USERNAME  # 应该输出你的用户名
```

## 🔧 配置 MCP 客户端

### Claude Desktop

编辑配置文件：
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

添加 `bgg-mcp-config.json` 的内容。

### OpenCode / 其他 MCP 客户端

根据客户端文档，将 `bgg-mcp-config.json` 的内容添加到相应配置位置。

## ✅ 测试

重启你的 MCP 客户端，然后尝试：

```
"Show me the current BGG hotness list"
"Search for Catan on BGG"
```

## 🔒 安全说明

- ✅ `.env` 和 `bgg-mcp-config.json` 已在 `.gitignore` 中
- ✅ 不会被提交到 Git 仓库
- ⚠️ Cookie 有效期有限，过期后需重新获取
- 💡 长期使用建议申请 [BGG API Key](https://boardgamegeek.com/applications)

## 🆘 常见问题

### Q: 环境变量设置后不生效？
A: 确保重新加载了 shell 配置或在当前终端执行 `source .env`

### Q: Cookie 过期怎么办？
A: 重新登录 BGG 网站，获取新的 Cookie 并更新 `.env` 文件

### Q: 如何使用 API Key 代替 Cookie？
A: 申请 API Key 后，在 `.env` 中设置 `BGG_API_KEY` 代替 `BGG_COOKIE`

## 📚 相关文件

- `setup-env.sh` - 自动配置脚本
- `.env.example` - 环境变量模板
- `bgg-mcp-config.json` - MCP 客户端配置
- `COOKIE_AUTH_GUIDE.md` - 详细配置指南
