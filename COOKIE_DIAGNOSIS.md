# BGG Cookie 认证问题诊断报告

**测试时间**: 2026-03-03 15:26  
**测试人员**: nantas

## 🔍 问题诊断

### ❌ 发现的问题

**BGG Cookie 格式不完整**

当前 `.env` 文件中的 `BGG_COOKIE` 只包含：
- ✅ `bggusername=...` (存在)
- ❌ `bggpassword=...` (缺失)
- ❌ `SessionID=...` (缺失)

**结果**: BGG API 返回 401 未授权错误

### 📋 Cookie 要求

完整的 BGG Cookie 应该包含三个部分：

```
bggusername=你的用户名; bggpassword=加密密码; SessionID=会话ID
```

## ✅ 解决方案

### 步骤 1: 重新获取完整的 Cookie

1. **登录 BGG 网站**
   - 访问 https://boardgamegeek.com/
   - 使用你的账号登录

2. **打开浏览器开发者工具**
   - 按 `F12` 键（或右键 → 检查）
   - 切换到 **Application** 标签（Chrome/Edge）或 **Storage** 标签（Firefox）

3. **查找 Cookies**
   - 左侧菜单：展开 **Cookies**
   - 点击 **https://boardgamegeek.com**

4. **复制以下三个值**
   
   必需的字段：
   - `bggusername` - 你的 BGG 用户名
   - `bggpassword` - 加密的密码字符串（很长的字符串）
   - `SessionID` - 会话标识符

### 步骤 2: 更新 .env 文件

编辑 `.env` 文件，按以下格式填写：

```bash
# BGG Cookie 认证信息
BGG_COOKIE="bggusername=你的用户名; bggpassword=完整的加密密码字符串; SessionID=会话ID"

# BGG 用户名（纯文本）
BGG_USERNAME="nantas"
```

**重要提示**：
- Cookie 字符串需要用引号包裹
- 三个字段之间用分号 `;` 和空格分隔
- 不要修改 `bggpassword` 的值，原样复制即可

### 步骤 3: 重新测试

```bash
# 1. 重新加载环境变量
source .env

# 2. 验证 Cookie 长度（应该大于 100）
echo "Cookie 长度: ${#BGG_COOKIE}"

# 3. 运行测试
./test-api.sh
```

## 🔧 示例（虚构数据）

**错误示例** ❌:
```bash
BGG_COOKIE="bggusername=nantas"
# 缺少 bggpassword 和 SessionID
```

**正确示例** ✅:
```bash
BGG_COOKIE="bggusername=nantas; bggpassword=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6; SessionID=xyz123abc456def"
# 包含所有三个必需字段
```

## 🎯 验证 Cookie 格式

运行以下命令检查你的 Cookie 格式：

```bash
source .env

echo "检查 Cookie 组件:"
echo "$BGG_COOKIE" | grep -o "bggusername=" > /dev/null && echo "✅ bggusername 存在" || echo "❌ bggusername 缺失"
echo "$BGG_COOKIE" | grep -o "bggpassword=" > /dev/null && echo "✅ bggpassword 存在" || echo "❌ bggpassword 缺失"
echo "$BGG_COOKIE" | grep -o "SessionID=" > /dev/null && echo "✅ SessionID 存在" || echo "❌ SessionID 缺失"
```

## 📊 当前测试结果

### ✅ 成功的部分
- MCP 服务器启动正常
- MCP 协议初始化成功
- 工具列表获取成功（10 个工具）
- 配置端点正常工作

### ❌ 失败的部分
- `bgg-hot` 工具调用返回 401 错误
- 原因：Cookie 不完整

## 💡 替代方案：使用 BGG API Key

如果 Cookie 方式持续有问题，建议申请 BGG API Key：

1. **申请 API Key**
   - 访问：https://boardgamegeek.com/applications
   - 填写申请表单（说明用于个人研究）
   - 等待审批（通常几天）

2. **配置 API Key**
   ```bash
   # 更新 .env 文件
   BGG_API_KEY="your_api_key_here"
   BGG_USERNAME="nantas"
   # 可以移除或注释掉 BGG_COOKIE
   ```

3. **优势**
   - ✅ 更稳定，不易过期
   - ✅ 不需要定期更新
   - ✅ 官方推荐方式

## 📝 下一步

1. ✅ 按照上述步骤重新获取完整的 Cookie
2. ✅ 更新 `.env` 文件
3. ✅ 运行 `./test-api.sh` 验证
4. ✅ 如果成功，集成到 MCP 客户端

## 🔗 相关文档

- 快速开始：`QUICK_START.md`
- 认证指南：`COOKIE_AUTH_GUIDE.md`
- 之前的测试报告：`TEST_REPORT.md`
