#!/usr/bin/env bash

# TermKit Dotfiles Shell Integration
# Version-controlled configuration files from ~/nexi/termkit/dotfiles/

# ============================================
# Tool Detection & Initialization
# ============================================

# Source the main TermKit integration
if [[ -f "$HOME/.config/termkit/bash-integration.sh" ]]; then
    source "$HOME/.config/termkit/bash-integration.sh"
fi

# ============================================
# Dotfiles-Specific Settings
# ============================================

# Environment for dotfiles management
export DOTFILES_DIR="$HOME/nexi/termkit/dotfiles"
export TERMKIT_CONFIG="$HOME/.config/termkit"

# Git repository information
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    cd "$DOTFILES_DIR"
    export DOTFILES_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    export DOTFILES_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    export DOTFILES_STATUS=$(git status --porcelain 2>/dev/null || echo "unknown")
    cd - >/dev/null
fi

# ============================================
# Dotfiles Management Functions
# ============================================

# Quick status check
dotfiles() {
    echo "TermKit Dotfiles Status:"
    echo "  Directory: $DOTFILES_DIR"
    
    if [[ -n "${DOTFILES_BRANCH:-}" ]]; then
        echo "  Branch: $DOTFILES_BRANCH"
        echo "  Commit: $DOTFILES_COMMIT"
        echo "  Status: $DOTFILES_STATUS"
    fi
    
    echo ""
    echo "Available commands:"
    echo "  dotfiles status    - Show current status"
    echo "  dotfiles sync      - Sync with remote repository"
    echo "  dotfiles add      - Add changes to git"
    echo "  dotfiles commit    - Commit changes"
    echo "  dotfiles push      - Push changes to remote"
    echo "  dotfiles pull      - Pull changes from remote"
    echo "  dotfiles edit     - Edit dotfiles directory"
    echo "  dotfiles reload    - Reload shell with latest configs"
}

# Edit dotfiles
dotfiles-edit() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        ${EDITOR:-nvim} "$DOTFILES_DIR"
    else
        echo "Dotfiles directory not found: $DOTFILES_DIR"
        return 1
    fi
}

# Sync dotfiles with remote
dotfiles-sync() {
    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        echo "Dotfiles directory is not a git repository"
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    
    # Check for local changes
    if [[ -n $(git status --porcelain) ]]; then
        echo "Local changes detected:"
        git status --short
        echo ""
        read -p "Commit local changes before syncing? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add -A
            read -p "Commit message: " -r
            git commit -m "$REPLY"
        fi
    fi
    
    # Pull latest changes
    echo "Pulling latest changes from remote..."
    git pull --rebase
    
    # Push local changes
    echo "Pushing local changes to remote..."
    git push
    
    cd - >/dev/null
    echo "Dotfiles synchronization complete"
}

# Reload shell with latest configs
dotfiles-reload() {
    echo "Reloading shell with latest configurations..."
    exec bash
}

# Enhanced functions for dotfiles workflow
# Quick add and commit
dotfiles-add() {
    if [[ -z "$1" ]]; then
        echo "Usage: dotfiles add <file_pattern>"
        echo "Examples:"
        echo "  dotfiles add .bashrc"
        echo "  dotfiles add config/*.sh"
        echo "  dotfiles add config/"
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    git add "$1"
    echo "Added to git: $1"
    cd - >/dev/null
}

# Quick commit with message
dotfiles-commit() {
    local message="${1:-Update configurations}"
    
    cd "$DOTFILES_DIR"
    
    if [[ -z $(git status --porcelain) ]]; then
        echo "No changes to commit"
        return 0
    fi
    
    git add -A
    git commit -m "$message"
    echo "Committed: $message"
    cd - >/dev/null
}

# Push changes to remote
dotfiles-push() {
    cd "$DOTFILES_DIR"
    git push
    echo "Changes pushed to remote"
    cd - >/dev/null
}

# Pull changes from remote
dotfiles-pull() {
    cd "$DOTFILES_DIR"
    git pull --rebase
    echo "Changes pulled from remote"
    cd - >/dev/null
}

# Status of dotfiles repository
dotfiles-status() {
    if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
        echo "Dotfiles directory is not a git repository"
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    echo "Dotfiles Repository Status:"
    echo "========================="
    echo ""
    
    # Git status
    git status
    echo ""
    
    # Remote status
    echo "Remote branches:"
    git branch -r
    echo ""
    
    # Recent commits
    echo "Recent commits:"
    git log --oneline -5
    echo ""
    
    cd - >/dev/null
}

# Create backup of current dotfiles
dotfiles-backup() {
    local backup_name="dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_dir="$HOME/$backup_name"
    
    echo "Creating backup: $backup_name"
    
    mkdir -p "$backup_dir"
    
    # Backup current configurations
    for config_file in "$HOME"/.bashrc "$HOME"/.zshrc "$HOME"/.profile "$HOME"/.gitconfig; do
        if [[ -f "$config_file" ]]; then
            cp "$config_file" "$backup_dir/"
            echo "  Backed up: $(basename "$config_file)"
        fi
    done
    
    # Backup config directory
    if [[ -d "$HOME/.config" ]]; then
        cp -r "$HOME/.config" "$backup_dir/config"
        echo "  Backed up: .config directory"
    fi
    
    echo "Backup created: $backup_dir"
}

# ============================================
# Aliases for Dotfiles Management
# ============================================

alias dfs='dotfiles-status'
alias dfsync='dotfiles-sync'
alias dfe='dotfiles-edit'
alias dfr='dotfiles-reload'
alias dfadd='dotfiles-add'
alias dfcommit='dotfiles-commit'
alias dfpush='dotfiles-push'
alias dfpull='dotfiles-pull'
alias dfbackup='dotfiles-backup'

# ============================================
# Customization Point
# ============================================

# Source local dotfiles customizations if they exist
if [[ -f "$HOME/.config/termkit/dotfiles-custom.sh" ]]; then
    source "$HOME/.config/termkit/dotfiles-custom.sh"
fi

# ============================================
# Prompt Enhancement (if dotfiles version info available)
# ============================================

# Add dotfiles status to prompt if changes exist
if command -v starship &>/dev/null && [[ -n "${DOTFILES_STATUS:-}" ]]; then
    if [[ "$DOTFILES_STATUS" != "unknown" ]] && [[ -n "$DOTFILES_STATUS" ]]; then
        # Add a visual indicator if there are uncommitted changes
        if [[ -n "$(echo "$DOTFILES_STATUS" | tr -d ' \n')" ]]; then
            export DOTFILES_DIRTY="true"
        else
            export DOTFILES_DIRTY="false"
        fi
    fi
fi

# ============================================
# Completion for dotfiles command
# ============================================

_dotfiles_completion() {
    local cur prev words
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case "$prev" in
        dotfiles|dfs)
            COMPREPLY=($(compgen -W "status sync edit reload add commit push pull backup" -- "$cur"))
            ;;
    esac
}

if command -v complete >/dev/null 2>&1; then
    complete -F _dotfiles_completion dotfiles
    complete -F _dotfiles_completion dfs
fi