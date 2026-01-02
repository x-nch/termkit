# TermKit User Guide

## Daily Workflows

This guide covers common workflows and productivity patterns using TermKit tools.

## Getting Started

### First Time Setup
```bash
# 1. Install TermKit
cd ~/nexi/termkit
./install.sh

# 2. Verify installation
./scripts/verify-installation.sh

# 3. Restart your shell
source ~/.bashrc

# 4. Test enhanced features
fe                    # Fuzzy file search
fcd                   # Directory navigation
lg                    # Git interface
```

### Daily Shell Usage
```bash
# Enhanced navigation
z projects           # Smart directory jump
fcd                  # Fuzzy directory search
..                   # Go up one directory
...                  # Go up two directories

# File operations
fe                   # Find and edit files
bat README.md        # Syntax-highlighted viewing
eza -la              # Modern ls with icons
```

## Development Workflows

### Code Navigation and Editing
```bash
# Start coding session
cd ~/projects/my-app

# Find and edit files
fe                    # Fuzzy file search with preview
rge "function"        # Search codebase and edit

# Enhanced Git workflow
lg                    # Launch lazygit interface
gs                    # Git status
gl                    # Git log with graph
gd                    # Git diff with delta

# Quick commits
qgc "Add new feature" # Commit and push in one command
```

### Data Processing
```bash
# JSON processing
cat data.json | jq '.users[] | select(.age > 25)' | jl
jqp data.json         # Interactive JSON exploration

# Text processing
cat logs.txt | choose 1 3  # Select columns
sd 'old' 'new' file.txt    # Find and replace

# DNS and network
doggo example.com     # Modern DNS lookup
xh api.example.com    # HTTP requests
```

### System Monitoring
```bash
# Real-time monitoring
btop                  # System monitor

# Process management
procs                 # Modern process listing
procs --tree          # Process tree view
killport 3000         # Kill process on port

# System information
sysinfo               # Comprehensive system info
```

## Tool Integration Examples

### NeoVim + Lazygit Workflow
```bash
# Edit with NeoVim
nvim app.js

# Git operations
lg                    # Visual Git interface
# Use arrow keys to navigate
# Press Enter to select actions
# Press ? for help

# Enhanced Git commands
gco feature-branch    # Checkout branch
gpub                  # Push current branch
gnew feature/new-ui   # Create and push new branch
```

### FZF-Powered Workflows
```bash
# File operations
Ctrl+T               # Fuzzy file search
fe                   # Find and edit with preview
fcd                  # Find and cd to directory

# History and commands
Ctrl+R               # Enhanced history search
Alt+C                # Directory jump

# Custom workflows
project              # Interactive project switcher
web-search "query"   # Search web from terminal
```

### Docker Workflow
```bash
# Container management
dps                  # List containers with formatting
dim                  # List images with formatting
docker-cleanup       # Clean up system

# Development workflow
lzd                  # Launch lazydocker interface
# Navigate containers with arrow keys
# View logs with Enter
# Manage containers visually
```

## Productivity Shortcuts

### Keyboard Shortcuts
```bash
# File and Directory Navigation
Ctrl+T     # Fuzzy file search
Ctrl+R     # Enhanced history search
Alt+C      # Directory jump

# WezTerm (if using GUI terminal)
Ctrl+Shift+T    # New tab
Ctrl+Shift+D    # Split pane
Ctrl+Shift+Left # Navigate panes
```

### Essential Aliases
```bash
# Modern replacements
vim → nvim          # Use NeoVim
cat → bat           # Syntax highlighting
ls → eza           # Modern listing
top → btop          # Beautiful monitor
dig → doggo         # Modern DNS

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
reload → source ~/.bashrc
```

### Power Functions
```bash
# File operations
fe pattern          # Find and edit files
fcd pattern         # Find and cd to directories
rge pattern         # Search and edit with preview

# System operations
mkcd dirname        # Create and cd to directory
killport 8080       # Kill process on port
sysinfo             # System information

# Git operations
qgc "message"       # Quick commit and push
project             # Project switcher

# Docker operations
docker-cleanup      # Clean up Docker system
```

## Advanced Usage Patterns

### Multi-Project Development
```bash
# Project switching
project             # Interactive project selector
# Or use zoxide learning
z project1
z project2

# Cross-project operations
# Search across all projects
rge "TODO" ~/projects/

# Compare configurations
difft config1.json config2.json
```

### Remote Development
```bash
# SSH with TermKit
ssh user@server
# All TermKit tools available on remote

# Sync configurations
dfs                  # Dotfiles status
dfsync               # Sync changes
dfe                  # Edit dotfiles

# Remote file operations
fe                   # Works on remote files
lg                   # Git operations on remote
```

### Documentation and Learning
```bash
# Quick help
tldr tar            # Simplified man pages
help git            # TLDR for git

# Markdown rendering
glow README.md      # Render markdown
readme              # Alias for glow

# Code exploration
bat main.py         # Syntax highlighted code
jqp package.json    # Interactive JSON exploration
```

## Customization

#### Dotfiles Protection System

TermKit implements read-only protection for critical configuration files to prevent accidental modifications:

**Protected Files:**
- `~/.bashrc` - Shell configuration (read-only)
- `~/.gitconfig` - Git settings (read-only)
- `~/.bash_aliases` - Shell aliases (read-only)
- `~/.config/termkit/` - TermKit directory (read-only)

**Protection Details:**
- Files are set to `chmod 444` (read-only)
- TermKit directory uses `chmod -R 444` (recursive read-only)
- Shell scripts retain execute permissions (`chmod 544`)
- Manual override possible with `chmod 644` for editing

**Best Practice:** Add customizations to `~/.bashrc.local` or `~/.config/termkit/custom.sh` instead of modifying protected files directly.

### Adding Personal Aliases
```bash
# Edit custom configuration (recommended approach)
vim ~/.config/termkit/custom.sh

# Add your aliases
alias ll='ls -la'
alias gs='git status'
alias deploy='git push && echo "Deployed!"'

# Or create ~/.bashrc.local for bash-specific customizations
echo 'alias myalias="command"' >> ~/.bashrc.local

# Reload configuration
source ~/.bashrc
```

### Custom Functions
```bash
# Add to ~/.config/termkit/custom.sh
myproject() {
    cd ~/projects/$1
    nvim
}

backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Usage
myproject myapp
backup important.txt
```

### Tool Configuration
```bash
# Starship prompt customization
vim ~/.config/starship.toml
# Edit modules, colors, symbols

# WezTerm customization
vim ~/.config/wezterm/wezterm.lua
# Keybindings, colors, fonts

# Git configuration
vim ~/.gitconfig
# Add custom aliases, settings
```

## Team Collaboration

### Shared Configurations
```bash
# Initialize team dotfiles
cd ~/nexi/termkit/dotfiles
git remote add team git@github.com:team/dotfiles.git

# Sync team configurations
dfsync --remote team

# Share customizations
dfe  # Edit dotfiles
dfs  # Check status
dfsync  # Push changes
```

### Code Review Workflow
```bash
# Enhanced diff viewing
git diff            # Delta-enhanced diffs
difft file1 file2   # Structural diff

# Interactive Git
lg                  # Visual interface
# Review changes, stage hunks, commit

# Share terminal sessions
# Use WezTerm for screen sharing
# Demonstrate workflows
```

## Performance Optimization

### Fast Startup
```bash
# Lazy load heavy tools
# Add to ~/.config/termkit/custom.sh
lazy_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

# Use on demand
lazy_nvm && nvm use 18
```

### Efficient Searching
```bash
# Optimize fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'

# Fast ripgrep
rg --type js "function"  # Search only JS files
rg -C 3 "error"         # Context lines
```

### Memory Management
```bash
# Monitor usage
btop

# Clean up
docker-cleanup
brew cleanup

# Limit resource usage
export NODE_OPTIONS="--max-old-space-size=1024"
```

## Troubleshooting Common Issues

### Tool Not Found
```bash
# Check installation
which nvim rg fd

# Reinstall if missing
brew reinstall neovim ripgrep fd

# Update PATH
source ~/.bashrc
```

### Configuration Not Loading
```bash
# Check integration
grep termkit ~/.bashrc

# Manual reload
source ~/.config/termkit/bash-integration.sh

# Verify functions
type fe fcd rge
```

### Performance Issues
```bash
# Profile startup
time source ~/.bashrc

# Check memory
btop

# Optimize settings
export FZF_DEFAULT_OPTS="--height 20% --no-preview"
```

## Integration Examples

### VS Code Integration
```bash
# Use TermKit tools in VS Code terminal
# All aliases and functions available
fe                    # Fuzzy file search
lg                    # Git interface
bat file.txt          # Syntax highlighting
```

### Tmux Integration
```bash
# Enhanced tmux workflow
tmux new -s development

# Split panes
Ctrl+B %             # Vertical split
Ctrl+B "             # Horizontal split

# Use TermKit in each pane
fe                    # Different files in each pane
```

### Script Integration
```bash
#!/bin/bash
# Use TermKit functions in scripts

source ~/.config/termkit/bash-integration.sh

# Use enhanced functions
mkcd myproject
echo "Created and entered: $(pwd)"

# Git operations
if git status --porcelain | grep -q .; then
    qgc "Auto-commit changes"
fi
```

## Best Practices

### Daily Habits
1. **Start with verification**: Run `./scripts/verify-installation.sh` weekly
2. **Keep tools updated**: `brew update && brew upgrade`
3. **Backup regularly**: Use dotfiles sync for configuration backup
4. **Learn shortcuts**: Practice keyboard shortcuts daily

### Project Organization
1. **Use zoxide**: Let it learn your project locations
2. **Standardize structure**: Keep similar projects in similar locations
3. **Use git**: Version control everything
4. **Document workflows**: Keep notes on custom functions

### Performance Tips
1. **Limit previews**: Use `--no-preview` for faster fzf
2. **Use lazy loading**: Load heavy tools only when needed
3. **Clean regularly**: Remove unused Docker images and cache
4. **Monitor resources**: Use btop to identify bottlenecks

---

*This user guide provides practical workflows for daily TermKit usage. Experiment with different combinations to find your optimal setup.*</content>
<parameter name="filePath">/home/xnch/nexi/termkit/docs/USER_GUIDE.md