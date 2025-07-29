# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Provider Switcher** - a Bash script that enables quick switching between different AI service providers for the Claude CLI tool. The main script (`provider.sh`) provides a unified interface to use Claude's official service, Zhipu GLM, and Kimi services.

## Core Architecture

### Main Components

1. **provider.sh** (372 lines) - Main script containing:
   - Provider configuration and URL management
   - Token handling and persistence system
   - Environment variable management
   - Command functions for each provider
   - Configuration management interface

2. **Supported Providers**:
   - **Claude Official**: Uses default Anthropic API
   - **GLM (Zhipu)**: Uses `https://open.bigmodel.cn/api/anthropic`
   - **Kimi**: Uses `https://api.moonshot.cn/v1`

### Key Functions

- **Provider Commands**: `cc`, `ccglm`, `cckimi` - Execute Claude with different providers
- **Configuration Management**: `cc_config` - Handle token storage and configuration
- **Token Management**: Secure token input, storage, and environment variable export
- **Environment Management**: Dynamic `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` setting

## Development Workflow

### Testing the Script

```bash
# Load the script (required for each new shell session)
source provider.sh

# Test configuration management
cc_config show
cc_config set glm    # Will prompt for token
cc_config set kimi   # Will prompt for token

# Test provider switching
cc          # Claude official
ccglm       # GLM provider
cckimi      # Kimi provider
```

### Adding New Providers

1. Add provider URL constant (line ~20)
2. Update `get_provider_url()` function (line ~24)
3. Update `get_token_var()` function (line ~33)
4. Add new command function (similar to `ccglm`, `cckimi`)
5. Update help text and configuration management

## Important Implementation Details

### Security Model
- Tokens are stored in environment variables, not written to files
- Uses `read -s` for secure password input
- Configuration directory has restricted permissions (700)
- Token files have restricted permissions (600)

### Configuration Storage
- Config directory: `~/.cc-provider-switcher/`
- Token storage: Environment variables only
- Backup mechanism: Creates `.backup` files before modifications

### Environment Variables
- `ANTHROPIC_BASE_URL` - Set dynamically based on provider
- `ANTHROPIC_AUTH_TOKEN` - Current active token
- `ANTHROPIC_AUTH_TOKEN_GLM` - GLM-specific token
- `ANTHROPIC_AUTH_TOKEN_KIMI` - Kimi-specific token

## Common Development Commands

```bash
# Source the script to load functions
source provider.sh

# View current configuration
cc_config show

# Test a specific provider
ccglm

# Clear all configuration
cc_config clear

# Get help
cc_help
```

## File Structure

```
/home/bojack/ccswitch/
├── provider.sh    # Main script (372 lines)
└── README.md      # User documentation
```

## Dependencies

- Bash 4.0+
- Claude CLI tool
- Valid API tokens for supported providers
- Linux/macOS environment

## Testing Considerations

- Script must be sourced (`source provider.sh`) not executed
- Tokens are session-persistent (environment variables)
- Each provider requires valid API credentials
- Claude CLI must be installed and accessible in PATH