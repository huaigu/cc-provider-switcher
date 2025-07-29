# Claude 供应商切换工具 (provider.sh)

一个用于在不同 AI 服务供应商之间快速切换的 Bash 脚本，支持 Claude 官方服务、智谱 GLM 和 Kimi 服务。

## 🚀 快速开始

### 一行命令安装
```bash
curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash
```

### 一行命令卸载
```bash
curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash -s uninstall
```

安装完成后重新启动 shell，然后就可以使用：
- `cc` - Claude 官方服务
- `ccglm` - 智谱 GLM 服务  
- `cckimi` - Kimi 服务

## 功能特性

### 🔄 供应商切换
- **cc** - 使用 Claude 官方服务
- **ccglm** - 使用智谱 GLM 服务
- **cckimi** - 使用 Kimi 服务

### ⚙️ 配置管理
- **cc_config** - 配置管理命令
  - `cc_config show` - 显示当前配置
  - `cc_config set <provider>` - 设置供应商 token
  - `cc_config clear [provider]` - 清除环境变量
  - `cc_config delete <provider>` - 删除持久化存储
  - `cc_config install [shell]` - 安装到 shell 配置文件（持久生效）
  - `cc_config uninstall` - 从 shell 配置文件卸载
  - `cc_config status` - 显示安装状态
  - `cc_config help` - 显示帮助

### 🔐 安全特性
- Token 安全存储（环境变量 + 持久化配置文件）
- 密码输入隐藏（silent read）
- 配置隔离（不同供应商使用不同变量）
- 文件权限保护（配置文件 600，目录 700）
- 自动备份机制（修改前自动备份）

## 支持的供应商

| 供应商 | 命令 | Token 变量名 | API 端点 |
|--------|------|-------------|----------|
| Claude 官方 | `cc` | ANTHROPIC_AUTH_TOKEN | 官方 API |
| 智谱 GLM | `ccglm` | ANTHROPIC_AUTH_TOKEN_GLM | https://open.bigmodel.cn/api/anthropic |
| Kimi | `cckimi` | ANTHROPIC_AUTH_TOKEN_KIMI | https://api.moonshot.cn/v1 |

## 安装和使用

### 1. 选择安装方式

#### 在线一键安装（最推荐）
```bash
# 直接从 GitHub 仓库安装（无需下载文件）
curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash

# 或者使用 wget
wget -qO- https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash
```

#### 本地一键安装
```bash
# 下载脚本后安装
./provider.sh install

# 或手动指定 shell 类型
./provider.sh install bash
./provider.sh install zsh

# 查看安装帮助
./provider.sh help
```

#### 临时使用（当前会话有效）
```bash
source provider.sh
```

#### 传统安装方式
```bash
# 自动检测 shell 类型并安装
cc_config install

# 或手动指定 shell 类型
cc_config install bash
cc_config install zsh
```

### 2. 设置供应商 Token

安装完成后，设置各供应商的 API token：

```bash
# 设置 GLM token
cc_config set glm

# 设置 Kimi token  
cc_config set kimi

# 查看当前配置
cc_config show
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

### 4. 管理配置
```bash
# 显示当前配置
cc_config show

# 显示安装状态
cc_config status

# 删除特定供应商的持久化存储
cc_config delete glm
cc_config delete kimi

# 删除所有持久化存储
cc_config delete all
```

### 5. 卸载
```bash
# 在线一键卸载（最推荐）
curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash -s uninstall

# 或者使用 wget
wget -qO- https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash -s uninstall

# 本地一键卸载
./provider.sh uninstall

# 或传统卸载方式
cc_config uninstall
```

### 6. 查看帮助
```bash
# 显示帮助信息
cc_help

# 显示配置管理帮助
cc_config help
```

## 工作原理

### 环境变量管理
- 每个供应商使用独立的 token 变量
- 运行时动态设置 `ANTHROPIC_BASE_URL` 和 `ANTHROPIC_AUTH_TOKEN`
- 切换供应商时自动清空之前的配置

### Token 安全
- Token 通过 `read -s` 安全输入
- 存储在环境变量中，同时支持持久化存储
- 支持 bash 和 zsh shell

### 配置持久化
- **自动持久化**: Token 设置后自动保存到 `~/.cc-provider-switcher/tokens.conf`
- **会话持久化**: 环境变量在当前 shell 会话中保持有效
- **安装持久化**: 通过 `cc_config install` 安装到 shell 配置文件，重启后仍然有效
- **安全存储**: 配置文件权限 600，目录权限 700

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
- 需要安装 Claude CLI 工具
- 支持 Linux/macOS 系统

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
CLAUDE.md           # 开发文档
```

### 配置文件和目录
```
~/.cc-provider-switcher/               # 配置目录（权限 700）
├── tokens.conf                        # Token 持久化存储（权限 600）
├── tokens.conf.backup                 # 自动备份文件
└── .installed                         # 安装标记文件
```

## 示例工作流

### 临时使用工作流
```bash
# 1. 加载脚本（当前会话有效）
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

# 5. 清除当前会话配置
cc_config clear
```

### 在线一键安装工作流（最推荐）
```bash
# 1. 在线一键安装（自动检测 shell 类型）
curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash

# 2. 重新启动 shell 或重新加载配置
source ~/.bashrc  # 或 source ~/.zshrc

# 3. 设置 token（自动持久化保存）
cc_config set glm
cc_config set kimi

# 4. 验证安装状态
cc_config status

# 5. 使用不同供应商
cc
ccglm
cckimi

# 6. 在线一键卸载（如需要）
curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash -s uninstall
```

### 本地一键安装工作流
```bash
# 1. 一键安装（自动检测 shell 类型）
./provider.sh install

# 2. 重新启动 shell 或重新加载配置
source ~/.bashrc  # 或 source ~/.zshrc

# 3. 设置 token（自动持久化保存）
cc_config set glm
cc_config set kimi

# 4. 验证安装状态
cc_config status

# 5. 使用不同供应商
cc
ccglm
cckimi

# 6. 一键卸载（如需要）
./provider.sh uninstall
```

### 永久安装工作流（传统方式）
```bash
# 1. 永久安装（重启 shell 后仍然有效）
cc_config install

# 2. 重新启动 shell 或重新加载配置
source ~/.bashrc  # 或 source ~/.zshrc

# 3. 设置 token（自动持久化保存）
cc_config set glm
cc_config set kimi

# 4. 验证安装状态
cc_config status

# 5. 使用不同供应商
cc
ccglm
cckimi

# 6. 卸载（如需要）
cc_config uninstall
```

## 故障排除

### 常见问题
1. **命令未找到** - 确保已正确安装，运行在线安装命令：`curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | bash`
2. **Token 无效** - 检查 token 是否正确设置
3. **API 连接失败** - 检查网络连接和 API 端点
4. **权限错误** - 检查配置文件权限是否正确
5. **安装失败** - 检查 shell 配置文件路径和权限
6. **脚本执行权限** - 确保 `provider.sh` 有执行权限：`chmod +x provider.sh`
7. **网络连接问题** - 在线安装时确保能访问 GitHub，检查代理设置

### 调试
```bash
# 显示当前环境变量
env | grep ANTHROPIC

# 显示安装状态
cc_config status

# 查看配置文件内容
cat ~/.cc-provider-switcher/tokens.conf

# 查看安装记录
cat ~/.cc-provider-switcher/.installed

# 重新加载脚本
source provider.sh

# 检查 shell 配置文件
grep -n "provider.sh" ~/.bashrc
grep -n "provider.sh" ~/.zshrc

# 测试在线安装命令（预览）
curl -fsSL https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh | head -10

# 测试本地一键安装命令
./provider.sh help

# 检查脚本执行权限
ls -la provider.sh

# 测试网络连接
curl -I https://raw.githubusercontent.com/huaigu/cc-provider-switcher/refs/heads/main/provider.sh
```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进此工具。