#!/usr/bin/env bash

# TermKit Validation Script
# Comprehensive validation and syntax checking for TermKit configurations

set -euo pipefail

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TERMKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly ERROR_COUNT=0
readonly WARNING_COUNT=0

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global counters
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
    ((VALIDATION_WARNINGS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $*"
    ((VALIDATION_ERRORS++))
}

log_section() {
    echo
    echo -e "${CYAN}=== $* ===${NC}"
    echo
}

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

file_exists() {
    [[ -f "$1" ]]
}

dir_exists() {
    [[ -d "$1" ]]
}

is_executable() {
    [[ -x "$1" ]]
}

# Shell script validation
validate_shell_script() {
    local script_file="$1"
    local shell_type="${2:-bash}"
    
    log_info "Validating shell script: $script_file"
    
    if ! file_exists "$script_file"; then
        log_error "Script file not found: $script_file"
        return 1
    fi
    
    # Check shebang
    local shebang
    shebang=$(head -n1 "$script_file")
    if [[ ! "$shebang" =~ ^#! ]]; then
        log_warning "Missing shebang in: $script_file"
    fi
    
    # Check for required security patterns
    if ! grep -q "set -euo pipefail" "$script_file"; then
        log_warning "Missing 'set -euo pipefail' in: $script_file"
    fi
    
    # Syntax validation
    if command_exists "$shell_type"; then
        if "$shell_type" -n "$script_file" 2>/dev/null; then
            log_success "Syntax validation passed: $script_file"
            return 0
        else
            log_error "Syntax validation failed: $script_file"
            return 1
        fi
    else
        log_warning "$shell_type not available for validation: $script_file"
        return 0
    fi
}

# Validate all shell scripts
validate_shell_scripts() {
    log_section "Shell Script Validation"
    
    local shell_scripts=(
        "$TERMKIT_ROOT/install.sh"
        "$TERMKIT_ROOT/dotfiles/install.sh"
        "$TERMKIT_ROOT/scripts/validate.sh"
    )
    
    for script in "${shell_scripts[@]}"; do
        if file_exists "$script"; then
            validate_shell_script "$script"
        else
            log_warning "Script not found: $script"
        fi
    done
    
    # Validate configuration scripts
    local config_scripts=(
        "$TERMKIT_ROOT/dotfiles/config/bashrc"
        "$TERMKIT_ROOT/dotfiles/config/zshrc"
        "$TERMKIT_ROOT/dotfiles/config/profile"
        "$TERMKIT_ROOT/dotfiles/config/bash_aliases"
    )
    
    for script in "${config_scripts[@]}"; do
        if file_exists "$script"; then
            validate_shell_script "$script" "bash"
        else
            log_warning "Configuration script not found: $script"
        fi
    done
}

# Configuration file validation
validate_starship_config() {
    local config_file="${1:-$HOME/.config/starship.toml}"
    
    log_info "Validating Starship configuration: $config_file"
    
    if ! file_exists "$config_file"; then
        log_warning "Starship config not found: $config_file"
        return 1
    fi
    
    if ! command_exists starship; then
        log_warning "Starship not installed, skipping validation"
        return 0
    fi
    
    # Check TOML syntax if toml command is available
    if command_exists toml; then
        if toml < "$config_file" >/dev/null 2>&1; then
            log_success "TOML syntax valid: $config_file"
        else
            log_error "Invalid TOML syntax: $config_file"
            return 1
        fi
    else
        # Basic structure validation
        if grep -q "format" "$config_file" 2>/dev/null; then
            log_success "Basic Starship config structure valid: $config_file"
        else
            log_warning "Starship config may have minimal structure: $config_file"
        fi
    fi
    
    # Use starship's built-in validation
    if starship config --status >/dev/null 2>&1; then
        log_success "Starship configuration valid"
    else
        log_error "Starship configuration validation failed"
        return 1
    fi
}

validate_wezterm_config() {
    local config_file="${1:-$HOME/.config/wezterm/wezterm.lua}"
    
    log_info "Validating WezTerm configuration: $config_file"
    
    if ! file_exists "$config_file"; then
        log_warning "WezTerm config not found: $config_file"
        return 1
    fi
    
    if ! command_exists wezterm; then
        log_warning "WezTerm not installed, skipping validation"
        return 0
    fi
    
    # Use wezterm's built-in validation
    if wezterm --check-config "$config_file" >/dev/null 2>&1; then
        log_success "WezTerm configuration valid"
    else
        log_error "WezTerm configuration validation failed"
        return 1
    fi
}

validate_git_config() {
    local config_file="${1:-$HOME/.gitconfig}"
    
    log_info "Validating Git configuration: $config_file"
    
    if ! file_exists "$config_file"; then
        log_warning "Git config not found: $config_file"
        return 1
    fi
    
    if ! command_exists git; then
        log_warning "Git not installed, skipping validation"
        return 0
    fi
    
    # Test git configuration
    if git config --global --list >/dev/null 2>&1; then
        log_success "Git configuration valid"
    else
        log_error "Git configuration validation failed"
        return 1
    fi
    
    # Check for essential sections
    if ! grep -q "\[user\]" "$config_file" 2>/dev/null; then
        log_warning "Missing [user] section in git config"
    fi
    
    if ! grep -q "\[core\]" "$config_file" 2>/dev/null; then
        log_warning "Missing [core] section in git config"
    fi
}

validate_vim_config() {
    local config_file="${1:-$HOME/.vimrc}"
    
    log_info "Validating Vim configuration: $config_file"
    
    if ! file_exists "$config_file"; then
        log_warning "Vim config not found: $config_file"
        return 1
    fi
    
    if ! command_exists vim; then
        log_warning "Vim not installed, skipping validation"
        return 0
    fi
    
    # Test vim configuration by running vim in batch mode
    if vim -u "$config_file" -e -s -c 'qall' 2>/dev/null; then
        log_success "Vim configuration valid"
    else
        log_error "Vim configuration validation failed"
        return 1
    fi
}

validate_tmux_config() {
    local config_file="${1:-$HOME/.tmux.conf}"
    
    log_info "Validating Tmux configuration: $config_file"
    
    if ! file_exists "$config_file"; then
        log_warning "Tmux config not found: $config_file"
        return 1
    fi
    
    if ! command_exists tmux; then
        log_warning "Tmux not installed, skipping validation"
        return 0
    fi
    
    # Test tmux configuration
    if tmux source-file "$config_file" >/dev/null 2>&1; then
        log_success "Tmux configuration valid"
    else
        log_error "Tmux configuration validation failed"
        return 1
    fi
}

# Directory structure validation
validate_directory_structure() {
    log_section "Directory Structure Validation"
    
    local required_dirs=(
        "$TERMKIT_ROOT"
        "$TERMKIT_ROOT/dotfiles"
        "$TERMKIT_ROOT/dotfiles/config"
        "$TERMKIT_ROOT/scripts"
        "$TERMKIT_ROOT/docs"
    )
    
    for dir in "${required_dirs[@]}"; do
        if dir_exists "$dir"; then
            log_success "Directory exists: $(basename "$dir")"
        else
            log_error "Required directory missing: $dir"
        fi
    done
    
    # Check for executable permissions
    local executable_files=(
        "$TERMKIT_ROOT/install.sh"
        "$TERMKIT_ROOT/dotfiles/install.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if file_exists "$file"; then
            if is_executable "$file"; then
                log_success "File is executable: $(basename "$file")"
            else
                log_error "File not executable: $file"
            fi
        fi
    done
}

# Security validation
validate_security_patterns() {
    log_section "Security Validation"
    
    log_info "Checking for security vulnerabilities in shell scripts..."
    
    local shell_files=(
        "$TERMKIT_ROOT/install.sh"
        "$TERMKIT_ROOT/dotfiles/install.sh"
    )
    
    for file in "${shell_files[@]}"; do
        if file_exists "$file"; then
            # Check for dangerous patterns
            if grep -q "curl.*|.*bash" "$file" 2>/dev/null; then
                log_warning "Potential unsafe curl|bash pattern in: $file"
            fi
            
            if grep -q "wget.*|.*bash" "$file" 2>/dev/null; then
                log_warning "Potential unsafe wget|bash pattern in: $file"
            fi
            
            # Check for hash verification patterns
            if grep -q "sha256sum.*-c" "$file" 2>/dev/null; then
                log_success "Hash verification pattern found in: $file"
            else
                log_warning "Hash verification pattern not found in: $file"
            fi
        fi
    done
}

# Performance validation
validate_performance() {
    log_section "Performance Validation"
    
    log_info "Checking script startup times..."
    
    local script="$TERMKIT_ROOT/install.sh"
    if file_exists "$script"; then
        local start_time end_time duration
        start_time=$(date +%s%N)
        
        # Check script syntax (quick test)
        bash -n "$script" >/dev/null 2>&1
        
        end_time=$(date +%s%N)
        duration=$(((end_time - start_time) / 1000000)) # Convert to milliseconds
        
        if (( duration < 1000 )); then
            log_success "Script syntax check: ${duration}ms"
        else
            log_warning "Slow script syntax check: ${duration}ms"
        fi
    fi
}

# Integration validation
validate_integrations() {
    log_section "Integration Validation"
    
    # Check tool dependencies
    local tools=("git" "curl" "wget" "vim" "tmux")
    local optional_tools=("starship" "wezterm" "node" "python3")
    
    log_info "Checking required tools..."
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            log_success "$tool is available"
        else
            log_warning "$tool is not available"
        fi
    done
    
    log_info "Checking optional tools..."
    for tool in "${optional_tools[@]}"; do
        if command_exists "$tool"; then
            log_success "$tool is available"
        else
            log_info "$tool is not available (optional)"
        fi
    done
}

# Generate validation report
generate_report() {
    log_section "Validation Summary"
    
    echo -e "${BLUE}Validation Results:${NC}"
    echo -e "  ${GREEN}Passed: $((VALIDATION_ERRORS + VALIDATION_WARNINGS))${NC}"
    echo -e "  ${RED}Errors: $VALIDATION_ERRORS${NC}"
    echo -e "  ${YELLOW}Warnings: $VALIDATION_WARNINGS${NC}"
    echo
    
    if (( VALIDATION_ERRORS > 0 )); then
        echo -e "${RED}❌ Validation failed with $VALIDATION_ERRORS error(s)${NC}"
        return 1
    elif (( VALIDATION_WARNINGS > 0 )); then
        echo -e "${YELLOW}⚠️  Validation completed with $VALIDATION_WARNINGS warning(s)${NC}"
        return 0
    else
        echo -e "${GREEN}✅ All validations passed successfully${NC}"
        return 0
    fi
}

# Help function
show_help() {
    cat << EOF
TermKit Validation Script

Usage: $SCRIPT_NAME [options]

Options:
  --shell-only        Validate only shell scripts
  --config-only       Validate only configuration files
  --security-only     Validate only security patterns
  --quick            Run quick validation (skip performance tests)
  --help, -h         Show this help message

Examples:
  $SCRIPT_NAME                      # Run full validation
  $SCRIPT_NAME --quick              # Quick validation
  $SCRIPT_NAME --shell-only         # Validate shell scripts only

EOF
}

# Main validation function
run_full_validation() {
    log_section "Starting TermKit Validation"
    
    validate_directory_structure
    validate_shell_scripts
    validate_starship_config "$TERMKIT_ROOT/dotfiles/config/starship.toml"
    validate_wezterm_config "$TERMKIT_ROOT/dotfiles/config/wezterm.lua"
    validate_git_config "$TERMKIT_ROOT/dotfiles/config/gitconfig"
    validate_vim_config "$TERMKIT_ROOT/dotfiles/config/vimrc"
    validate_tmux_config "$TERMKIT_ROOT/dotfiles/config/tmux.conf"
    validate_security_patterns
    validate_performance
    validate_integrations
}

# Parse command line arguments
main() {
    local validation_type="full"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --shell-only)
                validation_type="shell"
                shift
                ;;
            --config-only)
                validation_type="config"
                shift
                ;;
            --security-only)
                validation_type="security"
                shift
                ;;
            --quick)
                validation_type="quick"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    case "$validation_type" in
        shell)
            validate_shell_scripts
            ;;
        config)
            log_section "Configuration Validation"
            validate_starship_config
            validate_wezterm_config
            validate_git_config
            validate_vim_config
            validate_tmux_config
            ;;
        security)
            validate_security_patterns
            ;;
        quick)
            log_section "Quick Validation"
            validate_directory_structure
            validate_shell_scripts
            validate_security_patterns
            ;;
        full|*)
            run_full_validation
            ;;
    esac
    
    generate_report
}

# Execute main function
main "$@"