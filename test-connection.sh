#!/bin/bash

# BGG MCP 连接测试脚本

set -e

CONTAINER_NAME="bgg-mcp-quick-test"
SERVER_PID=""

cleanup() {
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    docker stop "$CONTAINER_NAME" > /dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
}

trap cleanup EXIT

echo "================================"
echo "BGG MCP 连接测试"
echo "================================"
echo ""

# 加载环境变量
if [ -f .env ]; then
    source .env
    echo "✅ 环境变量已加载"
else
    echo "❌ 错误: .env 文件不存在"
    exit 1
fi

# 验证环境变量
if [ -z "$BGG_USERNAME" ]; then
    echo "❌ 错误: BGG_USERNAME 未设置"
    exit 1
fi

if [ -n "$BGG_API_KEY" ]; then
    AUTH_MODE="API Key"
    CONFIG_FILE="bgg-mcp-config-api-key.json"
elif [ -n "$BGG_COOKIE" ]; then
    AUTH_MODE="Cookie"
    CONFIG_FILE="bgg-mcp-config.json"
else
    echo "❌ 错误: 未设置 BGG_API_KEY 或 BGG_COOKIE"
    exit 1
fi

echo "✅ BGG_USERNAME: $BGG_USERNAME"
echo "✅ 认证方式: $AUTH_MODE"
echo ""

# 检查二进制文件
if [ ! -f build/bgg-mcp ]; then
    echo "❌ 错误: build/bgg-mcp 不存在"
    echo "请先运行: make build"
    exit 1
fi

echo "✅ 二进制文件存在"
echo ""

# 测试 1: 启动 HTTP 服务器
echo "================================"
echo "测试 1: HTTP 服务器模式"
echo "================================"
echo ""

PORT=8888
echo "启动 HTTP 服务器在端口 $PORT..."

# 启动服务器（后台运行）
BGG_API_KEY="$BGG_API_KEY" BGG_COOKIE="$BGG_COOKIE" BGG_USERNAME="$BGG_USERNAME" MCP_MODE=http MCP_PORT=$PORT ./build/bgg-mcp &
SERVER_PID=$!

# 等待服务器启动
sleep 2

# 检查服务器是否运行
if kill -0 $SERVER_PID 2>/dev/null; then
    echo "✅ 服务器已启动 (PID: $SERVER_PID)"
else
    echo "❌ 服务器启动失败"
    exit 1
fi

# 测试配置端点
echo ""
echo "测试配置端点..."
if curl -s -f http://localhost:$PORT/.well-known/mcp-config > /dev/null 2>&1; then
    echo "✅ 配置端点正常"
else
    echo "❌ 配置端点失败"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

# 停止服务器
echo ""
echo "停止服务器..."
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null
SERVER_PID=""
echo "✅ 服务器已停止"

echo ""
echo "================================"
echo "测试 2: Docker 容器"
echo "================================"
echo ""

# 测试 2: Docker 容器
echo "启动 Docker 容器..."
docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
docker run -d --name "$CONTAINER_NAME" \
    -p 8080:8080 \
    -e BGG_API_KEY="$BGG_API_KEY" \
    -e BGG_COOKIE="$BGG_COOKIE" \
    -e BGG_USERNAME="$BGG_USERNAME" \
    -e MCP_MODE=http \
    -e MCP_PORT=8080 \
    bgg-mcp > /dev/null

sleep 3

# 检查容器状态
if docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "✅ Docker 容器已启动"
else
    echo "❌ Docker 容器启动失败"
    docker logs "$CONTAINER_NAME" 2>&1
    exit 1
fi

# 测试配置端点
echo ""
echo "测试配置端点..."
if curl -s -f http://localhost:8080/.well-known/mcp-config > /dev/null 2>&1; then
    echo "✅ Docker 容器配置端点正常"
else
    echo "❌ Docker 容器配置端点失败"
    exit 1
fi

# 清理
echo ""
echo "清理测试容器..."
docker stop "$CONTAINER_NAME" > /dev/null 2>&1 || true
docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
echo "✅ 测试容器已清理"

echo ""
echo "================================"
echo "✅ 所有测试通过！"
echo "================================"
echo ""
echo "下一步："
echo "1. 将 ${CONFIG_FILE} 的内容添加到你的 MCP 客户端配置"
echo "2. 重启 MCP 客户端"
echo "3. 测试工具调用，例如："
echo "   - 'Show me the current BGG hotness list'"
echo "   - 'Search for Catan on BGG'"
echo ""
