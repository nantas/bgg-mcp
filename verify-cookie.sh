#!/bin/bash

# BGG Cookie 格式验证脚本

echo "================================"
echo "BGG Cookie 格式验证"
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

# 检查必需字段
echo "检查 Cookie 组件:"
echo "----------------"

HAS_USERNAME=false
HAS_PASSWORD=false
HAS_SESSION=false

if echo "$BGG_COOKIE" | grep -q "bggusername="; then
    echo "✅ bggusername 存在"
    HAS_USERNAME=true
else
    echo "❌ bggusername 缺失"
fi

if echo "$BGG_COOKIE" | grep -q "bggpassword="; then
    echo "✅ bggpassword 存在"
    HAS_PASSWORD=true
else
    echo "❌ bggpassword 缺失"
fi

if echo "$BGG_COOKIE" | grep -q "SessionID="; then
    echo "✅ SessionID 存在"
    HAS_SESSION=true
else
    echo "❌ SessionID 缺失"
fi

echo ""
echo "Cookie 信息:"
echo "----------------"
echo "长度: ${#BGG_COOKIE} 字符"
echo "用户名: $BGG_USERNAME"
echo ""

# 判断结果
if [ "$HAS_USERNAME" = true ] && [ "$HAS_PASSWORD" = true ] && [ "$HAS_SESSION" = true ]; then
    echo "================================"
    echo "✅ Cookie 格式正确"
    echo "================================"
    echo ""
    
    # 估算合理性
    if [ ${#BGG_COOKIE} -lt 100 ]; then
        echo "⚠️  警告: Cookie 长度较短 (${#BGG_COOKIE} 字符)"
        echo "   通常完整的 Cookie 应该大于 100 字符"
        echo "   建议检查是否完整复制了所有值"
    else
        echo "✅ Cookie 长度合理 (${#BGG_COOKIE} 字符)"
    fi
    
    echo ""
    echo "下一步: 运行 ./test-api.sh 进行完整测试"
    exit 0
else
    echo "================================"
    echo "❌ Cookie 格式不完整"
    echo "================================"
    echo ""
    echo "缺少的组件:"
    [ "$HAS_USERNAME" = false ] && echo "  - bggusername"
    [ "$HAS_PASSWORD" = false ] && echo "  - bggpassword"
    [ "$HAS_SESSION" = false ] && echo "  - SessionID"
    echo ""
    echo "请按照 COOKIE_DIAGNOSIS.md 中的步骤重新获取完整的 Cookie"
    echo ""
    echo "正确的格式应该是:"
    echo 'BGG_COOKIE="bggusername=你的用户名; bggpassword=加密密码; SessionID=会话ID"'
    echo ""
    exit 1
fi
