# BGG MCP Cookie 鉴权配置指南

## 1. 获取 BGG Cookie 信息

### 方法一：通过浏览器开发者工具

1. 登录 [BoardGameGeek](https://boardgamegeek.com/)
2. 打开浏览器开发者工具（F12 或右键 -> 检查）
3. 切换到 "Application" 或 "存储" 标签
4. 在左侧找到 "Cookies" -> "https://boardgamegeek.com"
5. 查找以下 cookie 值：
   - `bggusername` - 你的用户名
   - `bggpassword` - 加密的密码
   - `SessionID` - 会话 ID

### 方法二：通过 Network 请求

1. 登录 BGG 后，打开开发者工具的 "Network" 标签
2. 刷新页面
3. 找到任意一个请求
4. 在请求头中找到 "Cookie" 字段
5. 复制完整的 cookie 字符串

## 2. 设置环境变量（推荐）

### macOS / Linux

#### 临时设置（仅当前终端会话有效）

```bash
# 设置 Cookie 信息
export BGG_COOKIE="bggusername=你的用户名; bggpassword=你的密码; SessionID=你的会话ID"

# 设置用户名
export BGG_USERNAME="你的BGG用户名"
```

#### 永久设置（推荐）

**方式一：使用 .env 文件（本地项目）**

1. 复制模板文件：
```bash
cp .env.example .env
```

2. 编辑 `.env` 文件，填写你的信息：
```bash
# .env
BGG_COOKIE="bggusername=你的用户名; bggpassword=你的密码; SessionID=你的会话ID"
BGG_USERNAME="你的BGG用户名"
```

3. 在 shell 配置中加载（如果使用 direnv 或类似工具）

**方式二：添加到 shell 配置文件**

编辑你的 shell 配置文件（`~/.zshrc`、`~/.bashrc` 或 `~/.bash_profile`）：

```bash
# BGG MCP 配置
export BGG_COOKIE="bggusername=你的用户名; bggpassword=你的密码; SessionID=你的会话ID"
export BGG_USERNAME="你的BGG用户名"
```

然后重新加载配置：
```bash
source ~/.zshrc  # 或 ~/.bashrc / ~/.bash_profile
```

### Windows

#### 临时设置（当前命令行窗口）

```cmd
set BGG_COOKIE=bggusername=你的用户名; bggpassword=你的密码; SessionID=你的会话ID
set BGG_USERNAME=你的BGG用户名
```

#### 永久设置

1. 右键"此电脑" -> "属性" -> "高级系统设置"
2. 点击"环境变量"
3. 在"用户变量"中点击"新建"
4. 添加两个变量：
   - 变量名：`BGG_COOKIE`
   - 变量值：`bggusername=你的用户名; bggpassword=你的密码; SessionID=你的会话ID`
   - 变量名：`BGG_USERNAME`
   - 变量值：`你的BGG用户名`

## 3. Cookie 字符串格式

完整格式应该是：
```
bggusername=实际用户名; bggpassword=加密密码值; SessionID=会话ID值
```

示例：
```
bggusername=john_doe; bggpassword=a1b2c3d4e5f6; SessionID=xyz789abc
```

## 4. 在不同客户端中使用

配置文件 `bgg-mcp-config.json` 已配置为读取环境变量，直接将配置添加到你的 MCP 客户端即可。

### Claude Desktop
将 `bgg-mcp-config.json` 的内容添加到：
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

### VS Code / Cursor
将配置添加到 `settings.json` 的 MCP 服务器配置部分

### OpenCode
根据 OpenCode 的配置方式添加到相应配置文件

## 5. 验证环境变量

在终端中运行以下命令验证环境变量是否设置成功：

```bash
# macOS / Linux
echo $BGG_COOKIE
echo $BGG_USERNAME

# Windows (cmd)
echo %BGG_COOKIE%
echo %BGG_USERNAME%

# Windows (PowerShell)
$env:BGG_COOKIE
$env:BGG_USERNAME
```

## 6. 注意事项

- ✅ `.env` 和 `bgg-mcp-config.json` 已添加到 `.gitignore`，不会被提交到 Git
- ⚠️ Cookie 有效期有限，过期后需要重新获取
- 🔒 不要将包含真实 cookie 的文件提交到版本控制系统
- 💡 如果使用 API Key 方式更稳定（推荐长期使用）

## 7. 测试连接

配置完成后，可以测试 MCP 工具是否正常工作：

1. 在支持的客户端中重新加载配置
2. 尝试使用 BGG MCP 工具，例如：
   - 搜索游戏："Search for Catan on BGG"
   - 查看热门："Show me the current BGG hotness list"
   - 查询用户收藏："Show me [username]'s game collection"
