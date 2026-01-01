#!/usr/bin/env bash

# TermKit Installation Verification Script
# Verifies that all tools are installed and configured correctly

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Statistics
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Logging functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_section() {
    echo -e "\n${YELLOW}>>> $1${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((PASSED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    ((WARNING_CHECKS++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((FAILED_CHECKS++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check function
check_tool() {
    local tool_name="$1"
    local command_name="${2:-$tool_name}"
    local description="${3:-}"
    
    ((TOTAL_CHECKS++))
    
    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "$tool_name is installed"
        if [[ -n "$description" ]]; then
            print_info "  $description"
        fi
    else
        print_error "$tool_name is NOT installed"
        if [[ -n "$description" ]]; then
            print_info "  $description"
        fi
    fi
}

# Check configuration file
check_config() {
    local config_path="$1"
    local config_name="$2"
    
    ((TOTAL_CHECKS++))
    
    if [[ -f "$config_path" ]]; then
        print_success "$config_name exists"
        if [[ -s "$config_path" ]]; then
            print_info "  Configuration file is not empty"
        else
            print_warning "$config_name exists but is empty"
        fi
    else
        print_error "$config_name does NOT exist"
    fi
}

# Test shell integration
test_shell_integration() {
    ((TOTAL_CHECKS++))
    
    if [[ -f "$HOME/.config/termkit/bash-integration.sh" ]]; then
        if grep -q "termkit" "$HOME/.bashrc" 2>/dev/null; then
            print_success "Shell integration is configured"
        else
            print_error "Shell integration not added to .bashrc"
        fi
    else
        print_error "Shell integration script does NOT exist"
    fi
}

# Test keyboard bindings
test_key_bindings() {
    ((TOTAL_CHECKS++))
    
    # Test if fzf key bindings are available
    if command -v fzf >/dev/null 2>&1; then
        if [[ -f ~/.fzf.bash ]]; then
            print_success "fzf key bindings are available"
        else
            print_warning "fzf key bindings may not be configured"
        fi
    else
        print_error "fzf not available for key bindings"
    fi
}

# Main verification
main() {
    print_header "TermKit Installation Verification v3.0"
    print_info "Checking installation of 30+ tools and configurations..."
    
    # Phase 1: Core Tools
    print_section "Checking Core Tools"
    check_tool "WezTerm" "wezterm" "Terminal emulator with GPU acceleration"
    check_tool "Starship" "starship" "Fast, minimal shell prompt"
    check_tool "NeoVim" "nvim" "Modern Vim-based text editor"
    check_tool "btop" "btop" "Beautiful system monitor"
    check_tool "Browsh" "browsh" "Text-based web browser"
    
    # Phase 2: Essential CLI Tools
    print_section "Checking Essential CLI Tools"
    check_tool "fzf" "fzf" "Fuzzy finder for command line"
    check_tool "ripgrep" "rg" "Fast code search tool"
    check_tool "fd" "fd" "Fast file finder"
    check_tool "bat" "bat" "Syntax highlighted cat"
    check_tool "eza" "eza" "Modern ls replacement"
    check_tool "zoxide" "zoxide" "Smart directory jumper"
    
    # Phase 3: Git & Data Tools
    print_section "Checking Git & Data Tools"
    check_tool "lazygit" "lazygit" "Git TUI interface"
    check_tool "git-delta" "delta" "Better git diffs"
    check_tool "jq" "jq" "JSON processor"
    check_tool "jless" "jless" "Interactive JSON viewer"
    check_tool "xh" "xh" "HTTP client for terminal"
    
    # Phase 4: File & Process Tools
    print_section "Checking File & Process Tools"
    check_tool "yazi" "yazi" "Terminal file manager"
    check_tool "procs" "procs" "Modern ps replacement"
    check_tool "sd" "sd" "Find and replace alternative to sed"
    check_tool "choose" "choose" "Cut alternative for modern shells"
    
    # Phase 5: DevOps Tools (Optional)
    print_section "Checking DevOps Tools (Optional)"
    check_tool "lazydocker" "lazydocker" "Docker TUI"
    check_tool "k9s" "k9s" "Kubernetes TUI"
    
    # Phase 6: Utility Tools
    print_section "Checking Utility Tools"
    check_tool "doggo" "doggo" "Modern DNS tool"
    check_tool "glow" "glow" "Markdown renderer"
    check_tool "tealdeer" "tldr" "TLDR pages"
    check_tool "difftastic" "difft" "Structural diff tool"
    check_tool "jqp" "jqp" "Interactive JSON processor"
    
    # Configuration Files Check
    print_section "Checking Configuration Files"
    check_config "$HOME/.config/starship.toml" "Starship configuration"
    check_config "$HOME/.config/wezterm/wezterm.lua" "WezTerm configuration"
    check_config "$HOME/.config/nvim" "NeoVim configuration"
    check_config "$HOME/.config/btop/btop.conf" "btop configuration"
    check_config "$HOME/.gitconfig" "Git configuration"
    check_config "$HOME/.gitignore_global" "Global gitignore"
    
    # Shell Integration Check
    print_section "Checking Shell Integration"
    test_shell_integration
    test_key_bindings
    
    # Test Enhanced Features
    print_section "Checking Enhanced Features"
    
    ((TOTAL_CHECKS++))
    if [[ -n "${EDITOR:-}" ]]; then
        print_success "EDITOR is set to: $EDITOR"
    else
        print_error "EDITOR is not set"
    fi
    
    ((TOTAL_CHECKS++))
    if [[ -n "${FZF_DEFAULT_COMMAND:-}" ]]; then
        print_success "FZF_DEFAULT_COMMAND is configured"
    else
        print_warning "FZF_DEFAULT_COMMAND is not set"
    fi
    
    # Font Check
    print_section "Checking Fonts"
    ((TOTAL_CHECKS++))
    if fc-list | grep -i "jetbrains.*mono.*nerd" >/dev/null 2>&1; then
        print_success "JetBrains Mono Nerd Font is installed"
    else
        print_warning "JetBrains Mono Nerd Font not found"
    fi
    
    # Performance Check
    print_section "Performance Check"
    ((TOTAL_CHECKS++))
    local used_memory
    used_memory=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}' 2>/dev/null || echo "N/A")
    if [[ "$used_memory" != "N/A" ]] && [[ $used_memory -lt 80 ]]; then
        print_success "Memory usage: ${used_memory}% (good)"
    elif [[ "$used_memory" != "N/A" ]]; then
        print_warning "Memory usage: ${used_memory}% (high)"
    else
        print_info "Memory usage: N/A (could not determine)"
    fi
    
    # Test functions
    print_section "Testing Custom Functions"
    
    ((TOTAL_CHECKS++))
    if declare -f fe >/dev/null 2>&1; then
        print_success "fe function is available"
    else
        print_warning "fe function not loaded"
    fi
    
    ((TOTAL_CHECKS++))
    if declare -f fcd >/dev/null 2>&1; then
        print_success "fcd function is available"
    else
        print_warning "fcd function not loaded"
    fi
    
    ((TOTAL_CHECKS++))
    if declare -f rge >/dev/null 2>&1; then
        print_success "rge function is available"
    else
        print_warning "rge function not loaded"
    fi
    
    # Summary
    print_header "Verification Summary"
    echo -e "${BLUE}Total Checks:${NC} $TOTAL_CHECKS"
    echo -e "${GREEN}Passed:${NC} $PASSED_CHECKS"
    echo -e "${YELLOW}Warnings:${NC} $WARNING_CHECKS"
    echo -e "${RED}Failed:${NC} $FAILED_CHECKS"
    echo ""
    
    local success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    if [[ $success_rate -ge 80 ]]; then
        print_success "Installation verification PASSED ($success_rate%)"
    elif [[ $success_rate -ge 60 ]]; then
        print_warning "Installation verification PARTIAL ($success_rate%)"
    else
        print_error "Installation verification FAILED ($success_rate%)"
    fi
    
    echo ""
    print_info "Next Steps:"
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        echo "  • Fix failed installations"
        echo "  • Run installation script again: ~/nexi/termkit/install.sh"
    fi
    if [[ $WARNING_CHECKS -gt 0 ]]; then
        echo "  • Address warnings for optimal experience"
    fi
    echo "  • Restart shell: source ~/.bashrc"
    echo "  • Test tools: Try 'lg', 'fe', 'rge pattern'"
    echo ""
}

# Run verification
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi