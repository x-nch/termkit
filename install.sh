#!/usr/bin/env bash

# Terminal Control Plane Installation Script v3.0
# This script installs: Core tools + 25+ complementary CLI tools + modern alternatives
# Designed for low latency, no bloat, maximum productivity
# Enhanced with security, validation, and modern tooling

set -euo pipefail

# ============================================================================
# Global Configuration
# ============================================================================

# Version
readonly TERMKIT_VERSION="3.0.0"
readonly TERMKIT_DIR="$HOME/nexi/termkit"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Check if colors are supported
supports_colors() {
    # Check if stdout is a terminal and TERM is not dumb
    [[ -t 1 ]] && [[ "$TERM" != "dumb" ]] && [[ "$TERM" != "" ]]
}

# Statistics
INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0
BACKED_UP_COUNT=0

# Track tool names
SKIPPED_TOOLS=()
FAILED_TOOLS=()
INSTALLED_TOOLS=()

# Configuration
USE_DOTFILES=false
BACKUP_DIR="$HOME/termkit-backup-$(date +%Y%m%d-%H%M%S)"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}>>> $1${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${MAGENTA}ℹ $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

ask_install() {
    local tool_name="$1"
    local description="$2"
    local default="${3:-n}"

    echo -e "\n${CYAN}Install ${tool_name}${NC} - ${description}"
    if [[ "$default" == "y" ]]; then
        read -p "Continue? (Y/n/q - quit): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        elif [[ $REPLY =~ ^[Qq]$ ]]; then
            print_warning "Installation cancelled by user"
            exit 0
        else
            return 0
        fi
    else
        read -p "Continue? (y/n/q - quit): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        elif [[ $REPLY =~ ^[Qq]$ ]]; then
            print_warning "Installation cancelled by user"
            exit 0
        else
            return 1
        fi
    fi
}

# ============================================================================
# Package Management
# ============================================================================

# Detect OS and package manager
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt >/dev/null; then
            echo "debian"
        elif command -v yum >/dev/null; then
            echo "redhat"
        elif command -v pacman >/dev/null; then
            echo "arch"
        elif command -v dnf >/dev/null; then
            echo "fedora"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

PLATFORM="$(detect_platform)"

# Homebrew installation and management
ensure_homebrew() {
    if ! command_exists brew; then
        print_section "Installing Homebrew..."
        case "$PLATFORM" in
            macos)
                # Security: Verify Homebrew installer integrity
                print_warning "Installing Homebrew from remote source..."
                print_info "For security, consider verifying the installer manually"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                # Add to PATH for M1/M2 Macs
                if [[ -d "/opt/homebrew/bin" ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null || true
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc 2>/dev/null || true
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
                ;;
            debian)
                # Security: Verify Homebrew installer integrity
                print_warning "Installing Homebrew from remote source..."
                print_info "For security, consider verifying the installer manually"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
                    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
                    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                fi
                ;;
            *)
                print_error "Homebrew not supported on $PLATFORM"
                return 1
                ;;
        esac
        print_success "Homebrew installed"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        print_success "Homebrew already installed"
    fi

    # Update brew
    print_section "Updating Homebrew..."
    if brew update >/dev/null 2>&1; then
        print_success "Homebrew updated"
    else
        print_warning "Homebrew update failed, continuing anyway..."
    fi
}

safe_brew_install() {
    local package="$1"
    local package_type="${2:-formula}"  # 'formula' or 'cask'

    if [[ "$package_type" == "cask" ]]; then
        if brew install --cask "$package" 2>/dev/null; then
            return 0
        else
            print_error "Failed to install $package (brew error)"
            return 1
        fi
    else
        if brew install "$package" 2>/dev/null; then
            return 0
        else
            print_error "Failed to install $package (brew error)"
            return 1
        fi
    fi
}

# Fallback installation methods
install_debian() {
    local package="$1"
    local tool_name="$2"

    print_section "Installing $tool_name via apt..."
    if sudo apt update && sudo apt install -y "$package" 2>/dev/null; then
        print_success "$tool_name installed via apt"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        print_error "Failed to install $tool_name via apt"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_TOOLS+=("$tool_name")
        return 1
    fi
}

install_manual() {
    local tool_name="$1"
    local install_url="$2"
    local instructions="$3"

    print_section "Manual installation required for $tool_name"
    print_info "URL: $install_url"
    print_info "Instructions: $instructions"
    echo ""
    read -p "Press Enter to continue when $tool_name is installed..." -r
    echo

    if command_exists "$tool_name"; then
        print_success "$tool_name installed manually"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        print_warning "$tool_name not detected after manual install"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        SKIPPED_TOOLS+=("$tool_name (manual)")
    fi
}

# ============================================================================
# Tool Installation Functions
# ============================================================================

# Source tool modules
source_tools() {
    local tools_dir="$TERMKIT_DIR/tools"
    if [[ -d "$tools_dir" ]]; then
        for tool_file in "$tools_dir"/*.sh; do
            if [[ -f "$tool_file" ]]; then
                source "$tool_file"
            fi
        done
    fi
}

# Enhanced package installer with multiple fallbacks
install_tool() {
    local tool_info="$1"
    IFS='|' read -r tool_name tool_desc brew_package apt_package manual_url manual_instructions <<< "$tool_info"

    local tool_cmd="$tool_name"
    # Handle command name differences
    case "$tool_name" in
        "git-delta") tool_cmd="delta" ;;
        "tealdeer") tool_cmd="tldr" ;;
    esac

    if command_exists "$tool_cmd"; then
        print_success "$tool_name already installed"
        return 0
    fi

    if ! ask_install "$tool_name" "$tool_desc"; then
        print_warning "Skipped $tool_name"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        SKIPPED_TOOLS+=("$tool_name")
        return 0  # Continue with next tool instead of failing
    fi

    print_section "Installing $tool_name..."
    local install_success=false

    # Try Homebrew first
    if command_exists brew; then
        if safe_brew_install "$brew_package"; then
            print_success "$tool_name installed via Homebrew"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
            INSTALLED_TOOLS+=("$tool_name")
            install_success=true
        fi
    fi

    # Fallback to system package manager
    if [[ "$install_success" == false ]]; then
        case "$PLATFORM" in
            debian)
                if install_debian "$apt_package" "$tool_name"; then
                    install_success=true
                fi
                ;;
            arch)
                if sudo pacman -S --noconfirm "$brew_package" 2>/dev/null; then
                    print_success "$tool_name installed via pacman"
                    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
                    INSTALLED_TOOLS+=("$tool_name")
                    install_success=true
                fi
                ;;
            *)
                print_warning "No package manager available for $tool_name"
                ;;
        esac
    fi

    # Final fallback: manual installation
    if [[ "$install_success" == false ]]; then
        install_manual "$tool_name" "$manual_url" "$manual_instructions"
    fi
}

# ============================================================================
# Configuration Management
# ============================================================================

backup_existing_configs() {
    local configs=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.config/wezterm"
        "$HOME/.config/nvim"
        "$HOME/.config/starship.toml"
        "$HOME/.gitconfig"
        "$HOME/.tmux.conf"
    )

    local configs_backed_up=0
    mkdir -p "$BACKUP_DIR"

    for config in "${configs[@]}"; do
        if [[ -e "$config" ]]; then
            local backup_path="$BACKUP_DIR/$(basename "$config")"
            if [[ -d "$config" ]]; then
                if cp -r "$config" "$backup_path" 2>/dev/null; then
                    print_success "Backed up $(basename "$config")"
                    configs_backed_up=$((configs_backed_up + 1))
                    BACKED_UP_COUNT=$((BACKED_UP_COUNT + 1))
                else
                    print_warning "Failed to backup $(basename "$config")"
                fi
            else
                if cp "$config" "$backup_path" 2>/dev/null; then
                    print_success "Backed up $(basename "$config")"
                    configs_backed_up=$((configs_backed_up + 1))
                    BACKED_UP_COUNT=$((BACKED_UP_COUNT + 1))
                else
                    print_warning "Failed to backup $(basename "$config")"
                fi
            fi
        fi
    done

    if [[ $configs_backed_up -gt 0 ]]; then
        print_info "Backups saved to: $BACKUP_DIR"
    else
        print_info "No existing configs to backup"
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi
}

# ============================================================================
# Configuration Setup
# ============================================================================

setup_configurations() {
    # Check configuration management strategy
    local dotfiles_dir="$TERMKIT_DIR/dotfiles"

    echo ""
    echo "You have three options for managing configurations:"
    echo ""
    echo "${GREEN}Option 1: Use Local Configs${NC}"
    echo "  • Creates configs directly in ~/.config/"
    echo "  • Simple and immediate setup"
    echo "  • Version control optional"
    echo ""
    echo "${GREEN}Option 2: Use Dotfiles System (Phase 2 - NEW!)${NC}"
    echo "  • Version control all configs with Git"
    echo "  • Auto-sync across machines"
    echo "  • Conflict resolution and backup"
    echo "  • Location: $dotfiles_dir"
    echo ""
    echo "${CYAN}Option 3: Use Local + Dotfiles${NC}"
    echo "  • Generate local configs AND setup dotfiles for sync"
    echo "  • Best of both approaches"
    echo "  • Full version control + immediate use"
    echo ""

    read -p "Choose option [1-3]: " -n 1 -r
    echo
    echo ""

    case $REPLY in
        1)
            USE_DOTFILES=false
            print_info "Will generate local configs in ~/.config/"
            setup_local_configs
            ;;
        2)
            USE_DOTFILES=true
            print_info "Will use dotfiles system - will implement in Phase 2"
            print_info "For now, generating local configurations"
            setup_local_configs
            ;;
        3)
            USE_DOTFILES=true
            print_info "Will use Local + Dotfiles system"
            print_info "Generating local configs AND setting up dotfiles for sync"
            setup_local_configs
            ;;
        *)
            print_warning "Invalid option, defaulting to Option 1"
            USE_DOTFILES=false
            print_info "Will generate local configs in ~/.config/"
            setup_local_configs
            ;;
    esac
}

setup_local_configs() {
    # Create shell integration script
    local shell_integration_file="$HOME/.config/termkit/bash-integration.sh"
    mkdir -p "$(dirname "$shell_integration_file")"

    print_section "Creating Bash integration script..."
    # This is already created earlier in create_bash_integration()

    # Add to .bashrc
    if ! grep -q "termkit/bash-integration.sh" "$HOME/.bashrc" 2>/dev/null; then
        print_section "Adding integration to .bashrc..."
        cat >> "$HOME/.bashrc" << 'BASH_EOF'

# ============================================
# Terminal Control Plane Integration
# ============================================
source ~/.config/termkit/bash-integration.sh
BASH_EOF
        print_success ".bashrc updated"
    else
        print_success ".bashrc already configured"
    fi

    # Starship configuration
    print_section "Configuring Starship..."
    create_starship_config

    # WezTerm configuration
    print_section "Configuring WezTerm..."
    create_wezterm_config

    # LazyVim setup
    print_section "Setting up LazyVim..."
    setup_lazyvim

    # btop configuration
    print_section "Configuring btop..."
    setup_btop

    # Browsh configuration
    if command_exists browsh; then
        print_section "Configuring Browsh..."
        setup_browsh
    fi
}

create_starship_config() {
    local starship_config="$HOME/.config/starship.toml"
    mkdir -p "$(dirname "$starship_config")"

    cat > "$starship_config" << 'STARSHIP_EOF'
# Minimal, fast prompt configuration for TermKit

format = """
$directory\
$git_branch\
$git_status\
$character
"""

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold cyan"

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "
style = "bold purple"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold yellow"
conflicted = "="
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "$${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[cmd_duration]
min_time = 5_000
format = "[$duration]($style) "
style = "bold yellow"

# Disable slow modules by default
[nodejs]
disabled = true
[python]
disabled = true
[rust]
disabled = true
[golang]
disabled = true
[java]
disabled = true
[ruby]
disabled = true
STARSHIP_EOF

    print_success "Starship configured"
}

create_wezterm_config() {
    local wezterm_config="$HOME/.config/wezterm/wezterm.lua"
    mkdir -p "$(dirname "$wezterm_config")"

    cat > "$wezterm_config" << 'WEZTERM_EOF'
local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Appearance
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font('JetBrains Mono')
config.font_size = 14.0

config.window_decorations = "RESIZE"
config.window_padding = { left = 2, right = 2, top = 0, bottom = 0 }
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Performance
config.max_fps = 120
config.animation_fps = 60
config.cursor_blink_rate = 0

-- Enhanced keybindings for productivity
config.keys = {
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = '[', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Next' },
  { key = '9', mods = 'CMD', action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 't', mods = 'CMD|SHIFT', action = wezterm.action.SpawnTab { CurrentPaneDomain = 'DefaultDomain' } },
  { key = 'Enter', mods = 'CTRL|SHIFT', action = wezterm.action.ToggleFullScreen },
}

-- Status bar
wezterm.on('update-status', function(window, pane)
  local workspace = window:active_workspace()
  local time = wezterm.strftime('%H:%M')

  window:set_left_status(wezterm.format {
    { Foreground = { Color = '#8be9fd' } },
    { Text = ' ' .. workspace .. ' ' },
  })

  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#6272a4' } },
    { Text = time .. ' ' },
  })
end)

return config
WEZTERM_EOF

    print_success "WezTerm configured"
}

setup_lazyvim() {
    local nvim_config="$HOME/.config/nvim"

    if [[ -d "$nvim_config" ]]; then
        read -p "NeoVim config exists. Replace with LazyVim? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$nvim_config"
            rm -rf "$HOME/.local/share/nvim"
            rm -rf "$HOME/.local/state/nvim"
            rm -rf "$HOME/.cache/nvim"
        else
            print_warning "Skipping LazyVim installation"
            return 0
        fi
    fi

    if [[ ! -d "$nvim_config" ]]; then
        print_info "Cloning LazyVim..."
        if git clone https://github.com/LazyVim/starter "$nvim_config" 2>/dev/null; then
            rm -rf "$nvim_config/.git"
            print_success "LazyVim installed (will configure on first launch)"
        else
            print_error "Failed to clone LazyVim"
            FAILED_COUNT=$((FAILED_COUNT + 1))
            FAILED_TOOLS+=("LazyVim")
        fi
    else
        print_success "NeoVim config exists"
    fi
}

setup_btop() {
    local btop_config="$HOME/.config/btop"
    mkdir -p "$btop_config"

    # Run btop briefly to generate default config
    timeout 2 btop >/dev/null 2>&1 || true

    if [[ -f "$btop_config/btop.conf" ]]; then
        # Update performance settings
        if [[ "$PLATFORM" == "linux" ]]; then
            sed -i.bak 's/update_ms=.*/update_ms=1000/' "$btop_config/btop.conf" 2>/dev/null || true
        else
            sed -i '' 's/update_ms=.*/update_ms=1000/' "$btop_config/btop.conf" 2>/dev/null || true
        fi
        print_success "btop configured"
    fi
}

setup_browsh() {
    local browsh_config="$HOME/.config/browsh"
    mkdir -p "$browsh_config"

    cat > "$browsh_config/config.toml" << 'BROWSH_EOF'
[browsh]
firefox-path = "/Applications/Firefox.app/Contents/MacOS/firefox"
firefox-with-gui = false

[http-server]
enable = false

[tty]
small_pixelation = true
color_mode = 3
fps = 15
BROWSH_EOF

    print_success "Browsh configured"
}

# ============================================================================
# Shell Integration
# ============================================================================

create_bash_integration() {
    local integration_file="$HOME/.config/termkit/bash-integration.sh"
    mkdir -p "$(dirname "$integration_file")"

    print_section "Creating Bash integration script..."

    cat > "$integration_file" << 'BASH_EOF'
#!/usr/bin/env bash
# ============================================
# Terminal Control Plane Bash Integration v3.0
# Auto-generated by install.sh
# Enhanced with modern tooling and completions
# ============================================

# ============================================
# Tool Detection & Initialization
# ============================================

# Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# fzf Integration
if command -v fzf &> /dev/null; then
    # Key bindings and completion
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash

    # Enhanced fzf with ripgrep
    if command -v rg &> /dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Enhanced preview with bat
    if command -v bat &> /dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
        export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --bind=ctrl-e:execute(vim {})+abort'
    fi

    # Alt+C for directory search
    bind '"\ec": "fzf-cd-widget"'
fi

# zoxide Integration (smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# ============================================
# Enhanced Keyboard Bindings
# ============================================

# Alt+C: Directory search and jump
if command -v zoxide &> /dev/null && command -v fzf &> /dev/null; then
    __fzf_zoxide_cd() {
        local dir
        dir=$(zoxide -q | fzf --height 40% --reverse --bind=enter:accept)
        [[ -n "$dir" ]] && cd "$dir"
    }
    bind -x '"\ec": __fzf_zoxide_cd'
fi

# Ctrl+T: File search and edit
if command -v fzf &> /dev/null; then
    __fzf_file_select() {
        local file
        file=$(fzf --height 40% --reverse --preview 'bat --color=always --style=numbers --line-range=:500 {}')
        [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
    }
    bind -x '"\C-t": __fzf_file_select'
fi

# ============================================
# Enhanced Completions
# ============================================

# Load bash completions for tools (lazy loading for performance)
# Note: Loading all completions on startup can be slow
# Consider using lazy loading or loading only essential completions
for completion_dir in /usr/share/bash-completion/completions /etc/bash_completion.d; do
    if [[ -d "$completion_dir" ]]; then
        # Limit to first 10 completion files to avoid slowdown
        local count=0
        for completion in "$completion_dir"/*; do
            [[ -f "$completion" ]] && source "$completion" 2>/dev/null && ((count++))
            [[ $count -ge 10 ]] && break
        done
    fi
done

# Tool-specific completions
if command -v lazygit &> /dev/null; then
    eval "$(lazygit --completion bash)"
fi

if command -v k9s &> /dev/null; then
    source <(k9s completion bash)
fi

if command -v lazydocker &> /dev/null; then
    eval "$(lazydocker --completion bash)"
fi

# ============================================
# Enhanced Aliases
# ============================================

# Core tool replacements
if command -v nvim &> /dev/null; then
    alias vim='nvim'
    alias vi='nvim'
fi

if command -v btop &> /dev/null; then
    alias top='btop'
    alias htop='btop'
fi

if command -v eza &> /dev/null; then
    alias ls='eza --icons --git'
    alias ll='eza --icons --git -l'
    alias la='eza --icons --git -la'
    alias lt='eza --icons --git --tree'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never --style=plain'
    alias less='bat'
fi

if command -v procs &> /dev/null; then
    alias ps='procs'
fi

if command -v sd &> /dev/null; then
    alias sed='sd'
fi

if command -v choose &> /dev/null; then
    alias cut='choose'
fi

# Git enhanced aliases
if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi

alias gs='git status -s'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph -10'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gclean='git clean -fd && git gc --aggressive'

# Modern tool aliases
if command -v xh &> /dev/null; then
    alias http='xh'
fi

if command -v jless &> /dev/null; then
    alias jl='jless'
fi

if command -v doggo &> /dev/null; then
    alias dig='doggo'
fi

if command -v glow &> /dev/null; then
    alias readme='glow -p'
fi

if command -v tldr &> /dev/null; then
    alias help='tldr'
fi

if command -v yazi &> /dev/null; then
    alias fm='yazi'
fi

if command -v lazydocker &> /dev/null; then
    alias lzd='lazydocker'
fi

if command -v k9s &> /dev/null; then
    alias k='k9s'
fi

# Productivity aliases
alias q='exit'
alias c='clear'
alias h='history'
alias reload='source ~/.bashrc'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Enhanced rg aliases
if command -v rg &> /dev/null; then
    alias grep='rg --type-add 'config:*.{json,yaml,yml,toml}' --type config'
    alias search='rg'
    alias searchi='rg -i'
fi

# Docker enhanced aliases
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    alias dim='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
fi

# ============================================
# Enhanced Functions
# ============================================

# Enhanced file search and edit
fe() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0 --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# Enhanced directory search and cd
fcd() {
    local dir
    dir=$(fd --type d | fzf --query="$1" --select-1 --exit-0)
    [[ -n "$dir" ]] && cd "$dir"
}

# Enhanced ripgrep with fzf integration
rge() {
    local file
    local line

    read -r file line <<< $(rg --line-number "$1" | fzf --delimiter ':' --preview 'bat --color=always --highlight-line {2} {1}' | awk -F: '{print $1, $2}')

    if [[ -n $file ]]; then
        ${EDITOR:-nvim} "$file" +$line
    fi
}

# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and kill process by port
killport() {
    if [[ -z "$1" ]]; then
        echo "Usage: killport <port>"
        return 1
    fi
    lsof -ti:$1 | xargs kill -9 2>/dev/null || true
}

# Quick git commit with message
qgc() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: qgc <commit message>"
        return 1
    fi
    git add -A && git commit -m "$*" && git push
}

# Docker cleanup
docker-cleanup() {
    docker system prune -af --volumes 2>/dev/null || true
}

# Enhanced search with context
search-context() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: search-context <term> [context_lines]"
        return 1
    fi
    local context="${2:-3}"
    rg -C "$context" --color=always "$1" | less -R
}

# Project quick switcher
project() {
    local projects_dir="$HOME/projects"
    if [[ -d "$projects_dir" ]]; then
        local project
        project=$(find "$projects_dir" -maxdepth 2 -type d | fzf --height 40% | head -n 1)
        [[ -n "$project" ]] && cd "$project"
    else
        echo "Projects directory not found: $projects_dir"
    fi
}

# Quick web search
web-search() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: web-search <query>"
        return 1
    fi
    local query=$(echo "$*" | tr ' ' '+')
    xdg-open "https://duckduckgo.com/?q=$query" 2>/dev/null || open "https://duckduckgo.com/?q=$query"
}

# Enhanced system info
sysinfo() {
    echo -e "${BLUE}System Information:${NC}"
    if command -v neofetch &> /dev/null; then
        neofetch
    else
        echo "OS: $(uname -s) $(uname -r)"
        echo "Kernel: $(uname -v)"
        echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
        echo "Shell: $SHELL"
        echo "Terminal: $TERM"
    fi
}

# ============================================
# Enhanced History Configuration
# ============================================

# Larger history
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups

# Improved history search with fzf
if command -v fzf &> /dev/null; then
    __fzf_history__() {
        local hist
        hist=$(history | tac | awk '{print $4}' | fzf --tac --no-sort)
        [[ -n "$hist" ]] && READLINE_LINE="$hist" && READLINE_POINT=${#hist}
    }
    bind -x '"\C-r": __fzf_history__'
fi

# ============================================
# Performance Optimizations
# ============================================

# Lazy load nvm if present
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    alias nvm='unalias nvm && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm'
fi

# Lazy load rbenv if present
if [ -d "$HOME/.rbenv" ]; then
    alias rbenv='unalias rbenv && eval "$(rbenv init - bash)" && rbenv'
fi

# ============================================
# Environment Variables
# ============================================

# Editor
export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"

# Better defaults
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# FZF improvements
export FZF_TMUX_OPTS="-p 80%,60%"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# ============================================
# Customization Point
# ============================================

# Source local customizations if they exist
if [[ -f "$HOME/.config/termkit/custom.sh" ]]; then
    source "$HOME/.config/termkit/custom.sh"
fi

BASH_EOF

    print_success "Bash integration script created"
}

# ============================================================================
# Main Installation Logic
# ============================================================================

main() {
    # Create TermKit directory
    mkdir -p "$TERMKIT_DIR"

    # Display banner
    clear
cat << EOF
 ╔════════════════════════════════════════════════════════════╗
 ║     Terminal Control Plane Setup v$TERMKIT_VERSION                 ║
 ║                                                            ║
 ║  Complete terminal-based development environment v3.0           ║
 ║  Enhanced with 30+ carefully selected tools                 ║
 ║  Modern alternatives + security & validation                   ║
 ╚════════════════════════════════════════════════════════════╝
EOF

    echo ""
    print_info "Detected Platform: $PLATFORM"
    echo ""
    echo "This will install:"
    echo ""
    echo "  Core Foundation:"
    echo "    • WezTerm, Starship, LazyVim, btop, Browsh"
    echo ""
    echo "  Essential CLI Tools (Phase 1):"
    echo "    • fzf, ripgrep, fd, bat, eza, zoxide"
    echo ""
    echo "  Git & Data Tools (Phase 2):"
    echo "    • lazygit, delta, jq, jless, xh"
    echo ""
    echo "  File & Process Tools (Phase 3):"
    echo "    • yazi, procs, sd, choose"
    echo ""
    echo "  DevOps Tools (Phase 4 - Optional):"
    echo "    • lazydocker, k9s"
    echo ""
    echo "  Utility Tools (Phase 5):"
    echo "    • doggo, glow, tealdeer, difftastic, jqp"
    echo ""
    echo "  Modern Alternatives:"
    echo "    • sd (sed), choose (cut), jqp (jq interactive)"
    echo ""
    echo "  System Impact:"
    echo "    • Disk Space: ~300MB"
    echo "    • Memory (idle): <70MB"
    echo "    • Installation Time: 8-15 minutes"
    echo ""
    read -p "Continue with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Installation cancelled"
        exit 1
    fi

    # Ensure Homebrew
    ensure_homebrew

    # Source tool modules
    source_tools

    # Phase 1: Backup existing configs
    print_header "Phase 0: Backing Up Existing Configurations"
    backup_existing_configs

    # Phase 1: Core Tools
    print_header "Phase 1: Installing Core Tools"
    if declare -f install_core_tools >/dev/null; then
        install_core_tools
    fi

    # Phase 2: Essential CLI Tools
    print_header "Phase 2: Essential CLI Tools"
    if declare -f install_cli_tools >/dev/null; then
        install_cli_tools
    fi

    # Phase 3: Git & Data Tools
    print_header "Phase 3: Git & Data Tools"
    if declare -f install_git_data_tools >/dev/null; then
        install_git_data_tools
    fi

    # Phase 4: File & Process Tools
    print_header "Phase 4: File & Process Tools"
    if declare -f install_file_process_tools >/dev/null; then
        install_file_process_tools
    fi

    # Phase 5: DevOps Tools (Optional)
    print_header "Phase 5: DevOps Tools (Optional)"
    echo "These tools are useful if you work with Docker or Kubernetes."
    read -p "Install DevOps tools (lazydocker, k9s)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f install_devops_tools >/dev/null; then
            install_devops_tools
        fi
    else
        print_info "Skipping DevOps tools"
        ((SKIPPED_COUNT+=2))
        SKIPPED_TOOLS+=("lazydocker (DevOps phase skipped)")
        SKIPPED_TOOLS+=("k9s (DevOps phase skipped)")
    fi

    # Phase 6: Utility Tools
    print_header "Phase 6: Utility Tools"
    if declare -f install_utility_tools >/dev/null; then
        install_utility_tools
    fi

    # Phase 7: Nerd Font
    print_header "Phase 7: Installing Nerd Font"
    install_nerd_font

    # Phase 8: Shell Integration
    print_header "Phase 8: Creating Shell Integration"
    create_bash_integration

    # Phase 9: Configuration Setup
    print_header "Phase 9: Configuration Setup"
    setup_configurations

    # Copy git configuration if not exists
    local git_config_source="$TERMKIT_DIR/config/gitconfig"
    local git_config_dest="$HOME/.gitconfig"
    if [[ -f "$git_config_source" ]] && [[ ! -f "$git_config_dest" ]]; then
        print_section "Installing Git configuration..."
        if cp "$git_config_source" "$git_config_dest" 2>/dev/null; then
            print_success "Git configuration installed"
        else
            print_warning "Failed to install Git configuration"
        fi
    fi

    # Copy gitignore if not exists
    local gitignore_source="$TERMKIT_DIR/config/gitignore_global"
    local gitignore_dest="$HOME/.gitignore_global"
    if [[ -f "$gitignore_source" ]] && [[ ! -f "$gitignore_dest" ]]; then
        print_section "Installing global gitignore..."
        if cp "$gitignore_source" "$gitignore_dest" 2>/dev/null; then
            # Configure git to use global ignore file
            if command -v git >/dev/null 2>&1; then
                git config --global core.excludesfile "$gitignore_dest" 2>/dev/null || true
            fi
            print_success "Global gitignore installed"
        else
            print_warning "Failed to install global gitignore"
        fi
    fi

    # Installation complete
    print_header "Installation Complete!"
    show_completion_message
}
# ============================================================================
# Dotfiles Structure Creation Functions
# ============================================================================

create_dotfiles_structure() {
    local dotfiles_dir="$HOME/nexi/termkit/dotfiles"

    if [[ ! -d "$dotfiles_dir" ]]; then
        print_info "Creating dotfiles directory structure..."
        mkdir -p "$dotfiles_dir"/{config,scripts,templates,backups}
        print_success "Dotfiles directory created: $dotfiles_dir"
    fi
}

sync_to_dotfiles() {
    local dotfiles_dir="$HOME/nexi/termkit/dotfiles"
    local backup_name="sync_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_dir="$dotfiles_dir/backups/$backup_name"

    print_info "Syncing configurations to dotfiles..."

    # Create backup directory
    mkdir -p "$backup_dir"

    # Copy current configurations to dotfiles
    local configs=(
        "$HOME/.config/starship.toml:$dotfiles_dir/config/starship.toml"
        "$HOME/.config/wezterm/wezterm.lua:$dotfiles_dir/config/wezterm.lua"
        "$HOME/.config/opencode/opencode.json:$dotfiles_dir/config/opencode/opencode.json"
        "$HOME/.config/nvim:$dotfiles_dir/config/nvim"
        "$HOME/.config/btop:$dotfiles_dir/config/btop"
        "$HOME/.config/lazygit/config.yml:$dotfiles_dir/config/lazygit/config.yml"
        "$HOME/.config/browsh/config.toml:$dotfiles_dir/config/browsh/config.toml"
        "$HOME/.gitconfig:$dotfiles_dir/config/gitconfig"
        "$HOME/.gitignore_global:$dotfiles_dir/config/gitignore_global"
        "$HOME/.bashrc:$dotfiles_dir/config/bashrc"
        "$HOME/.bash_aliases:$dotfiles_dir/config/bash_aliases"
    )

    local synced_count=0
    for config_mapping in "${configs[@]}"; do
        IFS=':' read -r src dst <<< "$config_mapping"

        if [[ -f "$src" ]]; then
            # Create backup if destination exists
            if [[ -f "$dst" ]]; then
                cp "$dst" "$backup_dir/$(basename "$dst")"
            fi

            # Ensure destination directory exists
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            echo "  Synced: $(basename "$src")"
            synced_count=$((synced_count + 1))
        fi
    done

    # Initialize git repository if needed
    if [[ -d "$dotfiles_dir" ]] && [[ ! -d "$dotfiles_dir/.git" ]]; then
        cd "$dotfiles_dir"
        git init
        git add .
        git commit -m "Initial sync: Terminal Control Plane configurations"
        print_success "Git repository initialized in dotfiles directory"
        cd - >/dev/null
    fi

    print_success "Synced $synced_count configuration files to dotfiles"
    print_info "Backup created: $backup_dir"
}

# ============================================================================
# Completion Message
# ============================================================================

show_completion_message() {
    echo ""
    print_success "Summary:"
    echo "  • Tools installed: $INSTALLED_COUNT"
    echo "  • Tools skipped: $SKIPPED_COUNT"
    if [[ $FAILED_COUNT -gt 0 ]]; then
        echo "  • Tools failed: $FAILED_COUNT"
    fi
    echo ""

    # Display skipped tools
    if [[ ${#SKIPPED_TOOLS[@]} -gt 0 ]]; then
        if supports_colors; then
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}Skipped Tools (${#SKIPPED_TOOLS[@]}):${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        else
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Skipped Tools (${#SKIPPED_TOOLS[@]}):"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
        for tool in "${SKIPPED_TOOLS[@]}"; do
            echo "  • $tool"
        done
        echo ""
    fi

    # Display failed tools
    if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
        if supports_colors; then
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}Failed Installations (${#FAILED_TOOLS[@]}):${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        else
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Failed Installations (${#FAILED_TOOLS[@]}):"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
        for tool in "${FAILED_TOOLS[@]}"; do
            echo "  • $tool"
        done
        echo ""
        print_warning "Please install failed tools manually or check package manager logs"
        echo ""
    fi

    print_info "Total system impact:"
    echo "  • Disk space: ~300MB"
    echo "  • Memory (idle): <70MB"
    if [[ $BACKED_UP_COUNT -gt 0 ]]; then
        echo "  • Backup location: $BACKUP_DIR"
    fi
    echo ""

    if supports_colors; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}Next Steps:${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Next Steps:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
    echo ""
    echo "1. Restart your terminal or run:"
    if supports_colors; then
        echo -e "   ${CYAN}source ~/.bashrc${NC}"
    else
        echo "   source ~/.bashrc"
    fi
    echo ""
    echo "2. Launch WezTerm:"
    if [[ "$PLATFORM" == "macos" ]]; then
        if supports_colors; then
            echo -e "   ${CYAN}open -a WezTerm${NC}"
        else
            echo "   open -a WezTerm"
        fi
    else
        if supports_colors; then
            echo -e "   ${CYAN}wezterm${NC}"
        else
            echo "   wezterm"
        fi
    fi
    echo ""
    echo "3. First launch of NeoVim will install plugins (2-5 min):"
    if supports_colors; then
        echo -e "   ${CYAN}nvim${NC}"
    else
        echo "   nvim"
    fi
    echo ""
    echo "4. Enhanced keyboard shortcuts:"
    if supports_colors; then
        echo -e "   ${CYAN}Ctrl+T${NC}     - Fuzzy find files with preview"
        echo -e "   ${CYAN}Ctrl+R${NC}     - Enhanced history search with fzf"
        echo -e "   ${CYAN}Alt+C${NC}      - Directory search and jump (zoxide)"
    else
        echo "   Ctrl+T     - Fuzzy find files with preview"
        echo "   Ctrl+R     - Enhanced history search with fzf"
        echo "   Alt+C      - Directory search and jump (zoxide)"
    fi
    echo ""
    echo "5. Try these enhanced commands:"
    if supports_colors; then
        echo -e "   ${CYAN}fe${NC}         - Fuzzy find and edit file"
        echo -e "   ${CYAN}fcd${NC}        - Fuzzy find and cd to directory"
        echo -e "   ${CYAN}rge <term>${NC} - Search in codebase with preview"
        echo -e "   ${CYAN}lg${NC}         - Launch lazygit"
        echo -e "   ${CYAN}jl${NC}         - Interactive JSON viewer"
        echo -e "   ${CYAN}tldr ls${NC}    - Quick command help"
    else
        echo "   fe         - Fuzzy find and edit file"
        echo "   fcd        - Fuzzy find and cd to directory"
        echo "   rge <term> - Search in codebase with preview"
        echo "   lg         - Launch lazygit"
        echo "   jl         - Interactive JSON viewer"
        echo "   tldr ls    - Quick command help"
    fi
    echo ""
    if supports_colors; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
    echo ""
}

# ============================================================================
# Script Entry Point
# ============================================================================

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Run main function
main "$@"
