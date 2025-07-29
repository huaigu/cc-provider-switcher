# Claude 供应商切换工具 (provider.sh)

一个用于在不同 AI 服务供应商之间快速切换的 Bash 脚本，支持 Claude 官方服务、智谱 GLM 和 Kimi 服务。

## 功能特性

### 🔄 供应商切换
- **cc** - 使用 Claude 官方服务
- **ccglm** - 使用智谱 GLM 服务
- **cckimi** - 使用 Kimi 服务

### ⚙️ 配置管理
- **cc_config** - 配置管理命令
  - `cc_config show` - 显示当前配置
  - `cc_config set <provider>` - 设置供应商 token
  - `cc_config clear [provider]` - 清除配置
  - `cc_config help` - 显示帮助

### 🔐 安全特性
- Token 安全存储（环境变量）
- 密码输入隐藏（silent read）
- 配置隔离（不同供应商使用不同变量）

## 支持的供应商

| 供应商 | 命令 | Token 变量名 | API 端点 |
|--------|------|-------------|----------|
| Claude 官方 | `cc` | ANTHROPIC_AUTH_TOKEN | 官方 API |
| 智谱 GLM | `ccglm` | ANTHROPIC_AUTH_TOKEN_GLM | https://open.bigmodel.cn/api/anthropic |
| Kimi | `cckimi` | ANTHROPIC_AUTH_TOKEN_KIMI | https://api.moonshot.cn/v1 |

## 安装和使用

### 1. 加载脚本
```bash
source provider.sh
```

### 2. 设置供应商 Token
```bash
# 设置 GLM token
cc_config set glm

# 设置 Kimi token
cc_config set kimi
```

### 3. 使用服务
```bash
# 使用 Claude 官方服务
cc

# 使用智谱 GLM 服务
ccglm

# 使用 Kimi 服务
cckimi
```

### 4. 查看配置
```bash
# 显示当前配置
cc_config show

# 显示帮助信息
cc_help
```

## 工作原理

### 环境变量管理
- 每个供应商使用独立的 token 变量
- 运行时动态设置 `ANTHROPIC_BASE_URL` 和 `ANTHROPIC_AUTH_TOKEN`
- 切换供应商时自动清空之前的配置

### Token 安全
- Token 通过 `read -s` 安全输入
- 存储在环境变量中，不会写入文件
- 支持 bash 和 zsh shell

### 配置持久化
- Token 设置后在当前会话中保持有效
- 可在 shell 配置文件中永久保存 token 变量

## 使用场景

1. **多供应商测试** - 快速测试不同 AI 服务的响应
2. **成本优化** - 根据需求选择最经济的供应商
3. **服务冗余** - 在某个服务不可用时切换到备用供应商
4. **开发调试** - 比较不同供应商的 API 表现

## 安全注意事项

- ⚠️ Token 是敏感信息，请妥善保管
- ⚠️ 不要在共享环境中使用此脚本
- ⚠️ 定期轮换 API token 以提高安全性
- ⚠️ 建议在受信任的环境中运行

## 限制

- 仅支持兼容 Anthropic API 格式的供应商
- 需要预先获取各供应商的 API token
- Token 仅在当前 shell 会话中有效（除非手动持久化）

## 技术细节

### 依赖项
- Bash shell
- Claude CLI 工具
- 各供应商的 API token

### 兼容性
- Linux/macOS
- Bash 4.0+
- Zsh shell

### 文件结构
```
provider.sh          # 主脚本
README.md           # 说明文档
```

## 示例工作流

```bash
# 1. 加载脚本
source provider.sh

# 2. 设置所有供应商的 token
cc_config set glm    # 输入 GLM token
cc_config set kimi   # 输入 Kimi token

# 3. 查看配置
cc_config show

# 4. 使用不同供应商
cc          # Claude 官方
ccglm       # 智谱 GLM
cckimi      # Kimi

# 5. 清除配置
cc_config clear
```

## 故障排除

### 常见问题
1. **命令未找到** - 确保已正确 `source provider.sh`
2. **Token 无效** - 检查 token 是否正确设置
3. **API 连接失败** - 检查网络连接和 API 端点

### 调试
```bash
# 显示当前环境变量
env | grep ANTHROPIC

# 重新加载脚本
source provider.sh
```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进此工具。