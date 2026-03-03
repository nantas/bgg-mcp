#!/bin/bash

# BGG Cookie 快速验证脚本（本地测试，不使用 Docker）

echo "================================"
echo "BGG Cookie 本地验证"
echo "================================"
echo ""

# 加载环境变量
if [ -f .env ]; then
    source .env
    echo "✅ 环境变量已加载"
    echo "   用户名: $BGG_USERNAME"
    echo "   Cookie 长度: ${#BGG_COOKIE}"
else
    echo "❌ 错误: .env 文件不存在"
    echo ""
    echo "请先运行: ./setup-env.sh"
    exit 1
fi

echo ""
echo "================================"
echo "测试 BGG API 连接"
echo "================================"
echo ""

# 测试热门游戏列表 API
echo "正在测试 BGG API..."
RESPONSE=$(curl -s -w "%{http_code}" -H "Cookie: $BGG_COOKIE" \
    "https://boardgamegeek.com/xmlapi2/hot?type=boardgame")

if [ "$RESPONSE" = "200" ]; then
    echo "✅ BGG API 连接成功！"
    echo ""
    echo "获取前 3 个热门游戏:"
    curl -s -H "Cookie: $BGG_COOKIE" \
        "https://boardgamegeek.com/xmlapi2/hot?type=boardgame" | \
        grep -o '<name rank="[^"]*">[^<]*</name>' | \
        head -3 | \
        sed 's/<name rank="\([0-9]*\)">\(.*\)<\/name>/\1. \2/'
    
    echo ""
    echo "================================"
    echo "✅ Cookie 验证成功！"
    echo "================================"
    echo ""
    echo "下一步："
    echo "  1. 运行 ./test-api.sh 进行完整测试"
    echo "  2. 集成到 MCP 客户端"
    echo ""
else
    echo "❌ BGG API 连接失败 (HTTP $RESPONSE)"
    echo ""
    if [ "$RESPONSE" = "401" ]; then
        echo "可能的原因:"
        echo "  • Cookie 已过期"
        echo "  • Cookie 值不正确"
        echo "  • Cookie 格式错误"
        echo ""
        echo "解决方法:"
        echo "  1. 重新登录 BGG 网站获取新 Cookie"
        echo "  2. 仔细检查 Cookie 值是否完整复制"
        echo "  3. 运行 ./setup-env.sh 重新配置"
    elif [ "$RESPONSE" = "000" ]; then
        echo "❌ 无法连接到 BGG 服务器"
        echo "  • 检查网络连接"
        echo "  • 稍后重试"
    else
        echo "❌ 未知错误 (HTTP $RESPONSE)"
    fi
    echo ""
    exit 1
fi
