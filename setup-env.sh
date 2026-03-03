#!/bin/bash

# BGG MCP 环境变量设置脚本

echo "================================"
echo "BGG MCP 环境变量配置向导"
echo "================================"
echo ""

# 检查是否已有 .env 文件
if [ -f ".env" ]; then
    echo "⚠️  检测到已存在 .env 文件"
    read -p "是否要覆盖现有配置？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消操作"
        exit 1
    fi
fi

echo ""
echo "请按照以下步骤获取你的 BGG Cookie 信息："
echo "1. 登录 https://boardgamegeek.com/"
echo "2. 按 F12 打开浏览器开发者工具"
echo "3. 进入 Application (应用) 标签"
echo "4. 左侧菜单: Cookies → https://boardgamegeek.com"
echo "5. 找到并复制以下值:"
echo "   - bggusername (你的用户名)"
echo "   - bggpassword (加密密码)"
echo "   - SessionID (会话ID)"
echo ""
read -p "按回车键继续..."

echo ""
echo "================================"
echo "请输入你的 BGG 认证信息"
echo "================================"
echo ""

# 获取 BGG 用户名
read -p "BGG 用户名: " username

# 获取 Cookie 组件
echo ""
echo "请从浏览器 Cookie 中复制以下值："
read -p "bggusername 的值: " bgg_username
read -p "bggpassword 的值: " bgg_password
read -p "SessionID 的值: " session_id

# 构建 Cookie 字符串
cookie_string="bggusername=${bgg_username}; bggpassword=${bgg_password}; SessionID=${session_id}"

# 创建 .env 文件
cat > .env << EOF
# BGG MCP 环境变量配置
# 此文件包含敏感信息，已添加到 .gitignore

# BGG Cookie 认证信息
BGG_COOKIE="${cookie_string}"

# BGG 用户名（纯文本）
BGG_USERNAME="${username}"
EOF

echo ""
echo "✅ 配置文件已创建: .env"
echo ""
echo "================================"
echo "下一步操作"
echo "================================"
echo ""
echo "选择以下方式之一加载环境变量:"
echo ""
echo "方式 1: 临时加载（仅当前终端会话）"
echo "  source .env"
echo ""
echo "方式 2: 永久加载（添加到 shell 配置）"
echo "  echo 'source $(pwd)/.env' >> ~/.zshrc"
echo "  source ~/.zshrc"
echo ""
echo "方式 3: 使用 direnv（推荐用于项目）"
echo "  echo 'dotenv' > .envrc"
echo "  direnv allow"
echo ""
echo "验证环境变量:"
echo "  echo \$BGG_USERNAME"
echo ""
echo "配置 MCP 客户端:"
echo "  将 bgg-mcp-config.json 的内容添加到你的 MCP 客户端配置"
echo ""
