# TermKit API Documentation

## Overview

TermKit provides a comprehensive API for managing terminal development environments. This document covers the main scripts, functions, and configuration options available in the TermKit system.

## Main Scripts

### install.sh

The primary installation script that sets up the entire TermKit environment.

#### Usage
```bash
./install.sh [options]
```

#### Options
- `--help`: Display help information
- `--dry-run`: Preview installation without making changes
- `--force`: Force reinstallation of all components
- `--skip-verification`: Skip post-installation verification

#### Functions

##### Core Functions
- `main()`: Main installation orchestrator
- `detect_platform()`: Detects operating system and package manager
- `ensure_homebrew()`: Installs Homebrew if not present
- `backup_existing_configs()`: Creates backups of existing configurations
- `setup_configurations()`: Sets up all tool configurations

##### Installation Functions
- `install_core_tools()`: Installs WezTerm, Starship, NeoVim, btop, Browsh
- `install_cli_tools()`: Installs fzf, ripgrep, fd, bat, eza, zoxide
- `install_git_tools()`: Installs lazygit, delta, jq, jless, xh
- `install_file_tools()`: Installs yazi, procs, sd, choose
- `install_devops_tools()`: Installs lazydocker, k9s (optional)
- `install_utility_tools()`: Installs doggo, glow, tealdeer, difftastic, jqp

##### Configuration Functions
- `create_starship_config()`: Generates Starship prompt configuration
- `create_wezterm_config()`: Generates WezTerm terminal configuration
- `setup_lazyvim()`: Configures LazyVim for NeoVim
- `create_bash_integration()`: Creates enhanced bash integration

### dotfiles/install.sh

Manages dotfiles system for configuration synchronization.

#### Usage
```bash
./dotfiles/install.sh [option]
```

#### Options
- `1`: Local configurations only
- `2`: Dotfiles system (recommended)
- `3`: Local + dotfiles hybrid

#### Functions
- `create_dotfiles_structure()`: Initializes dotfiles directory structure
- `sync_to_dotfiles()`: Synchronizes local configs to dotfiles
- `setup_symlinks()`: Creates symbolic links for configurations
- `create_symlink()`: Creates protected symlinks with read-only permissions

### scripts/verify-installation.sh

Comprehensive verification script for installed tools and configurations.

#### Usage
```bash
./scripts/verify-installation.sh [options]
```

#### Options
- `--verbose`: Detailed output
- `--fix`: Attempt to fix issues automatically
- `--report`: Generate detailed report

#### Verification Checks
- Tool installation status
- Configuration file presence
- Shell integration functionality
- Performance benchmarks

### scripts/sync.sh

Manages dotfiles synchronization across machines.

#### Usage
```bash
./scripts/sync.sh <command> [options]
```

#### Commands
- `status`: Show synchronization status
- `sync`: Full synchronization with conflict resolution
- `quick-sync`: Fast sync with auto-conflict resolution
- `push`: Push changes to remote
- `pull`: Pull changes from remote

#### Options
- `--remote <name>`: Specify remote repository
- `--dry-run`: Preview changes without applying
- `--force`: Force synchronization ignoring conflicts

### Dotfiles Protection System (Phase 1)

Implements read-only protection for critical configuration files.

#### Protected Files
- `~/.bashrc` - Shell configuration
- `~/.gitconfig` - Git settings
- `~/.bash_aliases` - Shell aliases
- `~/.config/termkit/` - TermKit integration directory

#### Permission Structure
```bash
# Individual files: read-only
-r--r--r-- ~/.bashrc
-r--r--r-- ~/.gitconfig
-r--r--r-- ~/.bash_aliases

# TermKit directory: read-only with executable scripts
dr-xr-xr-x ~/.config/termkit/
-r-xr--r-- ~/.config/termkit/*.sh  # executable scripts
-r--r--r-- ~/.config/termkit/*     # other files
```

#### Protection Functions
- `apply_readonly_protection()`: Applies read-only permissions to critical files
- `restore_script_permissions()`: Ensures shell scripts remain executable
- `verify_protection_status()`: Checks protection integrity

## Configuration Files

### ~/.config/termkit/bash-integration.sh

Enhanced bash integration with aliases, functions, and completions.

#### Key Functions

##### File Operations
- `fe [pattern]`: Fuzzy find and edit files
- `fcd [pattern]`: Fuzzy find and change directory
- `rge <pattern>`: Search codebase with preview and edit

##### System Operations
- `mkcd <dir>`: Create directory and cd into it
- `killport <port>`: Kill process running on specified port
- `sysinfo`: Display comprehensive system information

##### Git Operations
- `qgc <message>`: Quick git commit and push
- `project`: Interactive project switcher

##### Docker Operations
- `docker-cleanup`: Clean up Docker system

#### Environment Variables
```bash
export EDITOR="${EDITOR:-nvim}"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
```

### ~/.config/starship.toml

Starship prompt configuration for minimal, fast shell prompts.

#### Key Settings
```toml
# Performance optimizations
[status]
disabled = false

[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"

# Disabled slow modules
[nodejs]
disabled = true

[python]
disabled = true
```

### ~/.config/wezterm/wezterm.lua

WezTerm terminal emulator configuration.

#### Key Bindings
```lua
-- Productivity shortcuts
{ key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal },
{ key = 'Enter', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical },
{ key = 'LeftArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
```

#### Performance Settings
```lua
-- Optimized for performance
max_fps = 120,
animation_fps = 60,
cursor_blink_rate = 0,
```

## Tool-Specific APIs

### fzf Integration

#### Key Bindings
- `Ctrl+T`: Fuzzy file search with bat preview
- `Ctrl+R`: Enhanced history search
- `Alt+C`: Directory navigation

#### Custom Functions
```bash
# Enhanced file search with preview
fe() {
    local file
    file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}') && nvim "$file"
}
```

### Git Integration

#### Enhanced Aliases
```bash
alias gs='git status -s'
alias gl='git log --oneline --graph -10'
alias gd='git diff'
alias gco='git checkout'
```

#### Delta Configuration
```gitconfig
[core]
    pager = delta

[delta]
    side-by-side = true
    syntax-theme = GitHub
```

### Docker Integration

#### Enhanced Commands
```bash
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dim='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
```

## Error Codes

### Installation Errors
- `1`: General installation failure
- `2`: Dependency missing
- `3`: Permission denied
- `4`: Network error
- `5`: Configuration conflict

### Verification Errors
- `10`: Tool not installed
- `11`: Configuration missing
- `12`: Permission issue
- `13`: Integration failure

## Examples

### Complete Installation
```bash
# Install TermKit with dotfiles system
cd ~/nexi/termkit
./install.sh

# Choose option 2 for dotfiles system
# Follow interactive prompts
```

### Multi-Machine Setup
```bash
# Machine 1: Initialize dotfiles
cd ~/nexi/termkit/dotfiles
./install.sh  # Choose option 2
git remote add origin <repository-url>
./scripts/sync.sh push

# Machine 2: Clone and setup
git clone <repository-url> ~/nexi/termkit
cd ~/nexi/termkit
./install.sh  # Choose option 2
./scripts/sync.sh pull
```

### Custom Configuration
```bash
# Add custom aliases to ~/.config/termkit/custom.sh
echo "alias mycmd='command --options'" >> ~/.config/termkit/custom.sh

# Reload configuration
source ~/.bashrc
```

### Troubleshooting
```bash
# Run verification
./scripts/verify-installation.sh --verbose

# Check specific tool
which nvim && nvim --version

# Test shell integration
fe  # Should open fuzzy file finder
```

## Security Considerations

- All remote downloads are verified with SHA256 hashes
- Input validation prevents command injection
- Safe file operations with proper permissions
- Backup system prevents data loss
- Audit logging for all operations

## Performance Optimization

### Startup Time
- Lazy loading for heavy components
- Optimized bash completion loading
- Minimal memory footprint (<70MB idle)

### Runtime Performance
- Fast fuzzy finding with ripgrep backend
- Optimized Git operations with delta
- Efficient file operations with modern tools

## Support and Contributing

### Reporting Issues
- Use `./scripts/verify-installation.sh --report` for diagnostics
- Include system information and error logs
- Specify TermKit version and platform

### Contributing
1. Fork the repository
2. Create a feature branch
3. Test changes with `./scripts/test-dotfiles.sh`
4. Submit a pull request

---

*This API documentation covers TermKit v3.0. For the latest updates, check the official repository.*</content>
<parameter name="filePath">/home/xnch/nexi/termkit/docs/API.md