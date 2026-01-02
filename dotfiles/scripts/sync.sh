#!/usr/bin/env bash

# TermKit Dotfiles Synchronization Script
# Handles multi-machine synchronization with conflict resolution

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
readonly REMOTE_NAME="${1:-origin}"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[SYNC]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SYNC]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[SYNC]${NC} $1"
}

log_error() {
    echo -e "${RED}[SYNC]${NC} $1"
}

# Check git repository status
check_repository_status() {
    cd "$DOTFILES_DIR"
    
    if [[ ! -d .git ]]; then
        log_error "Not a git repository"
        return 1
    fi
    
    log_info "Checking repository status..."
    
    # Check for uncommitted changes
    local status_output
    status_output=$(git status --porcelain 2>/dev/null)
    
    if [[ -n "$status_output" ]]; then
        log_warning "Uncommitted changes detected:"
        echo "$status_output"
        
        read -p "Commit changes before syncing? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Commit message: " -r
            git add -A
            git commit -m "$REPLY"
            log_success "Changes committed"
        else
            log_warning "Syncing with uncommitted changes may cause conflicts"
        fi
    fi
    
    # Check current branch
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null)
    log_info "Current branch: $current_branch"
    
    # Check remote status
    if git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
        log_info "Remote: $REMOTE_NAME ($(git remote get-url "$REMOTE_NAME"))"
    else
        log_warning "No remote '$REMOTE_NAME' found"
    fi
}

# Pull changes from remote
pull_changes() {
    log_info "Pulling changes from remote..."
    
    cd "$DOTFILES_DIR"
    
    # Fetch latest changes
    if git fetch "$REMOTE_NAME"; then
        log_success "Fetched changes from remote"
    else
        log_error "Failed to fetch from remote"
        return 1
    fi
    
    # Check if we need to pull
    local local_commit
    local remote_commit
    local_commit=$(git rev-parse HEAD 2>/dev/null)
    remote_commit=$(git rev-parse "$REMOTE_NAME/$(git branch --show-current)" 2>/dev/null)
    
    if [[ "$local_commit" != "$remote_commit" ]]; then
        log_info "Remote changes detected, pulling..."
        
        if git pull --rebase "$REMOTE_NAME"; then
            log_success "Changes pulled successfully"
        else
            log_error "Failed to pull changes"
            log_info "You may need to resolve conflicts manually"
            return 1
        fi
    else
        log_info "No new changes from remote"
    fi
}

# Push changes to remote
push_changes() {
    log_info "Pushing changes to remote..."
    
    cd "$DOTFILES_DIR"
    
    # Check if there's anything to push
    local local_commit
    local remote_commit
    local_commit=$(git rev-parse HEAD 2>/dev/null)
    remote_commit=$(git rev-parse "$REMOTE_NAME/$(git branch --show-current)" 2>/dev/null)
    
    if [[ "$local_commit" != "$remote_commit" ]] || [[ -n $(git status --porcelain) ]]; then
        if git push "$REMOTE_NAME"; then
            log_success "Changes pushed successfully"
        else
            log_error "Failed to push changes"
            log_info "Check network connection and permissions"
            return 1
        fi
    else
        log_info "No changes to push"
    fi
}

# Handle conflicts
handle_conflicts() {
    cd "$DOTFILES_DIR"
    
    # Check for merge conflicts
    if [[ -n $(git diff --name-only --diff-filter=U) ]]; then
        log_warning "Merge conflicts detected!"
        
        echo "Conflicting files:"
        git diff --name-only --diff-filter=U
        echo ""
        
        read -p "Launch editor to resolve conflicts? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Open conflict files in editor
            local conflict_files=($(git diff --name-only --diff-filter=U))
            
            if command -v nvim >/dev/null 2>&1; then
                nvim +/"git mergetool" "${conflict_files[@]}"
            elif command -v vim >/dev/null 2>&1; then
                vim +/"git mergetool" "${conflict_files[@]}"
            else
                log_error "No suitable editor found"
                return 1
            fi
        else
            log_info "Please resolve conflicts manually"
            log_info "Use 'git status' to see conflicting files"
            log_info "Use 'git add' and 'git commit' when resolved"
        fi
        
        return 1
    fi
    
    return 0
}

# Sync with conflict resolution
sync_with_resolution() {
    log_info "Starting synchronization with conflict resolution..."
    
    check_repository_status
    pull_changes
    
    if handle_conflicts; then
        log_success "All conflicts resolved"
    else
        log_warning "Conflicts remain, sync incomplete"
        return 1
    fi
    
    push_changes
    log_success "Synchronization completed"
}

# Quick sync (auto-resolve simple conflicts)
quick_sync() {
    log_info "Starting quick synchronization..."
    
    cd "$DOTFILES_DIR"
    
    # Auto-resolve simple conflicts (prefer local)
    if [[ -n $(git diff --name-only --diff-filter=U) ]]; then
        log_info "Auto-resolving simple conflicts (preferring local)..."
        
        # For each conflicted file, prefer local version
        git diff --name-only --diff-filter=U | while read -r file; do
            git checkout --ours "$file"
            git add "$file"
            log_info "Auto-resolved: $file (kept local version)"
        done
        
        git commit -m "Auto-resolve merge conflicts"
    fi
    
    # Pull changes
    if ! git pull --rebase "$REMOTE_NAME" --no-edit; then
        log_error "Quick sync failed, manual resolution needed"
        return 1
    fi
    
    # Push changes
    push_changes
}

# Show sync status
show_sync_status() {
    cd "$DOTFILES_DIR"
    
    log_info "Dotfiles synchronization status"
    echo "========================================"
    
    # Repository info
    echo "Repository: $DOTFILES_DIR"
    echo "Current branch: $(git branch --show-current)"
    echo "Current commit: $(git rev-parse --short HEAD)"
    echo ""
    
    # Remote info
    if git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
        echo "Remote: $REMOTE_NAME"
        echo "URL: $(git remote get-url "$REMOTE_NAME")"
        echo ""
        
        # Sync status
        local local_commit
        local remote_commit
        local_commit=$(git rev-parse HEAD 2>/dev/null)
        remote_commit=$(git rev-parse "$REMOTE_NAME/$(git branch --show-current)" 2>/dev/null)
        
        if [[ "$local_commit" == "$remote_commit" ]]; then
            echo "Status: ✓ Up to date"
        else
            echo "Status: ⚠ Local and remote differ"
            echo "Local:  $local_commit"
            echo "Remote:  $remote_commit"
        fi
    else
        echo "Remote: No remote '$REMOTE_NAME' configured"
    fi
    
    echo ""
    
    # Uncommitted changes
    local status_output
    status_output=$(git status --porcelain 2>/dev/null)
    if [[ -n "$status_output" ]]; then
        echo "Uncommitted changes:"
        echo "$status_output"
    else
        echo "Status: ✓ Working tree clean"
    fi
    
    echo "========================================"
}

# Show help
show_help() {
    cat << EOF
TermKit Dotfiles Synchronization Script

Usage: $0 [command] [options]

Commands:
  status              Show synchronization status
  push                Push local changes to remote
  pull                Pull changes from remote
  sync                Full synchronization (pull + push)
  quick-sync          Quick sync with auto-conflict resolution
  resolve             Interactive conflict resolution
  help                Show this help

Options:
  --remote <name>    Remote repository name (default: origin)

Examples:
  $0 status                  # Show sync status
  $0 sync                   # Full sync
  $0 quick-sync               # Quick sync
  $0 --remote upstream sync   # Sync with 'upstream' remote
EOF
}

# Parse arguments
COMMAND=""
for arg in "$@"; do
    case $arg in
        --remote)
            shift
            REMOTE_NAME="${1:-origin}"
            shift
            ;;
        status|push|pull|sync|quick-sync|resolve|help)
            COMMAND="$arg"
            shift
            ;;
        *)
            log_error "Unknown argument: $arg"
            show_help
            exit 1
            ;;
    esac
done

# Execute command
case "$COMMAND" in
    status)
        show_sync_status
        ;;
    push)
        check_repository_status
        push_changes
        ;;
    pull)
        check_repository_status
        pull_changes
        ;;
    sync)
        sync_with_resolution
        ;;
    quick-sync)
        quick_sync
        ;;
    resolve)
        check_repository_status
        pull_changes
        handle_conflicts
        if [[ $? -eq 0 ]]; then
            push_changes
        fi
        ;;
    help)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac