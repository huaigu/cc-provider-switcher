#!/bin/bash

# AI 供应商配置脚本
# 支持 bash 和 zsh
# 使用方式: ./provider.sh [install|uninstall|help]

# 命令行参数处理
handle_command_line_args() {
    case "${1:-}" in
        "install")
            shift
            handle_install "$@"
            exit 0
            ;;
        "uninstall")
            handle_uninstall
            exit 0
            ;;
        "help"|"-h"|"--help")
            show_main_help
            exit 0
            ;;
        "")
            # 没有参数，正常加载脚本
            ;;
        *)
            echo "错误: 未知参数 '$1'"
            echo "使用 './provider.sh help' 查看帮助"
            exit 1
            ;;
    esac
}

# 处理安装命令
handle_install() {
    local shell_type="$1"
    
    if [ -z "$shell_type" ]; then
        local current_shell
        current_shell=$(detect_shell)
        if [ "$current_shell" = "unknown" ]; then
            echo "❌ 无法检测当前shell类型"
            echo "请手动指定shell类型:"
            echo "  $0 install bash"
            echo "  $0 install zsh"
            exit 1
        fi
        shell_type="$current_shell"
    fi
    
    echo "检测到shell类型: $shell_type"
    
    # 获取脚本绝对路径
    local script_path
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    
    # 检查脚本是否存在
    if [ ! -f "$script_path" ]; then
        echo "❌ 脚本文件不存在: $script_path"
        exit 1
    fi
    
    # 执行安装
    if install_to_shell "$shell_type"; then
        echo ""
        echo "✅ 安装完成！"
        echo "📝 请重新启动shell或运行 'source $(get_shell_config "$shell_type")' 来加载配置"
        echo "🔧 之后你可以直接使用: cc, ccglm, cckimi 命令"
    else
        echo "❌ 安装失败"
        exit 1
    fi
}

# 处理卸载命令
handle_uninstall() {
    if uninstall_from_shell; then
        echo ""
        echo "✅ 卸载完成！"
        echo "📝 请重新启动shell或运行 'source $(get_shell_config "$(cat "$INSTALL_MARKER" | cut -d'|' -f1)")' 来应用更改"
    else
        echo "❌ 卸载失败"
        exit 1
    fi
}

# 显示主帮助信息
show_main_help() {
    echo "Claude Provider Switcher - 安装脚本"
    echo ""
    echo "使用方式:"
    echo "  $0 install [shell]  - 安装到shell配置文件"
    echo "  $0 uninstall         - 从shell配置文件卸载"
    echo "  $0 help             - 显示此帮助信息"
    echo ""
    echo "支持的shell: bash zsh"
    echo ""
    echo "示例:"
    echo "  $0 install           - 自动检测并安装到当前shell"
    echo "  $0 install bash      - 安装到 ~/.bashrc"
    echo "  $0 install zsh       - 安装到 ~/.zshrc"
    echo "  $0 uninstall         - 从shell配置文件卸载"
    echo ""
    echo "安装后可以直接使用以下命令:"
    echo "  cc        - 使用 Claude 官方服务"
    echo "  ccglm     - 使用智谱GLM服务"
    echo "  cckimi    - 使用Kimi服务"
    echo "  cc_config - 配置管理"
    echo "  cc_help   - 显示帮助"
}

# 处理命令行参数（将在所有函数定义后调用）

# 配置文件路径
CONFIG_DIR="$HOME/.cc-provider-switcher"
CONFIG_FILE="$CONFIG_DIR/tokens.conf"
BACKUP_FILE="$CONFIG_DIR/tokens.conf.backup"
INSTALL_MARKER="$CONFIG_DIR/.installed"

# Shell 配置文件路径
BASH_RC="$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"
ZSH_RC="$HOME/.zshrc"
PROFILE="$HOME/.profile"

# 确保配置目录存在
ensure_config_dir() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        chmod 700 "$CONFIG_DIR"  # 设置权限为仅用户可访问
    fi
}

# 函数：检测当前shell类型
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        # 尝试从父进程检测
        local parent_shell
        parent_shell=$(ps -p $PPID -o comm= 2>/dev/null)
        case "$parent_shell" in
            *zsh*|*zsh) echo "zsh" ;;
            *bash*|*bash) echo "bash" ;;
            *) echo "unknown" ;;
        esac
    fi
}

# 函数：获取shell配置文件路径
get_shell_config() {
    local shell_type="$1"
    case "$shell_type" in
        "zsh")
            if [ -f "$ZSH_RC" ]; then
                echo "$ZSH_RC"
            elif [ -f "$HOME/.zshenv" ]; then
                echo "$HOME/.zshenv"
            else
                echo "$ZSH_RC"
            fi
            ;;
        "bash")
            # 按优先级检查配置文件
            if [ -f "$BASH_RC" ]; then
                echo "$BASH_RC"
            elif [ -f "$BASH_PROFILE" ]; then
                echo "$BASH_PROFILE"
            elif [ -f "$PROFILE" ]; then
                echo "$PROFILE"
            else
                echo "$BASH_RC"
            fi
            ;;
        *)
            echo "$BASH_RC"  # 默认使用bashrc
            ;;
    esac
}

# 函数：检查是否已安装
is_installed() {
    [ -f "$INSTALL_MARKER" ] && [ -s "$INSTALL_MARKER" ]
}

# 函数：备份配置文件
backup_config_file() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_file" "$backup_file"
        echo "$backup_file"
    fi
}

# 函数：安装到shell配置文件
install_to_shell() {
    local shell_type="$1"
    local config_file
    config_file=$(get_shell_config "$shell_type")
    
    echo "正在安装到 $config_file..."
    
    # 备份现有配置文件
    local backup_file
    backup_file=$(backup_config_file "$config_file")
    if [ -n "$backup_file" ]; then
        echo "✓ 已备份现有配置到 $backup_file"
    fi
    
    # 获取脚本绝对路径
    local script_path
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    
    # 检查是否已经安装
    if grep -q "source.*$(basename "${BASH_SOURCE[0]}")" "$config_file" 2>/dev/null; then
        echo "⚠️ 已经安装在此配置文件中"
        return 1
    fi
    
    # 添加安装标记
    cat >> "$config_file" << EOF

# Claude Provider Switcher - 安装于 $(date '+%Y-%m-%d %H:%M:%S')
# 支持: cc, ccglm, cckimi 命令
source "$script_path"
EOF
    
    # 创建安装标记
    ensure_config_dir
    echo "$shell_type|$config_file|$script_path" > "$INSTALL_MARKER"
    
    echo "✓ 已安装到 $config_file"
    echo "✓ 请重新启动shell或运行 'source $config_file' 来加载配置"
    return 0
}

# 函数：从shell配置文件卸载
uninstall_from_shell() {
    if ! is_installed; then
        echo "❌ 未找到安装记录"
        return 1
    fi
    
    # 读取安装记录
    local install_info
    install_info=$(cat "$INSTALL_MARKER")
    local shell_type config_file script_path
    IFS='|' read -r shell_type config_file script_path <<< "$install_info"
    
    echo "正在从 $config_file 卸载..."
    
    # 备份配置文件
    local backup_file
    backup_file=$(backup_config_file "$config_file")
    if [ -n "$backup_file" ]; then
        echo "✓ 已备份现有配置到 $backup_file"
    fi
    
    # 删除安装的内容
    if [ -f "$config_file" ]; then
        # 删除Claude Provider Switcher相关的行
        sed -i '/# Claude Provider Switcher - 安装于/,/source.*provider\.sh/d' "$config_file"
        
        # 删除空行（如果有的话）
        sed -i '/^$/N;/^\n$/D' "$config_file"
        
        echo "✓ 已从 $config_file 移除安装内容"
    fi
    
    # 删除安装标记
    rm -f "$INSTALL_MARKER"
    
    echo "✓ 卸载完成"
    echo "✓ 请重新启动shell或运行 'source $config_file' 来应用更改"
    return 0
}

# 函数：显示安装状态
show_install_status() {
    if is_installed; then
        local install_info
        install_info=$(cat "$INSTALL_MARKER")
        local shell_type config_file script_path
        IFS='|' read -r shell_type config_file script_path <<< "$install_info"
        
        echo "✅ Claude Provider Switcher 已安装"
        echo "   Shell类型: $shell_type"
        echo "   配置文件: $config_file"
        echo "   脚本路径: $script_path"
        echo "   安装时间: $(date -r "$INSTALL_MARKER" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$INSTALL_MARKER" 2>/dev/null || echo "未知")"
    else
        echo "❌ Claude Provider Switcher 未安装"
        echo "   使用 'cc_config install' 进行安装"
    fi
}

# 供应商配置
PROVIDER_GLM="https://open.bigmodel.cn/api/anthropic"
PROVIDER_KIMI="https://api.moonshot.cn/v1"

# 函数：获取供应商URL
get_provider_url() {
    case "$1" in
        "glm") echo "$PROVIDER_GLM" ;;
        "kimi") echo "$PROVIDER_KIMI" ;;
        *) echo "" ;;
    esac
}

# 函数：获取token变量名
get_token_var() {
    local provider="$1"
    case "$provider" in
        "glm") echo "ANTHROPIC_AUTH_TOKEN_GLM" ;;
        "kimi") echo "ANTHROPIC_AUTH_TOKEN_KIMI" ;;
        *) echo "" ;;
    esac
}

# 函数：保存token到配置文件
save_token() {
    local provider="$1"
    local token="$2"
    
    # 验证参数
    if [ -z "$provider" ] || [ -z "$token" ]; then
        echo "错误: provider 和 token 不能为空"
        return 1
    fi
    
    ensure_config_dir
    
    # 如果配置文件不存在，创建新文件
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"  # 设置权限为仅用户可读写
        echo "# Claude Provider Switcher Token Configuration" > "$CONFIG_FILE"
        echo "# 创建时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$CONFIG_FILE"
        echo "" >> "$CONFIG_FILE"
    fi
    
    # 备份现有配置文件
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
    fi
    
    # 删除旧的token配置（如果存在）
    sed -i.bak "/^${provider}_token=/d" "$CONFIG_FILE"
    
    # 添加新的token配置
    echo "${provider}_token=${token}" >> "$CONFIG_FILE"
    
    echo "✓ $provider token 已持久化保存到配置文件"
    return 0
}

# 函数：从配置文件加载token
load_tokens() {
    if [ -f "$CONFIG_FILE" ]; then
        local loaded_count=0
        while IFS='=' read -r key value; do
            # 跳过注释行和空行
            case "$key" in
                ""|"#"*)
                    continue
                    ;;
                "glm_token")
                    export ANTHROPIC_AUTH_TOKEN_GLM="$value"
                    loaded_count=$((loaded_count + 1))
                    ;;
                "kimi_token")
                    export ANTHROPIC_AUTH_TOKEN_KIMI="$value"
                    loaded_count=$((loaded_count + 1))
                    ;;
            esac
        done < "$CONFIG_FILE"
        
        if [ $loaded_count -gt 0 ]; then
            echo "✓ 已从持久化存储加载 $loaded_count 个供应商 token"
        fi
    fi
}

# 函数：删除配置文件中的token
delete_token() {
    local provider="$1"
    
    # 验证参数
    if [ -z "$provider" ]; then
        echo "错误: provider 不能为空"
        return 1
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "配置文件不存在"
        return 1
    fi
    
    if grep -q "^${provider}_token=" "$CONFIG_FILE"; then
        # 备份配置文件
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        # 删除token
        sed -i.bak "/^${provider}_token=/d" "$CONFIG_FILE"
        echo "✓ $provider token 已从持久化存储中删除"
        
        # 如果配置文件为空（除了注释），则删除文件
        local line_count
        line_count=$(grep -v "^#" "$CONFIG_FILE" | grep -v "^$" | wc -l | tr -d ' ')
        if [ "$line_count" -eq 0 ]; then
            rm "$CONFIG_FILE"
            echo "✓ 配置文件已删除（无有效配置）"
        fi
        
        return 0
    else
        echo "配置文件中未找到 $provider token"
        return 1
    fi
}

# 函数：删除整个配置文件
delete_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # 备份配置文件
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        # 删除配置文件
        rm "$CONFIG_FILE"
        echo "✓ 配置文件已删除，备份保存到 $BACKUP_FILE"
        return 0
    else
        echo "配置文件不存在"
        return 1
    fi
}

# 函数：获取或设置 token
get_or_set_token() {
    local provider="$1"
    local token_var
    token_var=$(get_token_var "$provider")
    
    if [ -z "$token_var" ]; then
        echo "错误: 不支持的供应商 '$provider'"
        return 1
    fi
    
    # 获取当前token值
    local current_token
    eval "current_token=\$$token_var"
    
    if [ -z "$current_token" ]; then
        echo "请输入 $provider 的 auth token:"
        read -s token
        if [ -n "$token" ]; then
            export "$token_var"="$token"
            echo "✓ $provider token 已设置（当前会话）"
            # 自动保存到持久化存储
            if save_token "$provider" "$token"; then
                echo "✓ token 已自动持久化保存"
            fi
        else
            echo "错误: token 不能为空"
            return 1
        fi
    else
        echo "✓ 使用已存在的 $provider token"
    fi
}

# 函数：清空 Anthropic 环境变量
clear_anthropic_env() {
    unset ANTHROPIC_BASE_URL
    unset ANTHROPIC_AUTH_TOKEN
}

# 函数：设置供应商环境变量
set_provider_env() {
    local provider="$1"
    local base_url
    base_url=$(get_provider_url "$provider")
    
    if [ -z "$base_url" ]; then
        echo "错误: 不支持的供应商 '$provider'"
        return 1
    fi
    
    # 获取或设置 token
    if ! get_or_set_token "$provider"; then
        return 1
    fi
    
    # 获取token值
    local token_var
    token_var=$(get_token_var "$provider")
    local token_value
    eval "token_value=\$$token_var"
    
    # 设置环境变量
    export ANTHROPIC_BASE_URL="$base_url"
    export ANTHROPIC_AUTH_TOKEN="$token_value"
}

# 函数：执行 claude 命令
run_claude() {
    claude --dangerously-skip-permissions
}

# 函数：显示当前配置
show_config() {
    echo "=== 当前 Anthropic 环境变量 ==="
    echo "ANTHROPIC_BASE_URL: ${ANTHROPIC_BASE_URL:-未设置}"
    if [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
        echo "ANTHROPIC_AUTH_TOKEN: 已设置"
    else
        echo "ANTHROPIC_AUTH_TOKEN: 未设置"
    fi
    echo ""
    echo "=== 已保存的供应商 tokens ==="
    
    if [ -n "$ANTHROPIC_AUTH_TOKEN_GLM" ]; then
        echo "glm: 已设置"
    else
        echo "glm: 未设置"
    fi
    
    if [ -n "$ANTHROPIC_AUTH_TOKEN_KIMI" ]; then
        echo "kimi: 已设置"
    else
        echo "kimi: 未设置"
    fi
}

# 函数：设置供应商 token
set_token() {
    local provider="$1"
    
    if [ "$provider" != "glm" ] && [ "$provider" != "kimi" ]; then
        echo "错误: 不支持的供应商 '$provider'"
        echo "支持的供应商: glm kimi"
        return 1
    fi
    
    echo "请输入 $provider 的 auth token:"
    read -s token
    if [ -n "$token" ]; then
        local token_var
        token_var=$(get_token_var "$provider")
        export "$token_var"="$token"
        # 保存到配置文件
        if save_token "$provider" "$token"; then
            echo "✓ $provider token 已设置并持久化保存"
        else
            echo "⚠️ $provider token 已设置但保存失败"
        fi
    else
        echo "错误: token 不能为空"
        return 1
    fi
}

# Claude 官方命令
function cc {
    echo "使用 Claude 官方服务..."
    clear_anthropic_env
    run_claude
}

# 智谱GLM命令
function ccglm {
    echo "使用智谱GLM服务..."
    clear_anthropic_env
    if set_provider_env "glm"; then
        run_claude
    fi
}

# Kimi命令
function cckimi {
    echo "使用Kimi服务..."
    clear_anthropic_env
    if set_provider_env "kimi"; then
        run_claude
    fi
}

# 配置管理命令
function cc_config {
    case "$1" in
        "show"|"")
            show_config
            ;;
        "set")
            if [ -n "$2" ]; then
                set_token "$2"
            else
                echo "用法: cc_config set <provider>"
                echo "支持的供应商: glm kimi"
            fi
            ;;
        "clear")
            if [ -n "$2" ]; then
                case "$2" in
                    "glm")
                        unset ANTHROPIC_AUTH_TOKEN_GLM
                        echo "glm token 已清除"
                        ;;
                    "kimi")
                        unset ANTHROPIC_AUTH_TOKEN_KIMI
                        echo "kimi token 已清除"
                        ;;
                    *)
                        echo "错误: 不支持的供应商 '$2'"
                        echo "支持的供应商: glm kimi"
                        ;;
                esac
            else
                echo "清除所有环境变量..."
                clear_anthropic_env
                unset ANTHROPIC_AUTH_TOKEN_GLM
                unset ANTHROPIC_AUTH_TOKEN_KIMI
                echo "所有配置已清除"
            fi
            ;;
        "delete")
            if [ -n "$2" ]; then
                case "$2" in
                    "glm")
                        if delete_token "glm"; then
                            unset ANTHROPIC_AUTH_TOKEN_GLM
                            echo "✓ GLM token 已完全删除"
                        fi
                        ;;
                    "kimi")
                        if delete_token "kimi"; then
                            unset ANTHROPIC_AUTH_TOKEN_KIMI
                            echo "✓ Kimi token 已完全删除"
                        fi
                        ;;
                    "all")
                        if delete_config; then
                            clear_anthropic_env
                            unset ANTHROPIC_AUTH_TOKEN_GLM
                            unset ANTHROPIC_AUTH_TOKEN_KIMI
                            echo "✓ 所有配置已完全删除"
                        fi
                        ;;
                    *)
                        echo "错误: 不支持的供应商 '$2'"
                        echo "支持的供应商: glm kimi"
                        echo "使用 'all' 删除所有配置"
                        ;;
                esac
            else
                echo "用法: cc_config delete <provider>"
                echo "支持的供应商: glm kimi"
                echo "使用 'all' 删除所有配置"
            fi
            ;;
        "help")
            echo "cc_config 命令用法:"
            echo "  cc_config show         - 显示当前配置"
            echo "  cc_config set <provider> - 设置供应商token"
            echo "  cc_config clear [provider] - 清除环境变量"
            echo "  cc_config delete <provider> - 删除持久化存储"
            echo "  cc_config install [shell]  - 安装到shell配置文件"
            echo "  cc_config uninstall       - 从shell配置文件卸载"
            echo "  cc_config status          - 显示安装状态"
            echo "  cc_config help         - 显示帮助"
            echo ""
            echo "支持的供应商: glm kimi"
            echo "支持的shell: bash zsh"
            echo "使用 'all' 删除所有配置"
            echo ""
            echo "持久化存储位置: $CONFIG_FILE"
            echo "备份文件位置: $BACKUP_FILE"
            echo "安装标记文件: $INSTALL_MARKER"
            ;;
        "install")
            local current_shell
            current_shell=$(detect_shell)
            if [ "$current_shell" = "unknown" ]; then
                echo "❌ 无法检测当前shell类型"
                echo "请手动指定shell类型:"
                echo "  cc_config install bash"
                echo "  cc_config install zsh"
                return 1
            fi
            
            if [ -n "$2" ]; then
                current_shell="$2"
            fi
            
            echo "检测到shell类型: $current_shell"
            install_to_shell "$current_shell"
            ;;
        "uninstall")
            uninstall_from_shell
            ;;
        "status")
            show_install_status
            ;;
        *)
            echo "错误: 未知参数 '$1'"
            echo "使用 'cc_config help' 查看帮助"
            ;;
    esac
}

# 帮助命令
function cc_help {
    echo "AI 供应商切换工具"
    echo ""
    echo "基本命令:"
    echo "  cc         - 使用 Claude 官方服务"
    echo "  ccglm      - 使用智谱GLM服务"
    echo "  cckimi     - 使用Kimi服务"
    echo ""
    echo "管理命令:"
    echo "  cc_config  - 配置管理 (详细用法请运行 cc_config help)"
    echo "  cc_help    - 显示此帮助信息"
    echo ""
    echo "支持的供应商: glm kimi"
    echo "支持的shell: bash zsh"
    echo ""
    echo "安装和卸载:"
    echo "  cc_config install   - 安装到shell配置文件（持久生效）"
    echo "  cc_config uninstall - 从shell配置文件卸载"
    echo "  cc_config status    - 显示安装状态"
    echo ""
    echo "持久化存储:"
    echo "  Tokens 自动保存到 ~/.cc-provider-switcher/tokens.conf"
    echo "  使用 cc_config delete 删除持久化存储"
}

# 加载已保存的tokens
load_tokens

# 检查是否为直接执行脚本（而不是source）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 直接执行脚本，处理命令行参数
    handle_command_line_args "$@"
else
    # 被source加载，显示加载成功信息
    echo "Claude 供应商切换工具已加载"
    echo "使用 'cc_help' 查看帮助信息"
fi
