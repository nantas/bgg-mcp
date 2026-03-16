#!/bin/bash

# BGG MCP 实际 API 调用测试

set -e

CONTAINER_NAME="bgg-mcp-api-test"

cleanup() {
    docker stop "$CONTAINER_NAME" > /dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
}

trap cleanup EXIT

echo "================================"
echo "BGG MCP API 调用测试"
echo "================================"
echo ""

# 加载环境变量
if [ -f .env ]; then
    source .env
    echo "✅ 环境变量已加载"
    echo "   BGG_USERNAME: $BGG_USERNAME"
else
    echo "❌ 错误: .env 文件不存在"
    exit 1
fi

echo ""

if [ -n "$BGG_API_KEY" ]; then
    echo "✅ 认证方式: API Key"
elif [ -n "$BGG_COOKIE" ]; then
    echo "✅ 认证方式: Cookie"
else
    echo "❌ 错误: 未设置 BGG_API_KEY 或 BGG_COOKIE"
    exit 1
fi

echo ""

# 启动 Docker 容器（HTTP 模式）
echo "启动 Docker 容器..."
docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
docker run -d --name "$CONTAINER_NAME" \
    -p 9090:9090 \
    -e BGG_API_KEY="$BGG_API_KEY" \
    -e BGG_COOKIE="$BGG_COOKIE" \
    -e BGG_USERNAME="$BGG_USERNAME" \
    -e MCP_MODE=http \
    -e MCP_PORT=9090 \
    bgg-mcp > /dev/null

sleep 3

echo "✅ 容器已启动"
echo ""

# 测试 MCP 协议
echo "================================"
echo "测试 MCP 工具调用"
echo "================================"
echo ""

# MCP 初始化请求
echo "1. 发送 MCP 初始化请求..."
INIT_RESPONSE=$(curl -s -X POST http://localhost:9090/mcp \
    -H "Content-Type: application/json" \
    -d '{
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {
                "name": "test-client",
                "version": "1.0.0"
            }
        }
    }')

if echo "$INIT_RESPONSE" | jq -e '.result' > /dev/null 2>&1; then
    echo "✅ MCP 初始化成功"
    echo "   服务器信息:"
    echo "$INIT_RESPONSE" | jq -r '.result.serverInfo | "   - 名称: \(.name)\n   - 版本: \(.version)"'
else
    echo "❌ MCP 初始化失败"
    echo "$INIT_RESPONSE" | jq .
    exit 1
fi

echo ""

# 列出可用工具
echo "2. 获取可用工具列表..."
TOOLS_RESPONSE=$(curl -s -X POST http://localhost:9090/mcp \
    -H "Content-Type: application/json" \
    -d '{
        "jsonrpc": "2.0",
        "id": 2,
        "method": "tools/list"
    }')

TOOL_COUNT=$(echo "$TOOLS_RESPONSE" | jq -r '.result.tools | length')
if [ "$TOOL_COUNT" -gt 0 ]; then
    echo "✅ 找到 $TOOL_COUNT 个工具:"
    echo "$TOOLS_RESPONSE" | jq -r '.result.tools[] | "   - \(.name): \(.description[:60])..."'
else
    echo "❌ 未找到任何工具"
    exit 1
fi

echo ""

# 测试 bgg-hot 工具
echo "3. 测试 bgg-hot 工具..."
HOT_RESPONSE=$(curl -s -X POST http://localhost:9090/mcp \
    -H "Content-Type: application/json" \
    -d '{
        "jsonrpc": "2.0",
        "id": 3,
        "method": "tools/call",
        "params": {
            "name": "bgg-hot",
            "arguments": {}
        }
    }')

HOT_TEXT=$(echo "$HOT_RESPONSE" | jq -r '.result.content[0].text // empty')
if [[ "$HOT_TEXT" == Error:* ]]; then
    echo "❌ bgg-hot 工具调用失败:"
    echo "   $HOT_TEXT"
    exit 1
fi
if [[ "$HOT_TEXT" == *"unexpected status code"* ]]; then
    echo "❌ bgg-hot 工具调用失败:"
    echo "   $HOT_TEXT"
    exit 1
fi

if [ -n "$HOT_TEXT" ] && echo "$HOT_TEXT" | jq -e 'type=="array" and length>0' > /dev/null 2>&1; then
    echo "✅ bgg-hot 工具调用成功"
    echo "   热门游戏列表（前3个）:"
    echo "$HOT_TEXT" | jq -r '.[0:3][] | "   \((.Rank // .rank // .rank.value // "N/A")). \((.Name.Value // .name.value // .Name // .name // "N/A")) (\(.YearPublished.Value // .yearpublished.value // .YearPublished // .yearpublished // "N/A"))"'
else
    echo "❌ bgg-hot 返回数据格式异常:"
    echo "   $HOT_TEXT"
    exit 1
fi

echo ""

# 清理
echo "================================"
echo "清理测试环境"
echo "================================"
echo ""
docker stop "$CONTAINER_NAME" > /dev/null 2>&1 || true
docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
echo "✅ 测试容器已清理"

echo ""
echo "================================"
echo "✅ API 测试完成"
echo "================================"
echo ""
echo "BGG MCP 服务器运行正常，可以集成到 MCP 客户端中使用。"
echo ""
