#!/usr/bin/env bash
# modules/git/module.sh — Git configuration module

MODULE_NAME="git"
MODULE_DESC="Git global config, aliases, and global gitignore"
MODULE_DEPS=("git")

_GIT_CONF="${TERMKIT_ROOT}/dotfiles/config"

module_install() {
    log_section "Module: git"
    require_commands git || { log_error "git is not installed."; return 1; }

    safe_copy "${_GIT_CONF}/gitconfig"         "$HOME/.gitconfig"
    safe_copy "${_GIT_CONF}/gitconfig_aliases"  "$HOME/.gitconfig_aliases"
    safe_copy "${_GIT_CONF}/gitignore_global"   "$HOME/.gitignore_global"

    # Wire the alias and ignore files into global config
    if ! is_dry_run; then
        git config --global core.excludesfile  "$HOME/.gitignore_global"
        git config --global include.path       "$HOME/.gitconfig_aliases"
    fi

    log_success "Git module installed."
}

module_uninstall() {
    log_section "Uninstall: git"
    safe_remove "$HOME/.gitconfig"
    safe_remove "$HOME/.gitconfig_aliases"
    safe_remove "$HOME/.gitignore_global"
    log_success "Git module uninstalled."
}

module_validate() {
    log_section "Validate: git"
    local ok=0

    if ! command -v git >/dev/null 2>&1; then
        log_warning "git not installed, skipping."
        return 0
    fi

    for f in "$HOME/.gitconfig" "$HOME/.gitignore_global"; do
        [[ -f "$f" ]] && log_success "Present: $f" || { log_warning "Missing: $f"; (( ok++ )) || true; }
    done

    if git config --global --list >/dev/null 2>&1; then
        log_success "git config parses cleanly."
    else
        log_error "git config --global --list failed."
        (( ok++ )) || true
    fi

    return "$ok"
}
