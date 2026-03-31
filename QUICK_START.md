# BGG MCP 快速配置指南

## 🚀 快速开始（macOS 容器 + Windows 远程连接）

### 步骤 1: 在 macOS 主机上生成运行环境文件

```bash
./setup-env.sh
```

按提示输入你的 BGG 认证信息。脚本会同时生成：

- `.env`，供本机调试使用
- `docker-compose.macos-http.env`，供 macOS Docker 容器使用

### 步骤 2: 启动 macOS 上的 HTTP 服务

```bash
docker compose -f docker-compose.macos-http.yml up -d
```

验证服务是否启动：

```bash
curl -fsS http://localhost:8080/.well-known/mcp-config
```

### 步骤 3: 在 Windows 端配置远程 MCP 客户端

编辑 `windows-mcp-remote.json`，把 `macos-host.local` 改成 macOS 主机的 LAN 或 VPN 地址，然后导入支持远程 MCP 的客户端。

### 步骤 4: 可选的本地环境加载

如果你仍然需要本机 shell 调试，可以加载 `.env`：

**临时加载（推荐用于测试）:**
```bash
source .env
```

**永久加载:**
```bash
echo "source $(pwd)/.env" >> ~/.zshrc
source ~/.zshrc
```

## 📖 手动配置（详细步骤）

### 1. 获取 BGG 认证信息

如果你使用 API Key，先去 [BoardGameGeek applications 页面](https://boardgamegeek.com/applications)申请一个。

如果你使用 Cookie：

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
BGG_API_KEY="你的API Key"
BGG_USERNAME="你的BGG用户名"
```

### 3. 设置环境变量

```bash
export BGG_API_KEY="你的API Key"
export BGG_USERNAME="你的BGG用户名"
```

### 4. 验证配置

```bash
echo $BGG_USERNAME  # 应该输出你的用户名
```

## 🔧 配置 MCP 客户端

### macOS Docker Host

将 `docker-compose.macos-http.env.example` 复制为 `docker-compose.macos-http.env`，填入真实值，然后运行：

```bash
docker compose -f docker-compose.macos-http.yml up -d
```

### Claude Desktop

编辑配置文件：
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

如果你是本机 stdio 模式，添加 `bgg-mcp-config.json` 的内容。

如果你是远程 HTTP 模式，请导入 `windows-mcp-remote.json` 并把 URL 改成 macOS 主机地址。

### OpenCode / 其他 MCP 客户端

根据客户端文档，将 `bgg-mcp-config.json` 的内容添加到相应配置位置。

## ✅ 测试

重启你的 MCP 客户端，然后尝试：

```
"Show me the current BGG hotness list"
"Search for Catan on BGG"
```

## 🔒 安全说明

- ✅ `.env`、`docker-compose.macos-http.env` 和 `bgg-mcp-config.json` 已在 `.gitignore` 中
- ✅ 不会被提交到 Git 仓库
- ⚠️ Cookie 有效期有限，过期后需重新获取
- 💡 长期使用建议申请 [BGG API Key](https://boardgamegeek.com/applications)

## 🆘 常见问题

### Q: 环境变量设置后不生效？
A: 确保重新加载了 shell 配置或在当前终端执行 `source .env`

### Q: Cookie 过期怎么办？
A: 重新登录 BGG 网站，获取新的 Cookie 并更新 `.env` 文件

### Q: 如何使用 API Key 代替 Cookie？
A: 申请 API Key 后，在 `.env` 中设置 `BGG_API_KEY`，或者直接运行 `./setup-env.sh` 选择 API Key 选项

## 📚 相关文件

- `setup-env.sh` - 自动配置脚本
- `.env.example` - 环境变量模板
- `docker-compose.macos-http.env.example` - macOS Docker 主机环境模板
- `bgg-mcp-config.json` - MCP 客户端配置
- `windows-mcp-remote.json` - Windows 远程 MCP 配置模板
- `COOKIE_AUTH_GUIDE.md` - 详细配置指南
