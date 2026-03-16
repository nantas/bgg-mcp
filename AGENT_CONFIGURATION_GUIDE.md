# BGG MCP Agent 配置指南（全局/仓库）

本指南面向 Coding Agent（Claude/Cursor/Codex 等）在不同仓库中稳定使用 `bgg-mcp`。

## 推荐结论

推荐默认使用 **全局 Docker 配置**，不要把 `bgg-mcp` 绑定到某个单独仓库。

原因：

1. 配置一次，全仓库可复用。
2. 运行环境一致，不依赖各仓库本地 Go 环境。
3. 版本可控（镜像 tag 可固定），升级/回滚简单。
4. 减少凭证散落到多个项目的风险。

## 运行机制说明

当客户端使用如下模式启动 MCP server：

- `command: "docker"`
- `args: ["run", "-i", "--rm", ...]`

行为是：每次会话直接执行 `docker run` 新起一个容器，结束后自动删除。  
不会先检查并复用你已有的常驻容器。

## 方案 A：全局 Docker 配置（推荐）

将以下配置放到你的 MCP 客户端全局配置（按客户端文档位置）：

```json
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
    "kdaniel/bgg-mcp:1.6.0"
  ],
  "env": {
    "BGG_API_KEY": "your_bgg_api_key",
    "BGG_USERNAME": "your_bgg_username"
  }
}
```

注意：

1. 建议固定镜像 tag（如 `1.6.0`），避免不可控变化。
2. 不建议在仓库内提交含真实 key 的配置文件。
3. 优先使用 `BGG_API_KEY`，仅在特殊情况下使用 `BGG_COOKIE`。

## 方案 B：仓库内本地二进制配置（调试优先）

适合你在当前仓库深度开发/调试 `bgg-mcp` 本身。

步骤：

1. 构建二进制：`make build`
2. MCP 配置指向本地绝对路径：

```json
"bgg": {
  "command": "/absolute/path/to/bgg-mcp/build/bgg-mcp",
  "args": ["-mode", "stdio"],
  "env": {
    "BGG_API_KEY": "your_bgg_api_key",
    "BGG_USERNAME": "your_bgg_username"
  }
}
```

什么时候选本地二进制：

1. 你需要改代码后立即验证，不想重建镜像。
2. 你希望在本地直接打断点/查看日志。

## 凭证与安全建议

1. API key 放在客户端配置或受控密钥管理，不写入 Git 仓库。
2. `.env` 仅用于本地测试，且必须在 `.gitignore` 中。
3. 不要在 issue、日志、截图里暴露完整 key。

## 验证清单

完成配置后，最小验证为：

1. 客户端可发现 `bgg` server。
2. `tools/list` 返回 10 个工具。
3. 调用 `bgg-hot` 成功返回数据。

仓库内可执行：

```bash
./test-connection.sh
./test-api.sh
```

## 常见问题

### 1) `401 Unauthorized`

高概率原因：

1. `BGG_API_KEY` 未实际传给进程/容器。
2. 使用了 `source .env` 但没有通过 `env` 配置或显式传值注入。
3. key 本身无效或暂未生效。

建议：

1. 优先在 MCP 配置 `env` 段显式设置 `BGG_API_KEY`。
2. 不依赖 shell 临时变量隐式继承。

### 2) `docker: image not found`

1. 先 `docker pull kdaniel/bgg-mcp:1.6.0`
2. 检查镜像名/tag 是否写错。

### 3) 工具可列出但调用失败

1. 先确认认证（API key）正确。
2. 再看具体工具入参是否满足要求。

## 版本维护建议

1. 生产稳定期固定镜像 tag。
2. 升级前先在单机验证，再更新全局配置。
3. 若升级后异常，直接回退旧 tag。
