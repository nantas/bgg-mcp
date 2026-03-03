# BGG MCP 测试报告

**测试时间**: 2026-03-03  
**测试人员**: nantas  
**测试环境**: macOS, Docker 29.2.1

## ✅ 测试总结

### 成功的测试

1. ✅ **Docker 镜像构建**: 成功构建 `bgg-mcp:latest` 镜像
2. ✅ **本地二进制构建**: 成功构建 `build/bgg-mcp` 二进制文件
3. ✅ **HTTP 服务器模式**: 服务器可以正常启动和响应
4. ✅ **配置端点**: `/.well-known/mcp-config` 端点正常工作
5. ✅ **MCP 协议初始化**: MCP 初始化请求成功
6. ✅ **工具列表**: 成功获取到 10 个可用工具
7. ✅ **Docker 容器运行**: 容器可以正常启动和运行

### ⚠️ 需要注意的问题

1. ⚠️ **BGG API 认证**: 调用 `bgg-hot` 工具时返回 401 错误

## 📊 可用工具列表

成功发现以下 10 个工具：

1. **bgg-collection** - 查询用户的桌游收藏
2. **bgg-details** - 获取桌游详细信息
3. **bgg-hot** - 获取当前热门桌游列表
4. **bgg-price** - 获取桌游价格信息
5. **bgg-recommender** - 获取桌游推荐
6. **bgg-rules** - 搜索桌游规则相关问题
7. **bgg-search** - 搜索桌游
8. **bgg-thread-details** - 获取论坛帖子详情
9. **bgg-trade-finder** - 查找交易机会
10. **bgg-user** - 获取用户信息

## 🔍 401 错误诊断

### 可能的原因

1. **Cookie 格式不正确**
   - 确保格式为: `bggusername=值; bggpassword=值; SessionID=值`
   - 检查是否有额外的空格或引号

2. **Cookie 已过期**
   - BGG Cookie 有效期有限
   - 建议重新登录 BGG 网站获取新的 Cookie

3. **Cookie 值不完整**
   - 确保包含了所有必需的字段
   - 检查 `bggusername`, `bggpassword`, `SessionID` 都已设置

### 诊断步骤

1. **验证环境变量**
   ```bash
   source .env
   echo $BGG_COOKIE
   echo $BGG_USERNAME
   ```

2. **检查 Cookie 格式**
   ```bash
   # 应该看到类似这样的输出
   bggusername=yourname; bggpassword=xxxx; SessionID=yyyy
   ```

3. **重新获取 Cookie**
   - 登录 https://boardgamegeek.com/
   - F12 → Application → Cookies → boardgamegeek.com
   - 复制完整的 Cookie 字符串

4. **测试 Cookie 有效性**
   ```bash
   curl -H "Cookie: $(echo $BGG_COOKIE)" \
        https://boardgamegeek.com/xmlapi2/hot?type=boardgame
   ```

## 📝 下一步建议

### 选项 1: 修复 Cookie 认证（推荐用于测试）

1. 重新登录 BGG 网站获取新的 Cookie
2. 更新 `.env` 文件
3. 重新运行 `./test-api.sh`

### 选项 2: 申请 BGG API Key（推荐用于生产）

1. 访问 https://boardgamegeek.com/applications
2. 申请 API Key
3. 更新 `.env` 文件:
   ```bash
   BGG_API_KEY=your_api_key_here
   BGG_USERNAME=your_username
   ```
4. 更新 `bgg-mcp-config.json`:
   ```json
   {
     "env": {
       "BGG_API_KEY": "${BGG_API_KEY}",
       "BGG_USERNAME": "${BGG_USERNAME}"
     }
   }
   ```

### 选项 3: 集成到 MCP 客户端

即使认证有问题，MCP 服务器本身运行正常，可以：

1. 将 `bgg-mcp-config.json` 的内容添加到 MCP 客户端配置
2. 重启 MCP 客户端
3. 在客户端中测试工具调用
4. 根据实际错误信息进一步调试

## 🛠️ 测试文件

以下测试脚本已创建：

- `test-connection.sh` - 基础连接测试
- `test-api.sh` - MCP API 调用测试
- `setup-env.sh` - 环境变量配置向导

## 📚 相关文档

- `QUICK_START.md` - 快速开始指南
- `COOKIE_AUTH_GUIDE.md` - Cookie 认证详细指南
- `AGENTS.md` - 代码库指南（给 AI Agent）
- `README.md` - 项目文档

## ✅ 结论

BGG MCP 服务器已经成功部署并运行。MCP 协议层面完全正常，所有 10 个工具都已注册。

**主要问题**: BGG API 认证（401 错误），这是预期的，因为：
- Cookie 认证方式不稳定，容易过期
- 建议长期使用申请 BGG API Key

**建议**:
1. 短期：重新获取有效的 Cookie 进行测试
2. 长期：申请 BGG API Key 用于生产环境
3. 现在：可以先将 MCP 服务器集成到客户端，在实际使用中验证
