# TermKit v3.0 - Installation Guide

## 🚀 Quick Start

### System Requirements
- **macOS**: 10.15+ (Catalina or newer)
- **Linux**: Ubuntu 18.04+, Debian 10+, Fedora 30+, Arch Linux
- **Windows**: WSL2 with Ubuntu/Debian
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: 500MB free space for full installation

### Installation Command
```bash
# Download and install (one command)
curl -fsSL https://raw.githubusercontent.com/your-repo/termkit/main/install.sh | bash

# Or clone and run
git clone https://github.com/your-repo/termkit ~/nexi/termkit
cd ~/nexi/termkit
chmod +x install.sh
./install.sh
```

## 📋 Installation Phases

### Phase 0: Preparation
- **System detection** and package manager setup
- **Homebrew installation** (if missing)
- **Configuration backup** of existing files

### Phase 1: Core Tools (Required)
```
WezTerm     - Terminal emulator with GPU acceleration
Starship     - Fast, minimal shell prompt  
NeoVim      - Modern Vim-based editor (LazyVim)
btop         - Beautiful system monitor
Browsh       - Text-based web browser
```

### Phase 2: Essential CLI Tools (Required)
```
fzf         - Fuzzy finder with preview
ripgrep     - Fast code search
fd           - Fast file finder  
bat          - Syntax highlighted cat
eza          - Modern ls with icons
zoxide       - Smart directory jumper
```

### Phase 3: Git & Data Tools (Required)
```
lazygit      - Git terminal UI
git-delta    - Enhanced git diffs
jq           - JSON processor
jless        - Interactive JSON viewer
xh           - Modern HTTP client
```

### Phase 4: File & Process Tools (Required)
```
yazi         - Terminal file manager
procs        - Modern ps replacement
sd           - Find/replace (sed alternative)
choose       - Cut alternative
```

### Phase 5: DevOps Tools (Optional)
```
lazydocker   - Docker management TUI
k9s          - Kubernetes management TUI
```

### Phase 6: Utility Tools (Required)
```
doggo        - Modern DNS tool
glow         - Markdown renderer
tealdeer     - TLDR pages
difftastic   - Structural diffs
jqp          - Interactive JSON processor
```

### Phase 7: Visual Enhancement
```
JetBrains Mono Nerd Font - Development-friendly font with glyphs
```

### Phase 8-9: Configuration
```
Shell integration - Enhanced bash with completions
Tool configs   - Optimized settings for all tools
```

## ⚙️ Configuration Options

### During Installation

#### Package Manager Priority
```bash
# Choose your preference:
1. Homebrew (recommended, cross-platform)
2. System package manager (apt, yum, pacman)
3. Manual installation (for specific tools)
```

#### Configuration Strategy
```bash
# Choose management approach:
1. Local configs (simple, immediate)
2. Dotfiles system (version control, sync)
```

### Post-Installation

#### Environment Variables
```bash
# Set preferred editor
export EDITOR="nvim"  # or vim, emacs, etc.

# Adjust fzf performance
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
```

#### Custom Shell Integration
```bash
# Add to ~/.config/termkit/custom.sh
alias mycustom='command --flag'

myfunction() {
    # Your custom function
    echo "Custom functionality"
}

# Reload with: source ~/.bashrc
```

## 🔧 Manual Installation

### Individual Tools

#### Core Tools
```bash
# WezTerm
brew install --cask wezterm
# or manual: https://wezfurlong.org/wezterm/install/linux.html

# Starship
curl -sS https://starship.rs/install.sh | sh

# NeoVim (LazyVim)
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# btop
brew install btop

# Browsh
brew install browsh
```

#### CLI Tools
```bash
# fzf
brew install fzf
$(brew --prefix)/opt/fzf/install --key-bindings --completion

# ripgrep
brew install ripgrep

# fd
brew install fd

# bat
brew install bat

# eza
brew install eza

# zoxide
cargo install zoxide
```

## 🎯 First Steps After Installation

### 1. Restart Your Shell
```bash
# Option 1: Restart terminal completely
# Option 2: Source configuration
source ~/.bashrc
```

### 2. Verify Installation
```bash
# Run verification script
~/nexi/termkit/scripts/verify-installation.sh

# Quick tool checks
which nvim rg fd fzf starship btop
```

### 3. Test Enhanced Features
```bash
# Test file search with preview
fe

# Test directory jump
zoxide -q <directory>

# Test enhanced git
lg

# Test fzf integration
Ctrl+T  # File search
Ctrl+R  # Enhanced history
Alt+C   # Directory jump
```

### 4. Configure Preferences

#### Starship Prompt Customization
```bash
# Edit ~/.config/starship.toml
vim ~/.config/starship.toml

# Customize prompt segments
# Adjust colors, symbols, modules
```

#### WezTerm Customization
```bash
# Edit ~/.config/wezterm/wezterm.lua
vim ~/.config/wezterm/wezterm.lua

# Key bindings, colors, fonts
```

#### NeoVim Extensions
```bash
# Launch NeoVim (LazyVim auto-installs plugins)
nvim

# Add custom plugins to ~/.config/nvim/lua/custom/plugins.lua
# Add custom settings to ~/.config/nvim/lua/custom/options.lua
```

## 🐛 Platform-Specific Instructions

### macOS
```bash
# Homebrew installation (if missing)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (M1/M2 Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# GUI applications via casks
brew install --cask wezterm font-jetbrains-mono-nerd-font
```

### Linux (Debian/Ubuntu)
```bash
# Install build dependencies
sudo apt update
sudo apt install build-essential curl git

# Homebrew installation
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### Linux (Arch)
```bash
# Install via pacman (alternative to Homebrew)
sudo pacman -Syu neovim fzf ripgrep fd bat eza btop

# Use yay for AUR packages
yay -S zoxide starship
```

### Windows (WSL2)
```bash
# Ensure WSL2 is enabled
wsl --list --verbose

# Install Ubuntu/Debian distro from Microsoft Store
# Then follow Linux installation steps
```

## 🔍 Troubleshooting

### Common Installation Issues

#### Homebrew Issues
```bash
# Fix permissions
sudo chown -R $(whoami) /home/linuxbrew/.linuxbrew/

# Update Homebrew
brew update && brew doctor

# Clean up
brew cleanup
```

#### Permission Issues
```bash
# Fix script permissions
chmod +x ~/nexi/termkit/install.sh

# Fix directory permissions
chmod 755 ~/.config/termkit/
```

#### Shell Integration Not Working
```bash
# Check if termkit is sourced
grep "termkit" ~/.bashrc

# Manually add to bashrc
echo 'source ~/.config/termkit/bash-integration.sh' >> ~/.bashrc

# Reload configuration
source ~/.bashrc
```

### Performance Issues

#### Memory Usage
```bash
# Check what's using memory
btop

# Disable heavy tool features
# Edit ~/.config/starship.toml to disable slow modules
# Remove unused shell completions
```

#### Slow Fuzzy Finding
```bash
# Optimize fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Reduce search scope
rg --max-depth 2 pattern
```

### Font Issues

#### Nerd Font Not Displaying
```bash
# Install manually (Linux)
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/JetBrainsMono.tar.xz
tar -xf JetBrainsMono.tar.xz
fc-cache -fv

# Verify installation
fc-list | grep "JetBrains Mono"
```

#### WezTerm Font Issues
```bash
# Edit ~/.config/wezterm/wezterm.lua
# Change font to system default
config.font = wezterm.font_with_fallback("JetBrains Mono", "Consolas")
```

## 📚 Advanced Configuration

### Custom Tool Aliases
```bash
# Add to ~/.config/termkit/custom.sh

# Development shortcuts
alias api='cd ~/projects/api'
alias web='cd ~/projects/webapp'
alias tests='python -m pytest'

# Tool shortcuts
alias docker-clean='docker system prune -af'
alias logs='journalctl -f'
```

### Enhanced FZF Configuration
```bash
# Add to ~/.config/termkit/custom.sh

# Custom fzf functions
fv() {
    vim $(fzf --preview 'bat --color=always {}')
}

# Enhanced file search with context
ff() {
    rg -l "$1" | fzf --preview "rg --color=always -C5 $1 {}" \
        --bind 'enter:execute(vim {})+abort'
}
```

### Git Workflow Integration
```bash
# Enhanced git functions
gpub() {
    local branch=$(git branch --show-current)
    git push origin "$branch"
}

gnew() {
    git checkout -b "feature/$1"
    git push -u origin "feature/$1"
}

# Branch switching with fzf
gco() {
    git checkout $(git branch --format='%(refname:short)' | fzf)
}
```

## 🔄 Updates and Maintenance

### Updating TermKit
```bash
# Update to latest version
cd ~/nexi/termkit
git pull origin main

# Re-run installation
./install.sh

# Verify updates
./scripts/verify-installation.sh
```

### Maintenance Tasks
```bash
# Clean up package manager
brew cleanup && brew autoremove
sudo apt autoremove

# Clear caches
rm -rf ~/.cache/nvim
rm -rf ~/.local/share/nvim

# Update tool databases
tldr --update
```

### Backup and Restore
```bash
# Backup configurations
cp -r ~/.config/termkit ~/termkit-config-backup

# Restore from backup
rm -rf ~/.config/termkit
cp -r ~/termkit-config-backup ~/.config/termkit
```

---

**Need Help?** Check out the [Troubleshooting Guide](TROUBLESHOOTING.md) or [open an issue](https://github.com/your-repo/termkit/issues).