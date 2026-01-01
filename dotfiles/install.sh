#!/usr/bin/env bash

# TermKit Dotfiles Installer v3.0
# Manages version-controlled configuration files with symlinks
# Features: backup/restore, conflict resolution, multi-machine sync

set -euo pipefail

# ============================================================================
# Global Configuration
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$SCRIPT_DIR"
readonly BACKUP_DIR="$HOME/.termkit_dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
readonly OPERATIONS_LOG="$BACKUP_DIR/operations.log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Statistics
LINKED_COUNT=0
SKIPPED_COUNT=0
CONFLICT_COUNT=0
BACKED_UP_COUNT=0

# Track operations for rollback
OPERATIONS=()

# Parse arguments
DRY_RUN=false
FORCE_UPDATE=false
RESOLVE_CONFLICTS=false
SKIP_BACKUP=false

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --force-update)
            FORCE_UPDATE=true
            ;;
        --resolve-conflicts)
            RESOLVE_CONFLICTS=true
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            ;;
        --help|-h)
            cat << 'EOF'
TermKit Dotfiles Installer v3.0

Usage: $SCRIPT_NAME [options]

Options:
  --dry-run              Show what would be done without making changes
  --force-update         Force update existing symlinks
  --resolve-conflicts     Interactive conflict resolution
  --skip-backup         Skip backup of existing files
  --help, -h            Show this help message

Commands:
  status                 Show current dotfiles status
  sync                   Sync dotfiles with remote repository
  backup                  Create backup of current configurations
  restore <timestamp>     Restore from backup

Examples:
  $SCRIPT_NAME                    # Install dotfiles
  $SCRIPT_NAME --dry-run           # Preview installation
  $SCRIPT_NAME --resolve-conflicts # Interactive conflict resolution
  $SCRIPT_NAME status              # Show status
  $SCRIPT_NAME sync                 # Sync with remote

EOF
            exit 0
            ;;
        status)
            show_status
            exit 0
            ;;
        sync)
            sync_dotfiles
            exit 0
            ;;
        backup)
            create_backup
            exit 0
            ;;
        restore)
            if [[ -z "${2:-}" ]]; then
                echo "Error: Please provide backup timestamp"
                echo "Usage: $SCRIPT_NAME restore <timestamp>"
                exit 1
            fi
            restore_from_backup "$2"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_conflict() {
    echo -e "${MAGENTA}[CONFLICT]${NC} $1"
}

# Print section header
print_section() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo ""
}

# Log operation for potential rollback
log_operation() {
    local operation="$1"
    local details="$2"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Create operations log if needed
        if [[ ! -f "$OPERATIONS_LOG" ]]; then
            mkdir -p "$(dirname "$OPERATIONS_LOG")"
            echo "# Dotfiles Installation Operations Log" > "$OPERATIONS_LOG"
            echo "# Created: $(date)" >> "$OPERATIONS_LOG"
            echo "" >> "$OPERATIONS_LOG"
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S')|$operation|$details" >> "$OPERATIONS_LOG"
        OPERATIONS+=("$operation|$details")
    fi
}

# ============================================================================ 
# Conflict Resolution
# ============================================================================

resolve_conflict() {
    local src="$1"
    local dst="$2"
    local backup_path="$3"
    
    echo ""
    log_conflict "Conflict detected: $dst"
    echo ""
    echo "Source: $src"
    echo "Destination: $dst"
    echo "Backup: $backup_path"
    echo ""
    
    if [[ "$RESOLVE_CONFLICTS" == "false" ]]; then
        log_info "Use --resolve-conflicts for interactive resolution"
        return 1
    fi
    
    echo "Choose resolution:"
    echo "  1) Overwrite destination (backup existing)"
    echo "  2) Keep destination (skip linking)"
    echo "  3) Show diff"
    echo "  4) Edit destination"
    echo ""
    read -p "Choice [1-4]: " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            if [[ -f "$dst" ]] || [[ -L "$dst" ]]; then
                mv "$dst" "$backup_path"
                log_info "Backed up existing file to: $backup_path"
                ((BACKED_UP_COUNT++))
            fi
            return 0
            ;;
        2)
            log_warning "Skipping: $dst"
            ((SKIPPED_COUNT++))
            return 1
            ;;
        3)
            if command -v diff >/dev/null 2>&1; then
                if [[ -f "$src" ]] && [[ -f "$dst" ]]; then
                    diff -u "$dst" "$src" | less
                else
                    log_error "Cannot show diff - one of the files is not a regular file"
                fi
            else
                log_error "diff command not available"
            fi
            resolve_conflict "$src" "$dst" "$backup_path"
            ;;
        4)
            if command -v "${EDITOR:-vim}" >/dev/null 2>&1; then
                "${EDITOR:-vim}" "$dst"
            else
                log_error "Editor not available"
            fi
            resolve_conflict "$src" "$dst" "$backup_path"
            ;;
        *)
            log_error "Invalid choice"
            resolve_conflict "$src" "$dst" "$backup_path"
            ;;
    esac
}

# ============================================================================ 
# Symlink Management
# ============================================================================

create_symlink() {
    local src="$1"
    local dst="$2"
    local backup_path="$BACKUP_DIR/${dst#$HOME/}"
    
    # Create parent directory if needed
    local parent_dir
    parent_dir="$(dirname "$dst")"
    if [[ ! -d "$parent_dir" ]]; then
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$parent_dir"
            log_info "Created directory: $parent_dir"
        fi
    fi
    
    # Check if destination exists
    if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then
        # If it's already a symlink pointing to correct location, skip
        if [[ -L "$dst" ]]; then
            local current_target
            current_target="$(readlink "$dst")"
            if [[ "$current_target" == "$src" ]]; then
                log_info "Already linked: $(basename "$src") -> $dst"
                ((SKIPPED_COUNT++))
                return 0
            fi
        fi
        
        # Conflict resolution needed
        if [[ "$SKIP_BACKUP" == "false" ]] && [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$(dirname "$backup_path")"
        fi
        
        if ! resolve_conflict "$src" "$dst" "$backup_path"; then
            return 1
        fi
    fi
    
    # Create symlink
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would link: $(basename "$src") -> $dst"
        ((LINKED_COUNT++))
    else
        if ln -sf "$src" "$dst"; then
            log_success "Linked: $(basename "$src") -> $dst"
            log_operation "LINK" "$src:$dst"
            ((LINKED_COUNT++))
        else
            log_error "Failed to create symlink: $src -> $dst"
            return 1
        fi
    fi
}

# ============================================================================ 
# Dotfiles Management Functions
# ============================================================================

install_shell_configs() {
    print_section "Installing Shell Configurations"
    
    # Bash configuration
    if [[ -f "$DOTFILES_DIR/config/bashrc" ]]; then
        create_symlink "$DOTFILES_DIR/config/bashrc" "$HOME/.bashrc"
    fi
    
    # ZSH configuration (if exists)
    if [[ -f "$DOTFILES_DIR/config/zshrc" ]]; then
        create_symlink "$DOTFILES_DIR/config/zshrc" "$HOME/.zshrc"
    fi
    
    # Profile configuration
    if [[ -f "$DOTFILES_DIR/config/profile" ]]; then
        create_symlink "$DOTFILES_DIR/config/profile" "$HOME/.profile"
    fi
    
    # Bash aliases
    if [[ -f "$DOTFILES_DIR/config/bash_aliases" ]]; then
        create_symlink "$DOTFILES_DIR/config/bash_aliases" "$HOME/.bash_aliases"
    fi
}

install_git_configs() {
    print_section "Installing Git Configurations"
    
    # Git configuration
    if [[ -f "$DOTFILES_DIR/config/gitconfig" ]]; then
        create_symlink "$DOTFILES_DIR/config/gitconfig" "$HOME/.gitconfig"
    fi
    
    # Global gitignore
    if [[ -f "$DOTFILES_DIR/config/gitignore_global" ]]; then
        create_symlink "$DOTFILES_DIR/config/gitignore_global" "$HOME/.gitignore_global"
    fi
    
    # Configure git to use global ignore file
    if [[ -f "$HOME/.gitignore_global" ]] && [[ "$DRY_RUN" == "false" ]]; then
        git config --global core.excludesfile "$HOME/.gitignore_global" 2>/dev/null || true
    fi
}

install_editor_configs() {
    print_section "Installing Editor Configurations"
    
    # Vim configuration
    if [[ -f "$DOTFILES_DIR/config/vimrc" ]]; then
        create_symlink "$DOTFILES_DIR/config/vimrc" "$HOME/.vimrc"
    fi
    
    # NeoVim configuration
    if [[ -d "$DOTFILES_DIR/config/nvim" ]]; then
        create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
    fi
    
    # VS Code settings (if directory exists)
    if [[ -d "$DOTFILES_DIR/config/vscode" ]]; then
        local vscode_dir="$HOME/.config/Code/User"
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$vscode_dir"
        fi
        for file in "$DOTFILES_DIR/config/vscode"/*; do
            create_symlink "$file" "$vscode_dir/$(basename "$file")"
        done
    fi
}

install_terminal_configs() {
    print_section "Installing Terminal Configurations"
    
    # WezTerm configuration
    if [[ -f "$DOTFILES_DIR/config/wezterm.lua" ]]; then
        local wezterm_dir="$HOME/.config/wezterm"
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$wezterm_dir"
        fi
        create_symlink "$DOTFILES_DIR/config/wezterm.lua" "$wezterm_dir/wezterm.lua"
    fi
    
    # Starship configuration
    if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
        local starship_dir="$HOME/.config"
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$starship_dir"
        fi
        create_symlink "$DOTFILES_DIR/config/starship.toml" "$starship_dir/starship.toml"
    fi
    
    # Tmux configuration (if exists - even though not in main toolset)
    if [[ -f "$DOTFILES_DIR/config/tmux.conf" ]]; then
        create_symlink "$DOTFILES_DIR/config/tmux.conf" "$HOME/.tmux.conf"
    fi
}

install_application_configs() {
    print_section "Installing Application Configurations"
    
    # Link all config directory contents
    if [[ -d "$DOTFILES_DIR/config" ]]; then
        local config_dir="$HOME/.config"
        if [[ "$DRY_RUN" == "false" ]]; then
            mkdir -p "$config_dir"
        fi
        
        for item in "$DOTFILES_DIR/config"/*; do
            local basename_item
            basename_item="$(basename "$item")"
            
            # Skip already handled files
            case "$basename_item" in
                bashrc|zshrc|profile|bash_aliases|gitconfig|gitignore_global|vimrc|wezterm.lua|starship.toml|tmux.conf)
                    continue
                    ;;
            esac
            
            create_symlink "$item" "$config_dir/$basename_item"
        done
    fi
    
    # Link other dotfiles (starting with dot)
    for dotfile in "$DOTFILES_DIR"/.[^.]*; do
        local basename_file
        basename_file="$(basename "$dotfile")"
        
        # Skip special files and directories
        case "$basename_file" in
            .git|.gitignore|.DS_Store)
                    continue
                    ;;
        esac
        
        create_symlink "$dotfile" "$HOME/$basename_file"
    done
}

# ============================================================================ 
# Status and Sync Functions
# ============================================================================

show_status() {
    print_section "Dotfiles Status"
    
    echo "Dotfiles directory: $DOTFILES_DIR"
    echo "Home directory: $HOME"
    echo ""
    
    # Check linked files
    local linked_files=0
    local broken_links=0
    local unmanaged_files=0
    
    echo "Linked configuration files:"
    for config_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.gitconfig" "$HOME/.gitignore_global" "$HOME/.vimrc" "$HOME/.tmux.conf"; do
        if [[ -L "$config_file" ]]; then
            local target
            target="$(readlink "$config_file")"
            if [[ -e "$target" ]]; then
                echo "  ✓ $config_file -> $target"
                ((linked_files++))
            else
                echo "  ✗ $config_file -> $target (broken link)"
                ((broken_links++))
            fi
        elif [[ -e "$config_file" ]]; then
            echo "  ? $config_file (not managed by dotfiles)"
            ((unmanaged_files++))
        fi
    done
    
    echo ""
    echo "Summary:"
    echo "  Linked files: $linked_files"
    echo "  Broken links: $broken_links"
    echo "  Unmanaged files: $unmanaged_files"
    echo ""
    
    if [[ $broken_links -gt 0 ]]; then
        log_warning "Found $broken_links broken symlinks. Run with --force-update to fix."
    fi
}

sync_dotfiles() {
    print_section "Syncing Dotfiles with Remote Repository"
    
    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        log_error "Dotfiles directory is not a git repository"
        log_info "To initialize: cd $DOTFILES_DIR && git init"
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    
    # Check for uncommitted changes
    if [[ -n $(git status --porcelain) ]]; then
        echo "Uncommitted changes detected:"
        git status --short
        echo ""
        read -p "Commit changes before syncing? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add -A
            read -p "Commit message: " -r
            git commit -m "$REPLY"
        fi
    fi
    
    # Pull latest changes
    log_info "Pulling latest changes from remote..."
    if git pull --rebase; then
        log_success "Pull completed successfully"
    else
        log_error "Pull failed - please resolve conflicts manually"
        return 1
    fi
    
    # Push local changes
    log_info "Pushing local changes to remote..."
    if git push; then
        log_success "Push completed successfully"
    else
        log_error "Push failed - please check network configuration"
        return 1
    fi
    
    echo ""
    log_success "Dotfiles synchronization completed"
}

create_backup() {
    local backup_dir="$HOME/.termkit_dotfiles_backup_manual_$(date +%Y%m%d_%H%M%S)"
    
    print_section "Creating Manual Backup"
    
    mkdir -p "$backup_dir"
    
    # Backup all configuration files
    local config_files=(
        "$HOME/.bashrc"
        "$HOME/.zshrc" 
        "$HOME/.profile"
        "$HOME/.gitconfig"
        "$HOME/.gitignore_global"
        "$HOME/.vimrc"
        "$HOME/.tmux.conf"
    )
    
    local backed_up=0
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]] || [[ -d "$config_file" ]]; then
            local backup_path="$backup_dir/$(basename "$config_file")"
            if [[ -d "$config_file" ]]; then
                cp -r "$config_file" "$backup_path"
            else
                cp "$config_file" "$backup_path"
            fi
            echo "  Backed up: $(basename "$config_file")"
            ((backed_up++))
        fi
    done
    
    # Backup config directory
    if [[ -d "$HOME/.config" ]]; then
        cp -r "$HOME/.config" "$backup_dir/config"
        echo "  Backed up: .config directory"
        ((backed_up++))
    fi
    
    echo ""
    log_success "Manual backup created: $backup_dir"
    log_info "Files backed up: $backed_up"
}

restore_from_backup() {
    local backup_timestamp="$1"
    local backup_dir="$HOME/.termkit_dotfiles_backup_$backup_timestamp"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup directory not found: $backup_dir"
        return 1
    fi
    
    print_section "Restoring from Backup: $backup_timestamp"
    
    # Confirm restoration
    read -p "This will replace current configurations. Continue? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restoration cancelled"
        return 0
    fi
    
    local restored=0
    for item in "$backup_dir"/*; do
        local basename_item
        basename_item="$(basename "$item")"
        
        # Restore to home directory or .config
        if [[ "$basename_item" == "config" ]]; then
            if [[ -d "$HOME/.config" ]]; then
                mv "$HOME/.config" "$HOME/.config.backup_$(date +%Y%m%d_%H%M%S)"
            fi
            cp -r "$item" "$HOME/"
            echo "  Restored: .config directory"
        else
            if [[ -f "$HOME/$basename_item" ]] || [[ -d "$HOME/$basename_item" ]]; then
                mv "$HOME/$basename_item" "$HOME/$basename_item.backup_$(date +%Y%m%d_%H%M%S)"
            fi
            cp -r "$item" "$HOME/"
            echo "  Restored: $basename_item"
        fi
        
        ((restored++))
    done
    
    echo ""
    log_success "Restoration completed"
    log_info "Files restored: $restored"
}

# ============================================================================ 
# Rollback Functions
# ============================================================================

rollback_operations() {
    if [[ ! -f "$OPERATIONS_LOG" ]]; then
        log_error "No operations log found. Cannot rollback."
        return 1
    fi
    
    print_section "Rolling Back Operations"
    
    # Read operations in reverse order
    local reversed_operations=()
    while IFS='|' read -r timestamp op details; do
        # Skip comments and empty lines
        [[ "$timestamp" =~ ^# ]] && continue
        [[ -z "$timestamp" ]] && continue
        reversed_operations=("$timestamp|$op|$details" "${reversed_operations[@]}")
    done < "$OPERATIONS_LOG"
    
    local rollback_count=0
    for operation in "${reversed_operations[@]}"; do
        IFS='|' read -r timestamp op details <<< "$operation"
        
        case "$op" in
            LINK)
                IFS=':' read -r src dst <<< "$details"
                if [[ -L "$dst" ]]; then
                    rm "$dst"
                    log_info "Removed symlink: $dst"
                    ((rollback_count++)) || true
                fi
                ;;
            BACKUP)
                IFS=':' read -r original backup <<< "$details"
                if [[ -e "$backup" ]] && [[ ! -e "$original" ]]; then
                    mv "$backup" "$original"
                    log_info "Restored from backup: $original"
                    ((rollback_count++)) || true
                fi
                ;;
        esac
    done
    
    log_success "Rolled back $rollback_count operations"
}

# ============================================================================ 
# Main Installation Logic
# ============================================================================

main() {
    if [[ "$DRY_RUN" == "true" ]]; then
        print_section "Dotfiles Installation (DRY RUN)"
        log_warning "DRY RUN MODE: No files will be modified"
    else
        print_section "TermKit Dotfiles Installation v3.0"
        log_info "Dotfiles directory: $DOTFILES_DIR"
        if [[ "$SKIP_BACKUP" == "false" ]]; then
            log_info "Backup directory: $BACKUP_DIR"
        fi
    fi
    
    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        log_info "Please ensure the dotfiles directory exists and contains configuration files"
        exit 1
    fi
    
    # Initialize git repository if needed
    if [[ ! -d "$DOTFILES_DIR/.git" ]] && [[ "$DRY_RUN" == "false" ]]; then
        log_info "Initializing git repository in dotfiles directory..."
        cd "$DOTFILES_DIR"
        git init
        git add .
        git commit -m "Initial commit: TermKit dotfiles setup"
        log_success "Git repository initialized"
    fi
    
    # Create backup unless skipped
    if [[ "$SKIP_BACKUP" == "false" ]] && [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Creating operations log: $OPERATIONS_LOG"
    fi
    
    # Install configurations
    install_shell_configs
    install_git_configs
    install_editor_configs
    install_terminal_configs
    install_application_configs
    
    # Show summary
    print_section "Installation Summary"
    
    echo ""
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${MAGENTA}DRY RUN COMPLETE${NC}"
        echo ""
        echo "Would link: $LINKED_COUNT files"
        echo "Would skip: $SKIPPED_COUNT files (already linked or conflicts)"
        if [[ $CONFLICT_COUNT -gt 0 ]]; then
            echo "Would resolve: $CONFLICT_COUNT conflicts"
        fi
        echo ""
        log_info "Run without --dry-run to actually install:"
        echo "  $SCRIPT_NAME"
    else
        log_success "Files linked: $LINKED_COUNT"
        log_info "Files skipped: $SKIPPED_COUNT"
        
        if [[ $CONFLICT_COUNT -gt 0 ]]; then
            log_info "Conflicts resolved: $CONFLICT_COUNT"
        fi
        
        if [[ $BACKED_UP_COUNT -gt 0 ]]; then
            log_info "Files backed up: $BACKED_UP_COUNT"
            log_info "Backup location: $BACKUP_DIR"
            log_info "Operations log: $OPERATIONS_LOG"
        fi
        
        echo ""
        log_success "Dotfiles installation complete!"
        
        # Provide next steps
        echo ""
        echo "Next steps:"
        echo "  1. Restart your shell or run: source ~/.bashrc"
        echo "  2. Verify installation: $SCRIPT_NAME status"
        echo "  3. Sync with remote: $SCRIPT_NAME sync"
        echo "  4. Customize your dotfiles as needed"
        echo ""
    fi
}

# ============================================================================
# Script Entry Point
# ============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi