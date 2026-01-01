#!/usr/bin/env bash

# TermKit Dotfiles Installer
# Handles installation of configuration files with dry-run and validation

set -euo pipefail

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TERMKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly DRY_RUN=false
readonly BACKUP_DIR="$HOME/.termkit_dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Dry run mode detection
is_dry_run() {
    [[ "${DRY_RUN:-}" == "true" ]]
}

# Safe file operations with dry-run support
safe_link() {
    local source="$1"
    local target="$2"
    
    if is_dry_run; then
        log_info "[DRY-RUN] Would link: $source -> $target"
        return 0
    fi
    
    local target_dir
    target_dir="$(dirname "$target")"
    
    # Create target directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi
    
    # Backup existing target if it exists
    if [[ -e "$target" ]]; then
        local backup_target="$BACKUP_DIR/$(basename "$target")"
        mkdir -p "$(dirname "$backup_target")"
        mv "$target" "$backup_target"
        log_info "Backed up existing file: $target -> $backup_target"
    fi
    
    # Create symbolic link
    ln -sf "$source" "$target"
    log_success "Linked: $source -> $target"
}

safe_copy() {
    local source="$1"
    local target="$2"
    
    if is_dry_run; then
        log_info "[DRY-RUN] Would copy: $source -> $target"
        return 0
    fi
    
    local target_dir
    target_dir="$(dirname "$target")"
    
    # Create target directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi
    
    # Backup existing target if it exists
    if [[ -e "$target" ]]; then
        local backup_target="$BACKUP_DIR/$(basename "$target")"
        mkdir -p "$(dirname "$backup_target")"
        mv "$target" "$backup_target"
        log_info "Backed up existing file: $target -> $backup_target"
    fi
    
    # Copy file
    cp "$source" "$target"
    log_success "Copied: $source -> $target"
}

# Configuration validation
validate_shell_config() {
    local config_file="$1"
    
    if ! command -v bash >/dev/null 2>&1; then
        log_error "bash not found for shell validation"
        return 1
    fi
    
    if ! bash -n "$config_file" 2>/dev/null; then
        log_error "Syntax error in shell configuration: $config_file"
        return 1
    fi
    
    log_success "Validated shell configuration: $config_file"
    return 0
}

validate_starship_config() {
    local config_file="$1"
    
    if ! command -v starship >/dev/null 2>&1; then
        log_warning "starship not found, skipping validation"
        return 0
    fi
    
    if starship config --status >/dev/null 2>&1; then
        log_success "Validated Starship configuration: $config_file"
        return 0
    else
        log_error "Invalid Starship configuration: $config_file"
        return 1
    fi
}

validate_wezterm_config() {
    local config_file="$1"
    
    if ! command -v wezterm >/dev/null 2>&1; then
        log_warning "wezterm not found, skipping validation"
        return 0
    fi
    
    if wezterm --check-config "$config_file" >/dev/null 2>&1; then
        log_success "Validated WezTerm configuration: $config_file"
        return 0
    else
        log_error "Invalid WezTerm configuration: $config_file"
        return 1
    fi
}

# Dotfile installation functions
install_shell_configs() {
    log_info "Installing shell configurations..."
    
    local shell_configs=(
        "bashrc:.bashrc"
        "zshrc:.zshrc"
        "profile:.profile"
        "bash_aliases:.bash_aliases"
    )
    
    for config_pair in "${shell_configs[@]}"; do
        local source_file="${config_pair%:*}"
        local target_file="${config_pair#*:}"
        local source_path="$SCRIPT_DIR/config/$source_file"
        local target_path="$HOME/$target_file"
        
        if [[ -f "$source_path" ]]; then
            safe_copy "$source_path" "$target_path"
            validate_shell_config "$target_path" || log_warning "Validation failed for: $target_path"
        else
            log_warning "Source config not found: $source_path"
        fi
    done
}

install_starship_config() {
    log_info "Installing Starship configuration..."
    
    local source_path="$SCRIPT_DIR/config/starship.toml"
    local target_path="$HOME/.config/starship.toml"
    
    if [[ -f "$source_path" ]]; then
        safe_copy "$source_path" "$target_path"
        validate_starship_config "$target_path" || log_warning "Starship validation failed"
    else
        log_warning "Starship config not found: $source_path"
    fi
}

install_wezterm_config() {
    log_info "Installing WezTerm configuration..."
    
    local source_path="$SCRIPT_DIR/config/wezterm.lua"
    local target_path="$HOME/.config/wezterm/wezterm.lua"
    
    if [[ -f "$source_path" ]]; then
        safe_copy "$source_path" "$target_path"
        validate_wezterm_config "$target_path" || log_warning "WezTerm validation failed"
    else
        log_warning "WezTerm config not found: $source_path"
    fi
}

install_git_config() {
    log_info "Installing Git configuration..."
    
    local git_configs=(
        "gitconfig:.gitconfig"
        "gitignore:.gitignore_global"
    )
    
    for config_pair in "${git_configs[@]}"; do
        local source_file="${config_pair%:*}"
        local target_file="${config_pair#*:}"
        local source_path="$SCRIPT_DIR/config/$source_file"
        local target_path="$HOME/$target_file"
        
        if [[ -f "$source_path" ]]; then
            safe_copy "$source_path" "$target_path"
            
            # Configure git to use global ignore file
            if [[ "$target_file" == ".gitconfig" ]]; then
                if ! is_dry_run; then
                    git config --global core.excludesfile "$HOME/.gitignore_global"
                fi
            fi
        else
            log_warning "Git config not found: $source_path"
        fi
    done
}

install_vim_config() {
    log_info "Installing Vim configuration..."
    
    local source_path="$SCRIPT_DIR/config/vimrc"
    local target_path="$HOME/.vimrc"
    
    if [[ -f "$source_path" ]]; then
        safe_copy "$source_path" "$target_path"
    else
        log_warning "Vim config not found: $source_path"
    fi
    
    # Install vim plugins if .vim directory exists
    local vim_source_dir="$SCRIPT_DIR/config/vim"
    local vim_target_dir="$HOME/.vim"
    
    if [[ -d "$vim_source_dir" ]]; then
        if is_dry_run; then
            log_info "[DRY-RUN] Would sync vim config directory"
        else
            if [[ -d "$vim_target_dir" ]]; then
                local backup_vim="$BACKUP_DIR/vim"
                mv "$vim_target_dir" "$backup_vim"
                log_info "Backed up existing vim directory"
            fi
            cp -r "$vim_source_dir" "$vim_target_dir"
            log_success "Installed vim configuration directory"
        fi
    fi
}

install_tmux_config() {
    log_info "Installing Tmux configuration..."
    
    local source_path="$SCRIPT_DIR/config/tmux.conf"
    local target_path="$HOME/.tmux.conf"
    
    if [[ -f "$source_path" ]]; then
        safe_copy "$source_path" "$target_path"
    else
        log_warning "Tmux config not found: $source_path"
    fi
}

install_editor_configs() {
    log_info "Installing editor configurations..."
    
    # VS Code settings
    if [[ -d "$SCRIPT_DIR/config/vscode" ]]; then
        local vscode_dir="$HOME/.config/Code/User"
        if [[ -d "$vscode_dir" ]] || mkdir -p "$vscode_dir" 2>/dev/null; then
            safe_copy "$SCRIPT_DIR/config/vscode/settings.json" "$vscode_dir/settings.json"
            safe_copy "$SCRIPT_DIR/config/vscode/keybindings.json" "$vscode_dir/keybindings.json"
        else
            log_warning "VS Code directory not accessible"
        fi
    fi
    
    # Neovim config
    if [[ -d "$SCRIPT_DIR/config/nvim" ]]; then
        local nvim_dir="$HOME/.config/nvim"
        if is_dry_run; then
            log_info "[DRY-RUN] Would sync Neovim configuration"
        else
            if [[ -d "$nvim_dir" ]]; then
                local backup_nvim="$BACKUP_DIR/nvim"
                mv "$nvim_dir" "$backup_nvim"
                log_info "Backed up existing Neovim directory"
            fi
            cp -r "$SCRIPT_DIR/config/nvim" "$nvim_dir"
            log_success "Installed Neovim configuration"
        fi
    fi
}

# Security and hash verification
verify_remote_config() {
    local url="$1"
    local expected_hash="$2"
    local local_file="$3"
    
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl not available for remote config verification"
        return 1
    fi
    
    log_info "Downloading remote config: $url"
    
    if curl -fsSL "$url" > "$local_file"; then
        if echo "$expected_hash $local_file" | sha256sum -c - >/dev/null 2>&1; then
            log_success "Remote config verified successfully"
            return 0
        else
            log_error "Hash verification failed for remote config"
            rm -f "$local_file"
            return 1
        fi
    else
        log_error "Failed to download remote config: $url"
        return 1
    fi
}

# Installation orchestration
install_all_configs() {
    log_info "Starting dotfiles installation..."
    
    # Create backup directory if not in dry-run mode
    if ! is_dry_run; then
        mkdir -p "$BACKUP_DIR"
        log_info "Created backup directory: $BACKUP_DIR"
    fi
    
    # Install configurations
    install_shell_configs
    install_starship_config
    install_wezterm_config
    install_git_config
    install_vim_config
    install_tmux_config
    install_editor_configs
    
    if ! is_dry_run; then
        log_success "Dotfiles installation completed!"
        log_info "Backup location: $BACKUP_DIR"
    else
        log_success "[DRY-RUN] Dotfiles installation preview completed"
        log_info "No changes were made. Run without --dry-run to apply changes."
    fi
}

# Help and argument handling
display_help() {
    cat << EOF
TermKit Dotfiles Installer

Usage: $SCRIPT_NAME [options]

Options:
  --dry-run      Preview changes without applying them
  --validate     Validate existing configurations only
  --backup       Create backup of existing configurations
  --help, -h     Show this help message

Examples:
  $SCRIPT_NAME                # Install all dotfiles
  $SCRIPT_NAME --dry-run      # Preview installation
  $SCRIPT_NAME --validate     # Validate current configs

EOF
}

validate_existing_configs() {
    log_info "Validating existing configurations..."
    
    local configs=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.config/starship.toml"
        "$HOME/.config/wezterm/wezterm.lua"
    )
    
    local validation_failed=false
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            case "$config" in
                *.bashrc|*.zshrc|*.profile)
                    validate_shell_config "$config" || validation_failed=true
                    ;;
                *starship.toml)
                    validate_starship_config "$config" || validation_failed=true
                    ;;
                *wezterm.lua)
                    validate_wezterm_config "$config" || validation_failed=true
                    ;;
            esac
        else
            log_info "Configuration not found: $config"
        fi
    done
    
    if [[ "$validation_failed" == "true" ]]; then
        log_warning "Some configurations failed validation"
        return 1
    else
        log_success "All configurations validated successfully"
        return 0
    fi
}

create_backup() {
    log_info "Creating backup of existing configurations..."
    
    local backup_dir="$HOME/.termkit_manual_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    local configs=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.config/starship.toml"
        "$HOME/.config/wezterm/wezterm.lua"
        "$HOME/.gitconfig"
        "$HOME/.vimrc"
        "$HOME/.tmux.conf"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            local backup_path="$backup_dir/$(basename "$config")"
            mkdir -p "$(dirname "$backup_path")"
            cp "$config" "$backup_path"
            log_info "Backed up: $config -> $backup_path"
        fi
    done
    
    log_success "Manual backup created: $backup_dir"
}

# Main execution
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                export DRY_RUN=true
                log_info "Running in dry-run mode"
                shift
                ;;
            --validate)
                validate_existing_configs
                exit $?
                ;;
            --backup)
                create_backup
                exit 0
                ;;
            --help|-h)
                display_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                display_help
                exit 1
                ;;
        esac
    done
    
    # Run installation
    install_all_configs
}

# Execute main function
main "$@"