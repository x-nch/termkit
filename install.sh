#!/usr/bin/env bash

# Terminal Control Plane Installation Script v2.0
# This script installs: Core tools + 20+ complementary CLI tools
# Designed for low latency, no bloat, maximum productivity

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
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
    echo -e "\n${CYAN}Install ${tool_name}${NC} - ${description}"
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

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    print_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# Display banner
clear
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║     Terminal Control Plane Setup v2.0                      ║
║                                                            ║
║  Complete terminal-based development environment           ║
║  with 25+ carefully selected tools                         ║
╚════════════════════════════════════════════════════════════╝
EOF

echo ""
print_info "Detected OS: $OS"
echo ""
echo "This will install:"
echo ""
echo "  Core Foundation:"
echo "    • WezTerm, Starship, LazyVim, Browsh, btop"
echo ""
echo "  Essential CLI Tools (Phase 1):"
echo "    • fzf, ripgrep, fd, bat, eza, zoxide"
echo ""
echo "  Git & Data Tools (Phase 2):"
echo "    • lazygit, delta, jq, jless, xh"
echo ""
echo "  File & Process Tools (Phase 3):"
echo "    • yazi, procs"
echo ""
echo "  DevOps Tools (Phase 4 - Optional):"
echo "    • lazydocker, k9s"
echo ""
echo "  Utility Tools (Phase 5):"
echo "    • doggo, glow, tealdeer, difftastic"
echo ""
echo "  System Impact:"
echo "    • Disk Space: ~200MB"
echo "    • Memory (idle): <50MB"
echo "    • Installation Time: 5-10 minutes"
echo ""
read -p "Continue with installation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Installation cancelled"
    exit 1
fi

# Track installed tools
INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0

# Track tool names
SKIPPED_TOOLS=()
FAILED_TOOLS=()

# ============================================
# 1. Install Homebrew (if not present)
# ============================================
print_header "1. Checking Homebrew"
if ! command_exists brew; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$OS" == "macos" ]]; then
        # Add to PATH for M1/M2 Macs
        if [[ -d "/opt/homebrew/bin" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        # Linux - Configure Linuxbrew
        if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
            echo '' >> ~/.bashrc
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
    print_success "Homebrew installed"
    ((INSTALLED_COUNT++))
else
    print_success "Homebrew already installed"
fi

# Update brew
print_section "Updating Homebrew..."
if ! brew update 2>/dev/null; then
    print_warning "Homebrew update failed, continuing anyway..."
fi

# ============================================
# 2. Install Core Tools
# ============================================
print_header "2. Installing Core Tools"

# WezTerm
if ! command_exists wezterm; then
    ask_install "WezTerm" "Terminal Emulator with GPU acceleration"
    install_choice=$?

    if [ $install_choice -eq 0 ]; then
        print_section "Installing WezTerm..."
        if [[ "$OS" == "macos" ]]; then
            if safe_brew_install "wezterm" "cask"; then
                print_success "WezTerm installed"
                ((INSTALLED_COUNT++))
            else
                ((FAILED_COUNT++))
                FAILED_TOOLS+=("WezTerm")
            fi
        else
            print_warning "Please install WezTerm manually: https://wezfurlong.org/wezterm/install/linux.html"
            ((SKIPPED_COUNT++))
            SKIPPED_TOOLS+=("WezTerm (Linux - manual install required)")
        fi
    else
        print_warning "Skipped WezTerm"
        ((SKIPPED_COUNT++))
        SKIPPED_TOOLS+=("WezTerm")
    fi
else
    print_success "WezTerm already installed"
fi

# Starship
if ! command_exists starship; then
    ask_install "Starship" "Fast, minimal shell prompt"
    install_choice=$?

    if [ $install_choice -eq 0 ]; then
        print_section "Installing Starship..."
        if safe_brew_install "starship"; then
            print_success "Starship installed"
            ((INSTALLED_COUNT++))
        else
            ((FAILED_COUNT++))
            FAILED_TOOLS+=("Starship")
        fi
    else
        print_warning "Skipped Starship"
        ((SKIPPED_COUNT++))
        SKIPPED_TOOLS+=("Starship")
    fi
else
    print_success "Starship already installed"
fi

# NeoVim
if ! command_exists nvim; then
    ask_install "NeoVim" "Modern Vim-based text editor"
    install_choice=$?

    if [ $install_choice -eq 0 ]; then
        print_section "Installing NeoVim..."
        if safe_brew_install "neovim"; then
            print_success "NeoVim installed"
            ((INSTALLED_COUNT++))
        else
            ((FAILED_COUNT++))
            FAILED_TOOLS+=("NeoVim")
        fi
    else
        print_warning "Skipped NeoVim"
        ((SKIPPED_COUNT++))
        SKIPPED_TOOLS+=("NeoVim")
    fi
else
    print_success "NeoVim already installed"
fi

# btop
if ! command_exists btop; then
    ask_install "btop" "Beautiful system monitor"
    install_choice=$?

    if [ $install_choice -eq 0 ]; then
        print_section "Installing btop..."
        if safe_brew_install "btop"; then
            print_success "btop installed"
            ((INSTALLED_COUNT++))
        else
            ((FAILED_COUNT++))
            FAILED_TOOLS+=("btop")
        fi
    else
        print_warning "Skipped btop"
        ((SKIPPED_COUNT++))
        SKIPPED_TOOLS+=("btop")
    fi
else
    print_success "btop already installed"
fi

# Browsh
if ! command_exists browsh; then
    ask_install "Browsh" "Text-based web browser"
    install_choice=$?

    if [ $install_choice -eq 0 ]; then
        print_section "Installing Browsh..."
        if [[ "$OS" == "macos" ]]; then
            if safe_brew_install "browsh"; then
                print_success "Browsh installed"
                ((INSTALLED_COUNT++))
            else
                ((FAILED_COUNT++))
                FAILED_TOOLS+=("Browsh")
            fi
        else
            print_warning "Please install Browsh manually: https://www.brow.sh/docs/installation/"
            ((SKIPPED_COUNT++))
            SKIPPED_TOOLS+=("Browsh (Linux - manual install required)")
        fi
    else
        print_warning "Skipped Browsh"
        ((SKIPPED_COUNT++))
        SKIPPED_TOOLS+=("Browsh")
    fi
else
    print_success "Browsh already installed"
fi

# ============================================
# 3. Phase 1: Essential CLI Tools
# ============================================
print_header "3. Phase 1: Essential CLI Tools"

essential_tools=("fzf:Fuzzy Finder" "ripgrep:Fast Code Search" "fd:Fast File Finder" "bat:Syntax Highlighted Cat" "eza:Modern LS" "zoxide:Smart Directory Jumper")

for tool_info in "${essential_tools[@]}"; do
    IFS=':' read -r tool desc <<< "$tool_info"

    if ! command_exists "$tool"; then
        ask_install "$tool" "$desc"
        install_choice=$?

        if [ $install_choice -eq 0 ]; then
            print_section "Installing $tool..."
            if safe_brew_install "$tool"; then
                print_success "$tool installed"
                ((INSTALLED_COUNT++))
            else
                ((FAILED_COUNT++))
                FAILED_TOOLS+=("$tool")
            fi
        else
            print_warning "Skipped $tool"
            ((SKIPPED_COUNT++))
            SKIPPED_TOOLS+=("$tool")
        fi
    else
        print_success "$tool already installed"
    fi
done

# Install fzf key bindings and fuzzy completion
if command_exists fzf; then
    print_section "Setting up fzf key bindings..."
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    print_success "fzf key bindings configured"
fi

# ============================================
# 4. Phase 2: Git & Data Tools
# ============================================
print_header "4. Phase 2: Git & Data Tools"

git_data_tools=("lazygit:Git TUI" "git-delta:Better Git Diffs" "jq:JSON Processor" "jless:JSON Viewer" "xh:HTTP Client")

for tool_info in "${git_data_tools[@]}"; do
    IFS=':' read -r tool desc <<< "$tool_info"

    if [[ "$tool" == "git-delta" ]]; then
        cmd="delta"
    else
        cmd="$tool"
    fi

    if ! command_exists "$cmd"; then
        ask_install "$tool" "$desc"
        install_choice=$?

        if [ $install_choice -eq 0 ]; then
            print_section "Installing $tool..."
            if safe_brew_install "$tool"; then
                print_success "$tool installed"
                ((INSTALLED_COUNT++))
            else
                ((FAILED_COUNT++))
                FAILED_TOOLS+=("$tool")
            fi
        else
            print_warning "Skipped $tool"
            ((SKIPPED_COUNT++))
            SKIPPED_TOOLS+=("$tool")
        fi
    else
        print_success "$tool already installed"
    fi
done

# ============================================
# 5. Phase 3: File & Process Tools
# ============================================
print_header "5. Phase 3: File & Process Tools"

file_proc_tools=("yazi:Terminal File Manager" "procs:Modern PS")

for tool_info in "${file_proc_tools[@]}"; do
    IFS=':' read -r tool desc <<< "$tool_info"

    if ! command_exists "$tool"; then
        ask_install "$tool" "$desc"
        install_choice=$?

        if [ $install_choice -eq 0 ]; then
            print_section "Installing $tool..."
            if safe_brew_install "$tool"; then
                print_success "$tool installed"
                ((INSTALLED_COUNT++))
            else
                ((FAILED_COUNT++))
                FAILED_TOOLS+=("$tool")
            fi
        else
            print_warning "Skipped $tool"
            ((SKIPPED_COUNT++))
            SKIPPED_TOOLS+=("$tool")
        fi
    else
        print_success "$tool already installed"
    fi
done

# ============================================
# 6. Phase 4: DevOps Tools (Optional)
# ============================================
print_header "6. Phase 4: DevOps Tools (Optional)"

echo "These tools are useful if you work with Docker or Kubernetes."
read -p "Install DevOps tools (lazydocker, k9s)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    devops_tools=("lazydocker:Docker TUI" "k9s:Kubernetes TUI")

    for tool_info in "${devops_tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"

        if ! command_exists "$tool"; then
            ask_install "$tool" "$desc"
            install_choice=$?

            if [ $install_choice -eq 0 ]; then
                print_section "Installing $tool..."
                if safe_brew_install "$tool"; then
                    print_success "$tool installed"
                    ((INSTALLED_COUNT++))
                else
                    ((FAILED_COUNT++))
                    FAILED_TOOLS+=("$tool")
                fi
            else
                print_warning "Skipped $tool"
                ((SKIPPED_COUNT++))
                SKIPPED_TOOLS+=("$tool")
            fi
        else
            print_success "$tool already installed"
        fi
    done
else
    print_info "Skipping DevOps tools"
    ((SKIPPED_COUNT+=2))
    SKIPPED_TOOLS+=("lazydocker (DevOps phase skipped)")
    SKIPPED_TOOLS+=("k9s (DevOps phase skipped)")
fi

# ============================================
# 7. Phase 5: Utility Tools
# ============================================
print_header "7. Phase 5: Utility Tools"

utility_tools=("doggo:Modern DNS Tool" "glow:Markdown Renderer" "tealdeer:TLDR Pages" "difftastic:Structural Diffs")

for tool_info in "${utility_tools[@]}"; do
    IFS=':' read -r tool desc <<< "$tool_info"

    if [[ "$tool" == "tealdeer" ]]; then
        cmd="tldr"
    elif [[ "$tool" == "doggo" ]]; then
        cmd="doggo"
    else
        cmd="$tool"
    fi

    if ! command_exists "$cmd"; then
        ask_install "$tool" "$desc"
        install_choice=$?

        if [ $install_choice -eq 0 ]; then
            print_section "Installing $tool..."
            if safe_brew_install "$tool"; then
                print_success "$tool installed"
                ((INSTALLED_COUNT++))
            else
                ((FAILED_COUNT++))
                FAILED_TOOLS+=("$tool")
            fi
        else
            print_warning "Skipped $tool"
            ((SKIPPED_COUNT++))
            SKIPPED_TOOLS+=("$tool")
        fi
    else
        print_success "$tool already installed"
    fi
done

# Update tealdeer cache
if command_exists tldr; then
    print_section "Updating tealdeer cache..."
    tldr --update || true
    print_success "tealdeer cache updated"
fi

# ============================================
# 8. Install Nerd Font
# ============================================
print_header "8. Installing Nerd Font"

if [[ "$OS" == "macos" ]]; then
    if ! brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
        print_section "JetBrains Mono Nerd Font"
        brew tap homebrew/cask-fonts 2>/dev/null || true
        if safe_brew_install "font-jetbrains-mono-nerd-font" "cask"; then
            print_success "Nerd Font installed"
            ((INSTALLED_COUNT++))
        else
            print_warning "Failed to install Nerd Font"
            ((FAILED_COUNT++))
            FAILED_TOOLS+=("JetBrains Mono Nerd Font")
        fi
    else
        print_success "Nerd Font already installed"
    fi
else
    print_warning "Please install a Nerd Font manually for your system"
    ((SKIPPED_COUNT++))
    SKIPPED_TOOLS+=("JetBrains Mono Nerd Font (Linux - manual install required)")
fi

# ============================================
# 9. Backup Existing Configs
# ============================================
print_header "9. Backing Up Existing Configurations"

backup_dir="$HOME/termkit-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

configs_backed_up=0

if [[ -d "$HOME/.config/wezterm" ]]; then
    cp -r "$HOME/.config/wezterm" "$backup_dir/"
    print_success "Backed up WezTerm config"
    ((configs_backed_up++))
fi

if [[ -d "$HOME/.config/nvim" ]]; then
    cp -r "$HOME/.config/nvim" "$backup_dir/"
    print_success "Backed up NeoVim config"
    ((configs_backed_up++))
fi

if [[ -f "$HOME/.config/starship.toml" ]]; then
    cp "$HOME/.config/starship.toml" "$backup_dir/"
    print_success "Backed up Starship config"
    ((configs_backed_up++))
fi

if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$backup_dir/.zshrc"
    print_success "Backed up .zshrc"
    ((configs_backed_up++))
fi

if [[ $configs_backed_up -gt 0 ]]; then
    print_info "Backups saved to: $backup_dir"
else
    print_info "No existing configs to backup"
    rmdir "$backup_dir" 2>/dev/null || true
fi

# ============================================
# 9.5. Configuration Management Strategy
# ============================================
print_header "9.5. Configuration Management Strategy"

echo ""
echo "You have two options for managing configurations:"
echo ""
echo "${GREEN}Option 1: Use Dotfiles System (Recommended)${NC}"
echo "  • Version control all configs with Git"
echo "  • Sync across machines"
echo "  • Easy rollback to previous versions"
echo "  • Changes automatically tracked"
echo "  • Location: ~/xnch/termkit/dotfiles/"
echo ""
echo "${CYAN}Option 2: Generate Local Configs${NC}"
echo "  • Creates configs directly in ~/.config/"
echo "  • No version control by default"
echo "  • Simpler, but less flexible"
echo ""

USE_DOTFILES=false
DOTFILES_DIR="$HOME/xnch/termkit/dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
    read -p "Use dotfiles system for configuration management? (y/n) " -n 1 -r
    echo
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        USE_DOTFILES=true
        print_info "Will use dotfiles system - skipping local config generation"
        print_info "Configs will be symlinked from: $DOTFILES_DIR/config/"
    else
        print_info "Will generate local configs in ~/.config/"
    fi
else
    print_warning "Dotfiles directory not found at: $DOTFILES_DIR"
    print_info "Will generate local configs in ~/.config/"
    print_info "You can set up dotfiles later by running: cd $DOTFILES_DIR && ./install.sh"
fi

# ============================================
# 10. Configure Shell
# ============================================
print_header "10. Configuring Shell"

# Create shell integration script
SHELL_INTEGRATION_FILE="$HOME/.config/termkit/shell-integration.sh"
mkdir -p "$HOME/.config/termkit"

cat > "$SHELL_INTEGRATION_FILE" << 'SHELL_EOF'
# ============================================
# Terminal Control Plane Shell Integration
# Auto-generated by install.sh
# ============================================

# Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# fzf Integration
if command -v fzf &> /dev/null; then
    # Key bindings
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    # Use ripgrep for fzf if available
    if command -v rg &> /dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Use bat for preview if available
    if command -v bat &> /dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    fi

    # Improved fzf colors
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# zoxide Integration (smart cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# ============================================
# Aliases
# ============================================

# Core replacements
if command -v nvim &> /dev/null; then
    alias vim='nvim'
    alias vi='nvim'
fi

if command -v btop &> /dev/null; then
    alias top='btop'
fi

if command -v eza &> /dev/null; then
    alias ls='eza --icons --git'
    alias ll='eza --icons --git -l'
    alias la='eza --icons --git -la'
    alias lt='eza --icons --git --tree'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias less='bat'
fi

if command -v procs &> /dev/null; then
    alias ps='procs'
fi

# Git shortcuts
if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Data tools
if command -v xh &> /dev/null; then
    alias http='xh'
fi

if command -v jless &> /dev/null; then
    alias jl='jless'
fi

# Documentation
if command -v browsh &> /dev/null; then
    alias docs='browsh'
fi

if command -v glow &> /dev/null; then
    alias readme='glow -p'
fi

if command -v tldr &> /dev/null; then
    alias help='tldr'
fi

# File management
if command -v yazi &> /dev/null; then
    alias fm='yazi'
fi

# DevOps
if command -v lazydocker &> /dev/null; then
    alias lzd='lazydocker'
fi

if command -v k9s &> /dev/null; then
    alias k='kubectl'
fi

# Navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ============================================
# Functions
# ============================================

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
    lsof -ti:$1 | xargs kill -9
}

# Quick file search and edit
fe() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0)
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# Quick directory search and cd
fcd() {
    local dir
    dir=$(fd --type d | fzf --query="$1" --select-1 --exit-0)
    [ -n "$dir" ] && cd "$dir"
}

# Search in files with ripgrep and open in editor
rge() {
    local file
    local line

    read -r file line <<< $(rg --line-number "$1" | fzf --delimiter ':' --preview 'bat --color=always --highlight-line {2} {1}' | awk -F: '{print $1, $2}')

    if [[ -n $file ]]; then
        ${EDITOR:-nvim} "$file" +$line
    fi
}

# Quick git commit
qgc() {
    git add -A && git commit -m "$*" && git push
}

# Docker cleanup
docker-cleanup() {
    docker system prune -af --volumes
}

# ============================================
# History Configuration
# ============================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# Share history across terminals
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# ============================================
# Performance Improvements
# ============================================

# Lazy load nvm if present
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    alias nvm='unalias nvm && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm'
fi
SHELL_EOF

print_success "Shell integration script created"

# Add to .zshrc
if ! grep -q "termkit/shell-integration.sh" "$HOME/.zshrc" 2>/dev/null; then
    print_section "Adding integration to .zshrc..."
    cat >> "$HOME/.zshrc" << 'ZSH_EOF'

# ============================================
# Terminal Control Plane Integration
# ============================================
source ~/.config/termkit/shell-integration.sh
ZSH_EOF
    print_success ".zshrc updated"
else
    print_success ".zshrc already configured"
fi

# ============================================
# 11. Setup Configuration Files
# ============================================

if [[ "$USE_DOTFILES" == false ]]; then
    print_header "11. Setting Up Configuration Files"

    # Starship
    print_section "Starship configuration..."
mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" << 'STARSHIP_EOF'
# Minimal, fast prompt configuration

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
symbol = ""
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

# WezTerm
print_section "WezTerm configuration..."
mkdir -p "$HOME/.config/wezterm"
cat > "$HOME/.config/wezterm/wezterm.lua" << 'WEZTERM_EOF'
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

-- Keybindings
config.keys = {
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = '[', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Next' },
  { key = '9', mods = 'CMD', action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
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

# Git delta configuration
if command_exists delta; then
    print_section "Configuring git delta..."
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate "true"
    git config --global delta.light "false"
    git config --global delta.side-by-side "true"
    git config --global merge.conflictstyle "diff3"
    git config --global diff.colorMoved "default"
    print_success "Git delta configured"
fi

# LazyVim
print_section "LazyVim setup..."
if [[ -d "$HOME/.config/nvim" ]]; then
    read -p "NeoVim config exists. Replace with LazyVim? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.config/nvim"
        rm -rf "$HOME/.local/share/nvim"
        rm -rf "$HOME/.local/state/nvim"
        rm -rf "$HOME/.cache/nvim"
    else
        print_warning "Skipping LazyVim installation"
    fi
fi

if [[ ! -d "$HOME/.config/nvim" ]]; then
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    print_success "LazyVim installed (will configure on first launch)"
else
    print_success "NeoVim config exists"
fi

# btop
print_section "btop configuration..."
mkdir -p "$HOME/.config/btop"
timeout 2 btop || true  # Generate default config
if [[ -f "$HOME/.config/btop/btop.conf" ]]; then
    sed -i.bak 's/update_ms=.*/update_ms=1000/' "$HOME/.config/btop/btop.conf" 2>/dev/null || \
    sed -i '' 's/update_ms=.*/update_ms=1000/' "$HOME/.config/btop/btop.conf" 2>/dev/null || true
    print_success "btop configured"
fi

# Browsh
print_section "Browsh configuration..."
mkdir -p "$HOME/.config/browsh"
cat > "$HOME/.config/browsh/config.toml" << 'BROWSH_EOF'
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

else
    # Using dotfiles system - run installer
    print_header "11. Installing Dotfiles System"

    if [[ -f "$DOTFILES_DIR/install.sh" ]]; then
        cd "$DOTFILES_DIR" || {
            print_error "Failed to access dotfiles directory"
            exit 1
        }

        print_info "Running dotfiles installer..."
        chmod +x install.sh
        ./install.sh

        print_success "Dotfiles system installed"
        echo ""
        echo "Your configurations are now managed via dotfiles:"
        echo "  • Location: $DOTFILES_DIR"
        echo "  • Version controlled with Git"
        echo "  • Changes to ~/.config/ files automatically tracked"
        echo ""
    else
        print_warning "Dotfiles installer not found at: $DOTFILES_DIR/install.sh"
        print_info "Generating local configs as fallback..."
        # Fall back to generating configs
        USE_DOTFILES=false
    fi
fi

# ============================================
# 12. Completion Message
# ============================================
print_header "Installation Complete!"

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
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Skipped Tools (${#SKIPPED_TOOLS[@]}):${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    for tool in "${SKIPPED_TOOLS[@]}"; do
        echo "  • $tool"
    done
    echo ""
fi

# Display failed tools
if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}Failed Installations (${#FAILED_TOOLS[@]}):${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    for tool in "${FAILED_TOOLS[@]}"; do
        echo "  • $tool"
    done
    echo ""
    print_warning "Please install failed tools manually or check Homebrew logs"
    echo ""
fi

print_info "Total system impact:"
echo "  • Disk space: ~200MB"
echo "  • Memory (idle): <50MB"
if [[ $configs_backed_up -gt 0 ]]; then
    echo "  • Backup location: $backup_dir"
fi
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Restart your terminal or run:"
echo "   ${CYAN}source ~/.zshrc${NC}"
echo ""
echo "2. Launch WezTerm:"
if [[ "$OS" == "macos" ]]; then
    echo "   ${CYAN}open -a WezTerm${NC}"
else
    echo "   ${CYAN}wezterm${NC}"
fi
echo ""
echo "3. First launch of NeoVim will install plugins (2-5 min):"
echo "   ${CYAN}nvim${NC}"
echo ""
echo "4. Try these commands:"
echo "   ${CYAN}Ctrl+R${NC}     - Fuzzy search command history"
echo "   ${CYAN}Ctrl+T${NC}     - Fuzzy find files"
echo "   ${CYAN}z <name>${NC}   - Jump to directory"
echo "   ${CYAN}lg${NC}         - Launch lazygit"
echo "   ${CYAN}rg <term>${NC}  - Search in codebase"
echo "   ${CYAN}tldr ls${NC}    - Quick command help"
echo ""
echo "5. Read the documentation:"
echo "   ${CYAN}cd $(dirname "$0")${NC}"
echo "   ${CYAN}glow README.md${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Documentation Files:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  • README.md           - Overview and quick start"
echo "  • QUICKSTART.md       - 15-minute getting started guide"
echo "  • TOOLS.md            - Complete tool reference"
echo "  • SETUP.md            - Detailed setup instructions"
echo "  • WORKFLOWS.md        - Common workflows and patterns"
echo "  • ARCHITECTURE.md     - System design and mental models"
echo "  • KEYBINDINGS.md      - Complete keybinding reference"
echo "  • CONFIGURATIONS.md   - Configuration examples"
echo "  • TROUBLESHOOTING.md  - Common issues and solutions"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ============================================
# 13. Next Steps for Dotfiles (if not installed)
# ============================================

if [[ "$USE_DOTFILES" == false ]]; then
    print_header "13. Optional: Install Dotfiles System Later"

    echo ""
    echo "You chose to use local configs. You can switch to the dotfiles system anytime:"
    echo ""
    echo "  ${CYAN}cd ~/xnch/termkit/dotfiles${NC}"
    echo "  ${CYAN}./install.sh${NC}"
    echo ""
    echo "Benefits of dotfiles:"
    echo "  • Track configuration changes in Git"
    echo "  • Sync configs across multiple machines"
    echo "  • Rollback to previous configs easily"
    echo "  • Automatic backups"
    echo ""
else
    print_success "Configuration management complete via dotfiles system"
    echo ""
    echo "Next steps for dotfiles:"
    echo "  1. Review symlinks: ${CYAN}ls -la ~/ | grep ' -> '${NC}"
    echo "  2. Check status: ${CYAN}cd ~/xnch/termkit/dotfiles && git status${NC}"
    echo "  3. Commit configs: ${CYAN}cd ~/xnch/termkit/dotfiles && make commit MSG=\"Initial setup\"${NC}"
    echo "  4. Sync to remote: ${CYAN}cd ~/xnch/termkit/dotfiles && make sync${NC}"
    echo ""
fi

# Return to original directory
cd "$HOME/xnch/termkit" 2>/dev/null || cd "$HOME"

# ============================================
# Final Message
# ============================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Happy hacking! 🚀${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
