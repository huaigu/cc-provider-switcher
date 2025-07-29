#!/bin/bash

# AI 供应商配置脚本
# 支持 bash 和 zsh

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
            echo "$provider token 已设置"
        else
            echo "错误: token 不能为空"
            return 1
        fi
    else
        echo "使用已存在的 $provider token"
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
    claude --dangerously-skip-permissions -c
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
        echo "$provider token 已设置"
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
        "help")
            echo "cc_config 命令用法:"
            echo "  cc_config show         - 显示当前配置"
            echo "  cc_config set <provider> - 设置供应商token"
            echo "  cc_config clear [provider] - 清除配置"
            echo "  cc_config help         - 显示帮助"
            echo ""
            echo "支持的供应商: glm kimi"
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
}

# 显示加载成功信息
echo "Claude 供应商切换工具已加载"
echo "使用 'cc_help' 查看帮助信息"
