#!/bin/bash

# BGG Cookie 详细检查脚本

echo "================================"
echo "BGG Cookie 详细检查"
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

echo ""
echo "当前 Cookie 内容:"
echo "----------------"
echo "$BGG_COOKIE"
echo ""

echo "Cookie 分析:"
echo "----------------"
echo "总长度: ${#BGG_COOKIE} 字符"
echo ""

# 提取各个字段
USERNAME=$(echo "$BGG_COOKIE" | grep -oP 'bggusername=\K[^;]+')
PASSWORD=$(echo "$BGG_COOKIE" | grep -oP 'bggpassword=\K[^;]+')
SESSION=$(echo "$BGG_COOKIE" | grep -oP 'SessionID=\K[^;]+')

echo "字段提取:"
echo "  bggusername: $USERNAME"
echo "  bggpassword 长度: ${#PASSWORD}"
echo "  SessionID 长度: ${#SESSION}"
echo ""

echo "⚠️  重要提示:"
echo "----------------"
echo "BGG 网站可能使用的 Cookie 名称不是 'bggpassword'"
echo ""
echo "请在浏览器中检查实际的 Cookie 名称:"
echo "1. 登录 https://boardgamegeek.com/"
echo "2. F12 → Application → Cookies → boardgamegeek.com"
echo "3. 查找所有 Cookie，特别注意:"
echo "   - 是否有 'bggpassword' 这个名称？"
echo "   - 还是其他名称，如 'password', 'pass', 'auth' 等？"
echo ""
echo "4. 常见的 BGG Cookie 字段:"
echo "   - bggusername (用户名)"
echo "   - SessionID (会话ID)"
echo "   - 可能还有其他字段..."
echo ""

echo "测试 BGG API..."
echo "----------------"
RESPONSE=$(curl -s -w "\n%{http_code}" -H "Cookie: $BGG_COOKIE" \
    "https://boardgamegeek.com/xmlapi2/hot?type=boardgame")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ BGG API 认证成功！"
    echo ""
    echo "热门游戏（前3个）:"
    echo "$BODY" | grep -oP '<name rank="\d+">\K[^<]+' | head -3
else
    echo "❌ BGG API 认证失败 (HTTP $HTTP_CODE)"
    echo ""
    echo "可能的原因:"
    echo "  1. Cookie 字段名称不正确"
    echo "  2. Cookie 值不完整"
    echo "  3. Cookie 已过期"
    echo "  4. 缺少必需的 Cookie 字段"
    echo ""
    echo "建议:"
    echo "  • 仔细检查浏览器中的 Cookie 名称"
    echo "  • 确保复制了所有相关的 Cookie"
    echo "  • 或者申请 BGG API Key（推荐）"
fi

echo ""
