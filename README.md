# TermKit v3.0 - Enhanced Terminal Control Plane

**TermKit** is a comprehensive cross-platform workstation setup system that installs 30+ carefully selected terminal tools with enhanced productivity features. This is **TermKit v3.0**, rebuilt from the original with modern enhancements, security improvements, and additional tools.

## 🚀 What's New in v3.0

### Enhanced Features
- **30+ Tools**: Original 25+ tools + 5 modern alternatives
- **Modern Keyboard Shortcuts**: Ctrl+T (file search), Ctrl+R (enhanced history), Alt+C (directory jump)
- **Enhanced Bash Integration**: Completions, aliases, and functions for all tools
- **Security-First**: Hash verification, input validation, safe fallbacks
- **Performance Optimized**: Low memory footprint (<70MB idle), minimal system impact
- **Cross-Platform**: Linux, macOS, and Windows (WSL) support

### New Tools Added
- **sd**: Modern alternative to `sed` with better syntax
- **choose**: Modern alternative to `cut` with intuitive interface  
- **jqp**: Interactive JSON processor for exploration
- **Enhanced alternatives**: Modern replacements for classic tools

### Enhanced Configuration
- **LazyVim**: Auto-setup with optimized configuration
- **Enhanced Starship**: Minimal, fast prompt with git status
- **WezTerm**: Tokyo Night theme, JetBrains Mono font, productivity keybindings
- **btop**: Performance-optimized settings
- **Comprehensive Git**: Delta pager, improved diff settings
- **Dotfiles Protection**: Read-only protection for critical configuration files

## 📦 Tool Stack

### Core Foundation (Phase 1)
- **WezTerm**: Terminal emulator with GPU acceleration
- **Starship**: Fast, minimal shell prompt  
- **NeoVim**: Modern Vim-based text editor with LazyVim
- **btop**: Beautiful system monitor
- **Browsh**: Text-based web browser

### Essential CLI Tools (Phase 2)
- **fzf**: Fuzzy finder with enhanced preview
- **ripgrep**: Fast code search with regex support
- **fd**: Fast file finder with intuitive syntax
- **bat**: Syntax highlighted `cat` with Git integration
- **eza**: Modern `ls` with icons and Git status
- **zoxide**: Smart directory jumper with frequency learning

### Git & Data Tools (Phase 3)
- **lazygit**: Terminal UI for Git operations
- **git-delta**: Enhanced Git diffs with syntax highlighting
- **jq**: JSON processor and formatter
- **jless**: Interactive JSON viewer with exploration
- **xh**: Modern HTTP client with better UX

### File & Process Tools (Phase 4)
- **yazi**: Terminal file manager with image preview
- **procs**: Modern process listing with better formatting
- **sd**: Find and replace tool with intuitive syntax
- **choose**: Cut alternative with column-based selection

### DevOps Tools (Phase 5 - Optional)
- **lazydocker**: Terminal UI for Docker management
- **k9s**: Kubernetes cluster management TUI

### Utility Tools (Phase 6)
- **doggo**: Modern DNS query tool
- **glow**: Markdown renderer for terminal
- **tealdeer**: TLDR pages for quick command help
- **difftastic**: Structural diff tool for better comparisons
- **jqp**: Interactive JSON processor

## 🎯 Enhanced Features

### Keyboard Shortcuts
```bash
Ctrl+T     # Fuzzy find files with bat preview
Ctrl+R     # Enhanced history search with fzf
Alt+C       # Directory search and jump (zoxide)
```

### Enhanced Aliases
```bash
# Core replacements
vim -> nvim          # Use NeoVim by default
cat -> bat           # Syntax highlighted output
ls -> eza           # Modern listing with icons
top -> btop          # Beautiful system monitor

# Enhanced Git
lg -> lazygit        # Launch Git TUI
gs -> git status -s  # Compact status
gl -> git log --oneline --graph -10  # Graph history

# Modern tool shortcuts
http -> xh           # HTTP client
jl -> jless          # JSON viewer
dig -> doggo         # DNS queries
help -> tldr         # Quick command help
fm -> yazi          # File manager
```

### Enhanced Functions
```bash
fe                   # Fuzzy find and edit file
fcd                  # Fuzzy find and cd to directory  
rge <pattern>        # Search codebase with preview and edit
mkcd <dir>           # Create directory and cd into it
killport <port>        # Kill process by port number
qgc <message>         # Quick git commit and push
docker-cleanup       # Clean up Docker system
sysinfo              # Display system information
```

## ⚙️ Installation

### Quick Start
```bash
# Clone and run
git clone <repository-url> ~/nexi/termkit
cd ~/nexi/termkit
./install.sh

# Follow interactive prompts for phased installation
```

### Installation Phases

1. **Phase 0**: Backup existing configurations
2. **Phase 1**: Core tools (WezTerm, Starship, NeoVim, btop, Browsh)
3. **Phase 2**: Essential CLI tools (fzf, ripgrep, fd, bat, eza, zoxide)
4. **Phase 3**: Git & data tools (lazygit, delta, jq, jless, xh)
5. **Phase 4**: File & process tools (yazi, procs, sd, choose)
6. **Phase 5**: DevOps tools - optional (lazydocker, k9s)
7. **Phase 6**: Utility tools (doggo, glow, tealdeer, difftastic, jqp)
8. **Phase 7**: Nerd font installation
9. **Phase 8**: Shell integration and configuration
10. **Phase 9**: Configuration setup

### Platform Support

- **macOS**: Full Homebrew support with casks for GUI tools
- **Linux**: Homebrew + apt/yum/pacman fallbacks
- **Windows**: WSL support with native package managers

## 🔧 Configuration

### Shell Integration
- **Location**: `~/.config/termkit/bash-integration.sh`
- **Features**: Auto-loading, completions, key bindings, aliases
- **Customization**: Add customizations to `~/.config/termkit/custom.sh`

### Configuration Files
- **Starship**: `~/.config/starship.toml` - Minimal, fast prompt
- **WezTerm**: `~/.config/wezterm/wezterm.lua` - Productivity theme
- **NeoVim**: `~/.config/nvim/` - LazyVim with optimized settings
- **Git**: `~/.gitconfig` - Delta pager, improved settings

### Dotfiles Protection System
TermKit implements read-only protection for critical configuration files to prevent accidental modifications:
- **Protected Files**: `~/.bashrc`, `~/.gitconfig`, `~/.bash_aliases`, `~/.config/termkit/`
- **Customization**: Use `~/.config/termkit/custom.sh` or `~/.bashrc.local` for personal additions
- **Manual Override**: Temporarily use `chmod 644` for editing, then restore with `chmod 444`

### Environment Variables
```bash
export EDITOR="${EDITOR:-nvim}"           # Default editor
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
```

## 🔒 Security

### Security Features
- **Hash Verification**: All downloads verified with SHA256 hashes
- **Input Validation**: Comprehensive input sanitization
- **Secure Defaults**: Least privilege principles
- **Audit Logging**: Complete operation tracking
- **Rollback Support**: Safe uninstallation capability

### Security Best Practices
```bash
# Remote script execution pattern (always used)
readonly SCRIPT_URL="https://example.com/script.sh"
readonly SCRIPT_HASH="sha256:abcdef1234567890"

if curl -fsSL "$SCRIPT_URL" > /tmp/script.sh; then
    if echo "$SCRIPT_HASH /tmp/script.sh" | sha256sum -c -; then
        chmod +x /tmp/script.sh && /tmp/script.sh
        rm -f /tmp/script.sh
    else
        echo "Hash verification failed"
        exit 1
    fi
fi
```

## ✅ Verification

### Installation Verification
```bash
# Run comprehensive verification
~/nexi/termkit/scripts/verify-installation.sh

# Check specific tools
which nvim rg fd fzf starship

# Test shell integration
source ~/.bashrc
fe                    # Test file search
rge pattern            # Test code search
```

### Performance Check
```bash
# Memory usage (<70MB idle is good)
free -h

# Disk usage (~300MB installed)
du -sh ~/.config/ ~/nexi/termkit/
```

## 🐛 Troubleshooting

### Common Issues

#### Tool Installation Failed
```bash
# Check Homebrew status
brew doctor

# Manually install specific tool
brew install <tool-name>

# Update package database
brew update
```

#### Configuration Not Working
```bash
# Check shell integration
cat ~/.bashrc | grep termkit

# Reload configuration
source ~/.bashrc

# Check file permissions
ls -la ~/.config/termkit/
```

#### Performance Issues
```bash
# Check memory usage
btop

# Optimize fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Check for background processes
ps aux | grep -E "(nvim|node)" | head -10
```

### Debug Mode
```bash
# Enable debug logging
export TERMKIT_DEBUG=1
~/nexi/termkit/install.sh

# Check installation log
cat ~/.termkit-install.log
```

## 📚 Documentation

### Comprehensive Documentation Suite

- **[User Guide](docs/USER_GUIDE.md)**: Daily workflows, productivity patterns, and usage examples
- **[API Documentation](docs/API.md)**: Complete API reference for scripts, functions, and configurations
- **[Architecture Guide](docs/ARCHITECTURE.md)**: System architecture, components, and data flow
- **[Installation Guide](docs/INSTALLATION.md)**: Detailed installation instructions and platform-specific guides
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)**: Comprehensive troubleshooting and issue resolution
- **[Tools Handbook](TERMKIT_TOOLS_HANDBOOK.md)**: Complete guide to all installed tools and their usage

### File Structure
```
~/nexi/termkit/
├── install.sh                 # Main installer (3000+ lines)
├── dotfiles/                  # Version-controlled configurations
│   ├── install.sh            # Dotfiles management system
│   ├── config/               # Configuration files
│   ├── scripts/              # Management utilities
│   └── backups/              # Backup storage
├── tools/                    # Tool installation modules
│   ├── core.sh               # Core foundation tools
│   ├── cli.sh                # Essential CLI tools
│   ├── git.sh                # Git & data processing tools
│   ├── file-process.sh       # File & process management
│   ├── devops.sh            # DevOps tools (optional)
│   └── utilities.sh          # Additional utilities
├── config/                   # Configuration templates
│   ├── starship.toml        # Starship prompt config
│   ├── wezterm.lua          # WezTerm terminal config
│   ├── gitconfig            # Git settings
│   └── gitignore_global     # Global gitignore
├── scripts/                  # Utility scripts
│   ├── verify-installation.sh # Comprehensive verification
│   ├── validate.sh          # Configuration validation
│   ├── security.sh          # Security functions
│   ├── sync.sh              # Dotfiles synchronization
│   └── test-dotfiles.sh     # Testing framework
├── docs/                     # Documentation suite
│   ├── API.md               # API documentation
│   ├── ARCHITECTURE.md      # System architecture
│   ├── INSTALLATION.md      # Installation guide
│   └── TROUBLESHOOTING.md   # Troubleshooting guide
└── TERMKIT_TOOLS_HANDBOOK.md # Tools reference
```
~/nexi/termkit/
├── install.sh              # Main installer (3000+ lines)
├── tools/                 # Tool installation modules
│   ├── core.sh            # Core tools
│   ├── cli.sh             # CLI tools
│   ├── git.sh            # Git & data tools
│   ├── file-process.sh     # File & process tools
│   ├── devops.sh         # DevOps tools
│   └── utilities.sh       # Utility tools
├── config/                # Configuration templates
│   ├── starship.toml     # Starship prompt
│   ├── wezterm.lua       # WezTerm terminal
│   ├── gitconfig         # Git settings
│   └── gitignore_global  # Global gitignore
├── scripts/               # Utility scripts
│   ├── verify-installation.sh  # Verification script
│   ├── validate.sh       # Configuration validation
│   └── security.sh       # Security functions
└── integration/           # Shell integration files
    └── completions/      # Bash completions
```

### Customization Guide

#### Adding Custom Tools
1. Create tool module in `tools/`
2. Define `install_<category>_tools()` function
3. Add tool to main installer phases
4. Update verification script

#### Custom Aliases
```bash
# Add to ~/.config/termkit/custom.sh
alias myalias='command --options'
myfunction() {
    # Your custom function
}
```

#### Custom Completions
```bash
# Add to integration/completions/
source <(tool --bash-completion)
```

## 🔄 Migration from v2.0

### What's Changed
- **Enhanced Keyboard Shortcuts**: Added Ctrl+T and Alt+C
- **Modern Tools**: Added sd, choose, jqp
- **Security**: Comprehensive hash verification added
- **Performance**: Optimized memory usage and startup
- **Validation**: Built-in verification script
- **Configuration**: Enhanced defaults and customization

### Migration Steps
1. **Backup**: Existing configs automatically backed up
2. **Run Installer**: `~/nexi/termkit/install.sh`
3. **Verify**: `~/nexi/termkit/scripts/verify-installation.sh`
4. **Customize**: Add personal customizations to `custom.sh`

## 📈 Performance

### System Impact
- **Disk Space**: ~300MB (vs ~200MB in v2.0)
- **Memory (idle)**: <70MB (vs <50MB in v2.0)
- **Startup Time**: 8-15 minutes (vs 5-10 minutes in v2.0)
- **Runtime Memory**: ~15MB additional for enhanced features

### Benchmarks
```bash
# Tool performance (typical operations)
rg search: <1s (vs 2s grep)
fd find: <500ms (vs 1s find)
fzf startup: ~100ms
nvim startup: ~200ms (with lazy loading)
```

## 🚀 Getting Started

### After Installation
```bash
# 1. Restart shell or reload
source ~/.bashrc

# 2. Launch WezTerm
wezterm

# 3. First NeoVim launch (installs plugins)
nvim

# 4. Test enhanced features
fe                    # File search with preview
fcd                   # Directory search
lg                    # Launch lazygit
rge pattern           # Code search
sysinfo               # System information
```

### Quick Command Reference

#### Essential Commands
```bash
fe                    # Fuzzy find and edit files
fcd                   # Fuzzy find and cd to directory
rge <pattern>         # Search codebase with preview
lg                    # Launch lazygit Git interface
sysinfo               # Display system information
```

#### Enhanced Aliases
```bash
# Modern tools
vim → nvim           # NeoVim editor
cat → bat            # Syntax-highlighted cat
ls → eza            # Modern ls with icons
top → btop           # Beautiful system monitor

# Git shortcuts
gs → git status -s
gl → git log --oneline --graph -10
gd → git diff
gco → git checkout
gp → git push

# Productivity
q → exit
c → clear
h → history
```

#### Keyboard Shortcuts
```bash
Ctrl+T     # Fuzzy file search
Ctrl+R     # Enhanced history search
Alt+C      # Directory navigation
```

### Daily Workflow Examples
```bash
# Start coding session
cd ~/project
fe                    # Find file to edit
lg                    # Check git status
nvim                   # Start editing

# System monitoring
btop                  # System resource usage
docker-cleanup         # Clean up containers

# Quick info lookup
tldr git             # Command help
doggo example.com     # DNS lookup
```

## 🤝 Contributing

### Development Setup
```bash
# Clone and test
git clone <repo-url> ~/nexi/termkit-dev
cd ~/nexi/termkit-dev

# Test installation
./install.sh

# Run verification
./scripts/verify-installation.sh

# Run validation
./scripts/validate.sh
```

### Adding Tools
1. Create tool module in `tools/`
2. Define installation function
3. Add to main installer
4. Update verification script
5. Test across platforms
6. Update documentation

---

**TermKit v3.0** - Enhanced terminal productivity with modern tooling, security, and performance optimizations.