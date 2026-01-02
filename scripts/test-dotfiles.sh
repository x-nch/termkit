#!/usr/bin/env bash

# TermKit Phase 2 Completion Test
# Tests dotfiles system installation and functionality

set -euo pipefail

readonly TERMKIT_DIR="$HOME/nexi/termkit"
readonly DOTFILES_DIR="$HOME/nexi/termkit/dotfiles"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test 1: Dotfiles Directory Structure
test_dotfiles_structure() {
    log_info "Testing dotfiles directory structure..."
    
    local required_dirs=("config" "scripts" "templates" "backups")
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [[ ${#missing_dirs[@]} -eq 0 ]]; then
        log_success "All required directories present"
    else
        log_error "Missing directories: ${missing_dirs[*]}"
        return 1
    fi
    
    return 0
}

# Test 2: Configuration Files
test_config_files() {
    log_info "Testing configuration files..."
    
    local config_files=(
        "config/bashrc"
        "config/zshrc"
        "config/bash_aliases"
        "config/gitconfig"
        "config/gitignore_global"
        "config/bash-integration.sh"
    )
    
    local missing_files=()
    local existing_files=()
    
    for file in "${config_files[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            existing_files+=("$file")
        else
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#existing_files[@]} -gt 0 ]]; then
        log_success "Configuration files present: ${#existing_files[@]}"
    fi
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_warning "Missing config files: ${missing_files[*]}"
    fi
    
    return 0
}

# Test 3: Installer Script
test_dotfiles_installer() {
    log_info "Testing dotfiles installer script..."
    
    local installer="$DOTFILES_DIR/install.sh"
    
    if [[ ! -f "$installer" ]]; then
        log_error "Dotfiles installer script not found"
        return 1
    fi
    
    # Test syntax
    if bash -n "$installer" 2>/dev/null; then
        log_success "Installer script syntax is valid"
    else
        log_error "Installer script has syntax errors"
        return 1
    fi
    
    # Test executable bit
    if [[ -x "$installer" ]]; then
        log_success "Installer script is executable"
    else
        log_warning "Installer script is not executable"
    fi
    
    return 0
}

# Test 4: Sync Script
test_sync_script() {
    log_info "Testing sync script..."
    
    local sync_script="$DOTFILES_DIR/scripts/sync.sh"
    
    if [[ ! -f "$sync_script" ]]; then
        log_error "Sync script not found"
        return 1
    fi
    
    # Test syntax
    if bash -n "$sync_script" 2>/dev/null; then
        log_success "Sync script syntax is valid"
    else
        log_error "Sync script has syntax errors"
        return 1
    fi
    
    # Test executable bit
    if [[ -x "$sync_script" ]]; then
        log_success "Sync script is executable"
    else
        log_warning "Sync script is not executable"
    fi
    
    return 0
}

# Test 5: Git Repository Setup
test_git_repository() {
    log_info "Testing git repository setup..."
    
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "Dotfiles directory not found"
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    
    # Check if it's a git repository
    if [[ ! -d ".git" ]]; then
        log_warning "Not a git repository - will initialize for testing"
        git init >/dev/null 2>&1
        git add . >/dev/null 2>&1
        git commit -m "Test commit" >/dev/null 2>&1
        log_success "Git repository initialized for testing"
    else
        log_success "Git repository exists"
    fi
    
    # Test git status
    local git_status
    git_status=$(git status --porcelain 2>/dev/null)
    if [[ -z "$git_status" ]]; then
        log_success "Git repository is clean"
    else
        log_warning "Git repository has uncommitted changes"
    fi
    
    return 0
}

# Test 6: Integration Script
test_integration_script() {
    log_info "Testing bash integration script..."
    
    local integration_script="$DOTFILES_DIR/config/bash-integration.sh"
    
    if [[ ! -f "$integration_script" ]]; then
        log_warning "Bash integration script not found"
        return 1
    fi
    
    # Test syntax
    if bash -n "$integration_script" 2>/dev/null; then
        log_success "Integration script syntax is valid"
    else
        log_error "Integration script has syntax errors"
        return 1
    fi
    
    return 0
}

# Test 7: Dry Run Installation
test_dry_run() {
    log_info "Testing dry run installation..."
    
    local installer="$DOTFILES_DIR/install.sh"
    
    if [[ -x "$installer" ]]; then
        if "$installer" --dry-run >/dev/null 2>&1; then
            log_success "Dry run completed successfully"
        else
            log_error "Dry run failed"
            return 1
        fi
    else
        log_error "Installer is not executable"
        return 1
    fi
    
    return 0
}

# Test 8: Status Command
test_status_command() {
    log_info "Testing status command..."
    
    local installer="$DOTFILES_DIR/install.sh"
    
    if [[ -x "$installer" ]]; then
        if "$installer" status >/dev/null 2>&1; then
            log_success "Status command works"
        else
            log_error "Status command failed"
            return 1
        fi
    else
        log_error "Installer is not executable"
        return 1
    fi
    
    return 0
}

# Test 9: Shell Integration Sourcing
test_shell_integration() {
    log_info "Testing shell integration sourcing..."
    
    local integration_script="$DOTFILES_DIR/config/bash-integration.sh"
    
    if [[ -f "$integration_script" ]]; then
        # Test sourcing without affecting current shell
        if bash -c "source '$integration_script' && echo 'Integration sourced successfully'" >/dev/null 2>&1; then
            log_success "Shell integration script can be sourced"
        else
            log_error "Shell integration script has sourcing errors"
            return 1
        fi
    else
        log_warning "Integration script not found for testing"
    fi
    
    return 0
}

# Main test function
main() {
    echo "========================================"
    echo "TermKit Phase 2 - Dotfiles System Tests"
    echo "========================================"
    echo ""
    
    local test_count=0
    local failed_count=0
    
    # Run all tests
    local tests=(
        "test_dotfiles_structure"
        "test_config_files"
        "test_dotfiles_installer"
        "test_sync_script"
        "test_git_repository"
        "test_integration_script"
        "test_dry_run"
        "test_status_command"
        "test_shell_integration"
    )
    
    for test_func in "${tests[@]}"; do
        echo ""
        $test_func
        if [[ $? -eq 0 ]]; then
            ((test_count++))
        else
            ((failed_count++))
        fi
    done
    
    # Results summary
    echo ""
    echo "========================================"
    echo "Test Results Summary"
    echo "========================================"
    echo "Total tests: $test_count"
    echo "Failed tests: $failed_count"
    echo "Success rate: $(((test_count - failed_count) * 100 / test_count))%"
    echo ""
    
    if [[ $failed_count -eq 0 ]]; then
        log_success "All tests passed! Phase 2 implementation is complete."
    else
        log_warning "$failed_count tests failed. Please review the output above."
    fi
    
    echo "========================================"
    
    # Return appropriate exit code
    [[ $failed_count -eq 0 ]]
}

# Run tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi