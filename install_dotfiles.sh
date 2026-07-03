#!/usr/bin/env bash
#
# Dotfiles Installation Script
#
# Purpose: Create symlinks from home directory to dotfiles repository
# Usage: ./install.sh [--dry-run]
# Idempotent: Safe to run multiple times
#
# Options:
#   --dry-run    Show what would be done without making changes
#
# Author: System Administration Team
# Last Modified: 2025-12-28
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
OPERATIONS_LOG="$BACKUP_DIR/operations.log"

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--dry-run]"
            exit 1
            ;;
    esac
done

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m' # No Color

# Statistics
LINKED_COUNT=0
SKIPPED_COUNT=0
BACKED_UP_COUNT=0

# Track if we've created backup dir
BACKUP_DIR_CREATED=false

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${BLUE}[SUCCESS]${NC} $1"
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

    if [[ "$DRY_RUN" == false ]]; then
        # Create operations log if needed
        if [[ ! -f "$OPERATIONS_LOG" ]]; then
            mkdir -p "$(dirname "$OPERATIONS_LOG")"
            echo "# Dotfiles Installation Operations Log" > "$OPERATIONS_LOG"
            echo "# Created: $(date)" >> "$OPERATIONS_LOG"
            echo "" >> "$OPERATIONS_LOG"
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S')|$operation|$details" >> "$OPERATIONS_LOG"
    fi
}

# Rollback all operations
rollback_operations() {
    if [[ ! -f "$OPERATIONS_LOG" ]]; then
        log_warn "No operations log found. Cannot rollback."
        return 1
    fi

    log_warn "Rolling back operations..."

    # Read operations in reverse order
    local operations=()
    while IFS='|' read -r timestamp op details; do
        # Skip comments and empty lines
        [[ "$timestamp" =~ ^# ]] && continue
        [[ -z "$timestamp" ]] && continue
        operations=("$timestamp|$op|$details" "${operations[@]}")
    done < "$OPERATIONS_LOG"

    local rollback_count=0
    for operation in "${operations[@]}"; do
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
    return 0
}

# Offer rollback on error
offer_rollback() {
    log_error "Installation failed!"
    echo ""

    if [[ -f "$OPERATIONS_LOG" ]]; then
        log_warn "Would you like to rollback changes? (yes/no)"
        read -p "> " -r response

        if [[ "$response" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
            rollback_operations
            log_success "Rollback complete"
        else
            log_info "Keeping partial installation. You can rollback later by inspecting:"
            echo "  Backup directory: $BACKUP_DIR"
            echo "  Operations log: $OPERATIONS_LOG"
        fi
    fi
}

# Link a file or directory from dotfiles to home directory
# Args:
#   $1: Source path (in dotfiles repo)
#   $2: Destination path (in home directory)
link_file() {
    local src="$1"
    local dst="$2"

    # Validate source exists
    if [[ ! -e "$src" ]]; then
        log_error "Source does not exist: $src"
        if [[ "$DRY_RUN" == false ]]; then
            offer_rollback
        fi
        return 1
    fi

    # Check if destination exists
    if [[ -e "$dst" || -L "$dst" ]]; then
        # If it's already a symlink pointing to the correct location, skip
        if [[ -L "$dst" ]]; then
            local current_target
            current_target="$(readlink "$dst")"
            if [[ "$current_target" == "$src" ]]; then
                log_info "Already linked: $(basename "$src")"
                ((SKIPPED_COUNT++)) || true
                return 0
            fi
        fi

        # Backup existing file/directory/symlink
        if [[ "$DRY_RUN" == true ]]; then
            log_warn "[DRY-RUN] Would backup: $dst"
            ((BACKED_UP_COUNT++)) || true
        else
            # Create parent directory if needed
            local parent_dir
            parent_dir="$(dirname "$dst")"
            if [[ ! -d "$parent_dir" ]]; then
                mkdir -p "$parent_dir"
                log_info "Created directory: $parent_dir"
            fi

            mkdir -p "$BACKUP_DIR"
            BACKUP_DIR_CREATED=true

            local relative_path="${dst#$HOME/}"
            local backup_path="$BACKUP_DIR/$relative_path"
            mkdir -p "$(dirname "$backup_path")"

            mv "$dst" "$backup_path" || {
                log_error "Failed to backup: $dst"
                offer_rollback
                return 1
            }
            log_operation "BACKUP" "$dst:$backup_path"
            log_warn "Backed up: $dst -> $backup_path"
            ((BACKED_UP_COUNT++)) || true
        fi
    fi

    # Create symlink
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would link: $(basename "$src") -> $dst"
        ((LINKED_COUNT++)) || true
    else
        # Create parent directory if needed (in case it doesn't exist yet)
        local parent_dir
        parent_dir="$(dirname "$dst")"
        if [[ ! -d "$parent_dir" ]]; then
            mkdir -p "$parent_dir"
            log_info "Created directory: $parent_dir"
        fi

        ln -s "$src" "$dst" || {
            log_error "Failed to create symlink: $src -> $dst"
            offer_rollback
            return 1
        }
        log_operation "LINK" "$src:$dst"
        log_info "Linked: $(basename "$src") -> $dst"
        ((LINKED_COUNT++)) || true
    fi
}

# ============================================================================
# Main Installation Logic
# ============================================================================

main() {
    if [[ "$DRY_RUN" == true ]]; then
        print_section "Dotfiles Installation (DRY RUN)"
        log_warn "DRY RUN MODE: No files will be modified"
    else
        print_section "Dotfiles Installation"
    fi

    log_info "Dotfiles directory: $DOTFILES_DIR"
    if [[ "$DRY_RUN" == false ]]; then
        log_info "Backup directory: $BACKUP_DIR"
    fi

    # Link shell configuration files
    print_section "Linking Shell Configuration"

    if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
        link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    fi

    if [[ -f "$DOTFILES_DIR/.bashrc" ]]; then
        link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    fi

    # Link git configuration
    print_section "Linking Git Configuration"

    if [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
        link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    fi

    if [[ -f "$DOTFILES_DIR/.gitignore_global" ]]; then
        link_file "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
    fi

    if [[ -f "$DOTFILES_DIR/.gitattributes" ]]; then
        link_file "$DOTFILES_DIR/.gitattributes" "$HOME/.gitattributes"
    fi

    # Link config directory contents
    print_section "Linking Config Directory"

    if [[ -d "$DOTFILES_DIR/config" ]]; then
        # Create ~/.config if it doesn't exist
        mkdir -p "$HOME/.config"

        # Link each subdirectory/file in config/
        for item in "$DOTFILES_DIR/config"/*; do
            if [[ -e "$item" ]]; then
                local basename_item
                basename_item="$(basename "$item")"
                link_file "$item" "$HOME/.config/$basename_item"
            fi
        done
    fi

    # Link other dotfiles (if any)
    print_section "Linking Other Dotfiles"

    for dotfile in "$DOTFILES_DIR"/.[^.]*; do
        # Skip special files and directories
        local basename_file
        basename_file="$(basename "$dotfile")"

        # Skip already processed files and special directories
        if [[ "$basename_file" == ".zshrc" ]] || \
           [[ "$basename_file" == ".bashrc" ]] || \
           [[ "$basename_file" == ".gitconfig" ]] || \
           [[ "$basename_file" == ".gitignore_global" ]] || \
           [[ "$basename_file" == ".gitattributes" ]] || \
           [[ "$basename_file" == ".git" ]] || \
           [[ "$basename_file" == ".gitignore" ]] || \
           [[ "$basename_file" == ".DS_Store" ]]; then
            continue
        fi

        if [[ -f "$dotfile" ]]; then
            link_file "$dotfile" "$HOME/$basename_file"
        fi
    done

    # Print summary
    print_section "Installation Summary"

    echo ""
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${MAGENTA}DRY RUN COMPLETE${NC}"
        echo ""
        echo "Would link: $LINKED_COUNT files"
        echo "Would skip: $SKIPPED_COUNT files (already linked)"
        if [[ $BACKED_UP_COUNT -gt 0 ]]; then
            echo "Would backup: $BACKED_UP_COUNT files"
        fi
        echo ""
        log_info "Run without --dry-run to actually install:"
        echo "  ./install.sh"
    else
        log_success "Files linked: $LINKED_COUNT"
        log_info "Files skipped (already linked): $SKIPPED_COUNT"

        if [[ $BACKED_UP_COUNT -gt 0 ]]; then
            log_warn "Files backed up: $BACKED_UP_COUNT"
            log_warn "Backup location: $BACKUP_DIR"
            log_info "Operations log: $OPERATIONS_LOG"
        fi

        echo ""
        log_success "Dotfiles installation complete!"

        # Provide next steps
        echo ""
        echo "Next steps:"
        echo "  1. Restart your shell or run: source ~/.zshrc"
        echo "  2. Verify installation: ./verify-installation.sh"
        echo "  3. Customize your dotfiles as needed"
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
