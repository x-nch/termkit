# TermKit Troubleshooting Guide

## Overview

This comprehensive troubleshooting guide covers common issues, diagnostic procedures, and resolution steps for TermKit installations and operations.

## Quick Diagnostics

### System Health Check
```bash
# Run comprehensive verification
~/nexi/termkit/scripts/verify-installation.sh

# Check system information
sysinfo

# Test shell integration
source ~/.bashrc
fe  # Should open fuzzy file finder
```

### Log Locations
```bash
# Installation logs
~/.termkit-install.log

# Dotfiles operation logs
~/nexi/termkit/dotfiles/logs/

# System logs (Linux)
journalctl -u termkit 2>/dev/null || echo "No systemd service"

# macOS logs
log show --predicate 'process == "termkit"' --last 1h
```

## Installation Issues

### Common Installation Failures

#### Homebrew Installation Issues
**Symptoms**: Homebrew fails to install or update

**Diagnosis**:
```bash
# Check Homebrew status
brew doctor

# Check permissions
ls -la /usr/local/  # macOS
ls -la /home/linuxbrew/  # Linux

# Check network connectivity
curl -I https://github.com
```

**Solutions**:
```bash
# Fix permissions (Linux)
sudo chown -R $(whoami) /home/linuxbrew/

# Reinstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update Homebrew
brew update && brew upgrade
```

#### Tool Installation Failures
**Symptoms**: Specific tools fail to install

**Diagnosis**:
```bash
# Check package manager
which brew || which apt || which yum

# Check tool availability
brew search <tool-name>

# Check disk space
df -h
```

**Solutions**:
```bash
# Manual installation fallback
brew install --force <tool-name>

# Alternative package manager
sudo apt install <tool-name>  # Ubuntu/Debian
sudo yum install <tool-name>  # CentOS/RHEL

# Clean and retry
brew cleanup && brew install <tool-name>
```

#### Permission Issues
**Symptoms**: Permission denied errors during installation

**Diagnosis**:
```bash
# Check current user
whoami

# Check sudo access
sudo -v

# Check file permissions
ls -la ~/nexi/termkit/
```

**Solutions**:
```bash
# Run with sudo if necessary
sudo ~/nexi/termkit/install.sh

# Fix permissions
chmod +x ~/nexi/termkit/install.sh
chmod 755 ~/nexi/termkit/

# Change ownership
sudo chown -R $(whoami) ~/nexi/termkit/
```

### Configuration Issues

#### Shell Integration Not Working
**Symptoms**: Aliases and functions not available after installation

**Diagnosis**:
```bash
# Check if termkit is sourced
grep "termkit" ~/.bashrc ~/.zshrc ~/.profile

# Check integration file
ls -la ~/.config/termkit/bash-integration.sh

# Test sourcing
source ~/.config/termkit/bash-integration.sh
fe  # Test function
```

**Solutions**:
```bash
# Manual addition to bashrc
echo 'source ~/.config/termkit/bash-integration.sh' >> ~/.bashrc

# Reload shell
source ~/.bashrc

# Check for syntax errors
bash -n ~/.config/termkit/bash-integration.sh

# Reinstall integration
~/nexi/termkit/install.sh --reinstall-integration
```

#### Configuration File Conflicts
**Symptoms**: Existing configurations overwritten or conflicting

**Diagnosis**:
```bash
# Check backup directory
ls -la ~/termkit-backup-*/

# Compare configurations
diff ~/.bashrc ~/.termkit-backup-*/bashrc

# Check for syntax errors
bash -n ~/.bashrc
```

**Solutions**:
```bash
# Restore from backup
cp ~/termkit-backup-*/bashrc ~/.bashrc

# Merge configurations manually
vimdiff ~/.bashrc ~/termkit-backup-*/bashrc

# Reinstall with backup preservation
~/nexi/termkit/install.sh --preserve-existing
```

#### Read-Only Protection Issues
**Symptoms**: Cannot edit protected configuration files

**Diagnosis**:
```bash
# Check file permissions
ls -la ~/.bashrc ~/.gitconfig ~/.bash_aliases

# Check termkit directory permissions
ls -la ~/.config/termkit/

# Verify protection status
stat ~/.bashrc | grep "Access:"
```

**Solutions**:
```bash
# Temporarily make file writable for editing
chmod 644 ~/.bashrc

# Edit the file
vim ~/.bashrc

# Restore protection (optional)
chmod 444 ~/.bashrc

# Use recommended customization files instead
echo 'alias myalias="command"' >> ~/.config/termkit/custom.sh
# or
echo 'export MY_VAR=value' >> ~/.bashrc.local
```

#### Shell Script Execution Permission Issues
**Symptoms**: `source ~/.bashrc` fails with "Permission denied"

**Diagnosis**:
```bash
# Check termkit script permissions
ls -la ~/.config/termkit/*.sh

# Test script execution
bash ~/.config/termkit/shell-integration-bash.sh

# Check if scripts have execute permission
stat ~/.config/termkit/shell-integration-bash.sh | grep "Access:"
```

**Solutions**:
```bash
# Make termkit directory temporarily writable
chmod 755 ~/.config/termkit/

# Restore execute permissions on shell scripts
chmod 544 ~/.config/termkit/*.sh

# Make directory read-execute only
chmod 555 ~/.config/termkit/

# Reload configuration
source ~/.bashrc
```

### Performance Issues

#### Slow Shell Startup
**Symptoms**: Shell takes >2 seconds to load

**Diagnosis**:
```bash
# Time shell startup
time source ~/.bashrc

# Check loaded components
grep -n "source\|export\|alias" ~/.bashrc | head -20

# Profile startup
bash --login -c 'echo "Startup complete"'
```

**Solutions**:
```bash
# Disable heavy completions
echo "# Disabled heavy completions" >> ~/.config/termkit/custom.sh
echo "export BASH_COMPLETION_LOAD=0" >> ~/.config/termkit/custom.sh

# Optimize fzf settings
export FZF_DEFAULT_OPTS="--height 20% --no-preview"

# Use lazy loading
# Add to ~/.config/termkit/custom.sh
lazy_load() {
    # Load heavy tools only when needed
}
```

#### High Memory Usage
**Symptoms**: System memory usage >70MB idle

**Diagnosis**:
```bash
# Check memory usage
btop  # Or htop/top

# Check running processes
ps aux | grep -E "(nvim|node|python)" | head -10

# Check background jobs
jobs -l
```

**Solutions**:
```bash
# Kill unnecessary processes
killall -9 <process-name>

# Optimize tool settings
echo "export NODE_OPTIONS='--max-old-space-size=512'" >> ~/.config/termkit/custom.sh

# Disable memory-intensive features
echo "export STARSHIP_CONFIG_DISABLE_MEMORY=true" >> ~/.config/termkit/custom.sh
```

#### Slow Fuzzy Finding
**Symptoms**: fzf operations take >1 second

**Diagnosis**:
```bash
# Test fzf performance
time fd . | fzf --no-preview

# Check search scope
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
time $FZF_DEFAULT_COMMAND | wc -l
```

**Solutions**:
```bash
# Optimize search command
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'

# Reduce preview load
export FZF_DEFAULT_OPTS="--height 40% --no-preview"

# Use faster alternatives
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*" -not -name "*.tmp"'
```

## Tool-Specific Issues

### WezTerm Issues

#### Font Display Problems
**Symptoms**: Icons or fonts not displaying correctly

**Diagnosis**:
```bash
# Check font installation
fc-list | grep "JetBrains\|Mono"

# Check WezTerm config
cat ~/.config/wezterm/wezterm.lua | grep font

# Test font rendering
wezterm --version
```

**Solutions**:
```bash
# Install Nerd Fonts
brew install --cask font-jetbrains-mono-nerd-font

# Update font cache
fc-cache -fv

# Update WezTerm config
echo 'config.font = wezterm.font_with_fallback("JetBrains Mono", "Monaco")' >> ~/.config/wezterm/wezterm.lua
```

#### Performance Issues
**Symptoms**: WezTerm slow or laggy

**Diagnosis**:
```bash
# Check system resources
btop

# Check WezTerm settings
cat ~/.config/wezterm/wezterm.lua | grep fps
```

**Solutions**:
```bash
# Optimize settings
echo 'config.max_fps = 60' >> ~/.config/wezterm/wezterm.lua
echo 'config.animation_fps = 30' >> ~/.config/wezterm/wezterm.lua
echo 'config.cursor_blink_rate = 0' >> ~/.config/wezterm/wezterm.lua
```

### NeoVim/LazyVim Issues

#### Plugin Installation Failures
**Symptoms**: LazyVim plugins not loading

**Diagnosis**:
```bash
# Check NeoVim version
nvim --version

# Check LazyVim installation
ls -la ~/.config/nvim/

# Test NeoVim startup
nvim --headless -c "echo 'test'" -c "quit"
```

**Solutions**:
```bash
# Reinstall LazyVim
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Update plugins
nvim --headless -c "Lazy sync" -c "quit"

# Check for errors
nvim --headless -c "checkhealth" -c "quit"
```

#### Configuration Conflicts
**Symptoms**: Custom settings not working

**Diagnosis**:
```bash
# Check config files
ls -la ~/.config/nvim/lua/

# Test configuration loading
nvim --headless -c "echo stdpath('config')" -c "quit"
```

**Solutions**:
```bash
# Add custom config
mkdir -p ~/.config/nvim/lua/custom
echo 'return {}' > ~/.config/nvim/lua/custom/init.lua

# Reload configuration
:source ~/.config/nvim/init.lua
```

### Git Integration Issues

#### Delta Not Working
**Symptoms**: Git diff not using delta

**Diagnosis**:
```bash
# Check delta installation
which delta && delta --version

# Check git config
git config --global core.pager

# Test delta
echo "test" | delta
```

**Solutions**:
```bash
# Configure git to use delta
git config --global core.pager delta
git config --global delta.side-by-side true

# Reinstall delta
brew reinstall git-delta
```

#### Lazygit Issues
**Symptoms**: Lazygit not launching or crashing

**Diagnosis**:
```bash
# Check installation
which lazygit && lazygit --version

# Check git repository
git status

# Test in different directory
cd /tmp && lazygit
```

**Solutions**:
```bash
# Reinstall lazygit
brew reinstall lazygit

# Check git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Dotfiles System Issues

### Synchronization Failures
**Symptoms**: Sync operations fail or conflict

**Diagnosis**:
```bash
# Check sync status
~/nexi/termkit/scripts/sync.sh status

# Check git status
cd ~/nexi/termkit/dotfiles && git status

# Check remote configuration
git remote -v
```

**Solutions**:
```bash
# Resolve conflicts manually
cd ~/nexi/termkit/dotfiles
git add <conflicted-file>
git commit -m "Resolve conflicts"

# Force sync (caution: may lose changes)
~/nexi/termkit/scripts/sync.sh --force sync

# Reinitialize dotfiles
rm -rf ~/nexi/termkit/dotfiles
~/nexi/termkit/install.sh  # Choose dotfiles option
```

### Symlink Issues
**Symptoms**: Configuration files not updating

**Diagnosis**:
```bash
# Check symlinks
ls -la ~/.bashrc
ls -la ~/.config/starship.toml

# Check target files
ls -la ~/nexi/termkit/dotfiles/config/
```

**Solutions**:
```bash
# Recreate symlinks
~/nexi/termkit/dotfiles/install.sh

# Manual symlink creation
ln -sf ~/nexi/termkit/dotfiles/config/bashrc ~/.bashrc

# Check permissions
chmod 644 ~/nexi/termkit/dotfiles/config/*
```

## Network and Download Issues

### Download Failures
**Symptoms**: Tools fail to download

**Diagnosis**:
```bash
# Check network connectivity
ping -c 3 github.com

# Check DNS resolution
nslookup github.com

# Test download manually
curl -I https://github.com/junegunn/fzf/releases/latest
```

**Solutions**:
```bash
# Use different mirror
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

# Manual download and install
wget <tool-url>
chmod +x <tool-binary>
sudo mv <tool-binary> /usr/local/bin/
```

### SSL Certificate Issues
**Symptoms**: SSL verification failures

**Diagnosis**:
```bash
# Check certificate
openssl s_client -connect github.com:443

# Check system certificates
curl -v https://github.com 2>&1 | grep "SSL certificate"
```

**Solutions**:
```bash
# Update certificates
brew install curl  # macOS
sudo apt install ca-certificates  # Ubuntu

# Disable SSL verification (not recommended)
export GIT_SSL_NO_VERIFY=1
```

## Platform-Specific Issues

### macOS Issues

#### Gatekeeper Blocks
**Symptoms**: macOS blocks unsigned applications

**Solutions**:
```bash
# Allow from unidentified developers
sudo spctl --master-disable

# Or allow specific app
sudo xattr -rd com.apple.quarantine /Applications/WezTerm.app
```

#### Homebrew Path Issues
**Symptoms**: Homebrew commands not found

**Solutions**:
```bash
# Add to PATH (Intel Mac)
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc

# Add to PATH (Apple Silicon)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

### Linux Issues

#### Package Manager Conflicts
**Symptoms**: Conflicts between Homebrew and system packages

**Solutions**:
```bash
# Use system packages where possible
sudo apt install neovim fzf ripgrep

# Set Homebrew PATH priority
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
```

#### Display Issues
**Symptoms**: GUI tools not displaying correctly

**Solutions**:
```bash
# Install display server
sudo apt install xorg

# Set display variable
export DISPLAY=:0

# Use text-based alternatives
# WezTerm → terminal, Browsh → lynx
```

### Windows (WSL) Issues

#### Path Translation Issues
**Symptoms**: Windows/WSL path conflicts

**Solutions**:
```bash
# Use WSL paths
cd /mnt/c/Users/YourName/

# Configure Windows Terminal
# Settings → Add profile → Ubuntu/WSL
```

#### Performance Issues
**Symptoms**: WSL running slowly

**Solutions**:
```bash
# Enable WSL2
wsl --set-version Ubuntu 2

# Configure memory limits
# %USERPROFILE%\.wslconfig
[wsl2]
memory=4GB
processors=2
```

## Advanced Troubleshooting

### Debug Mode
```bash
# Enable debug logging
export TERMKIT_DEBUG=1
~/nexi/termkit/install.sh

# Verbose verification
~/nexi/termkit/scripts/verify-installation.sh --verbose --debug

# Shell debug mode
set -x
source ~/.bashrc
set +x
```

### Log Analysis
```bash
# Search for errors
grep -i "error\|failed\|cannot" ~/.termkit-install.log

# Check recent logs
tail -f ~/.termkit-install.log

# System logs
dmesg | grep -i termkit
```

### Recovery Procedures

#### Complete Reinstallation
```bash
# Backup current setup
~/nexi/termkit/scripts/sync.sh backup

# Remove current installation
rm -rf ~/nexi/termkit
rm -rf ~/.config/termkit

# Fresh install
git clone <repo-url> ~/nexi/termkit
cd ~/nexi/termkit
./install.sh
```

#### Selective Component Repair
```bash
# Reinstall specific tool
brew reinstall <tool-name>

# Regenerate configuration
~/nexi/termkit/install.sh --reconfigure

# Restore from backup
cp ~/termkit-backup-*/bashrc ~/.bashrc
```

### Performance Profiling
```bash
# Profile shell startup
bash -c 'time source ~/.bashrc'

# Profile tool performance
time nvim --headless -c "quit"
time lazygit --help > /dev/null

# Memory profiling
/usr/bin/time -v source ~/.bashrc
```

## Getting Help

### Information to Provide
When reporting issues, include:
- TermKit version (`cat ~/nexi/termkit/VERSION`)
- Platform and OS version (`uname -a`)
- Installation log (`~/.termkit-install.log`)
- Verification output (`~/nexi/termkit/scripts/verify-installation.sh --report`)
- System information (`sysinfo`)

### Community Support
- Check existing issues on GitHub
- Search documentation and troubleshooting guides
- Provide detailed reproduction steps
- Include relevant log files

### Professional Support
For enterprise deployments:
- Contact support with system diagnostics
- Provide access logs and configuration files
- Schedule remote troubleshooting session
- Request custom deployment assistance

---

*This troubleshooting guide covers the most common issues encountered with TermKit. For additional help, check the GitHub repository or community forums.*</content>
<parameter name="filePath">/home/xnch/nexi/termkit/docs/TROUBLESHOOTING.md