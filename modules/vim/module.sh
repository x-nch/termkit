#!/usr/bin/env bash
# modules/vim/module.sh — Vim configuration

MODULE_NAME="vim"
MODULE_DESC="Vim editor configuration"
MODULE_DEPS=()  # vim is optional

_VIM_CONF="${TERMKIT_ROOT}/dotfiles/config/vimrc"

module_install() {
    log_section "Module: vim"

    if ! command -v vim >/dev/null 2>&1; then
        log_warning "vim not found. Install it via your package manager, or skip this module."
        if ! prompt_yes_no "Install vim?" n; then
            log_info "Skipping vim install."
            return 0
        fi
        pm_install vim || return 1
    fi

    safe_copy "$_VIM_CONF" "$HOME/.vimrc"
    log_success "Vim module installed."
}

module_uninstall() {
    log_section "Uninstall: vim"
    safe_remove "$HOME/.vimrc"
    log_success "Vim config removed."
}

module_validate() {
    log_section "Validate: vim"
    local ok=0

    if ! command -v vim >/dev/null 2>&1; then
        log_warning "vim not installed, skipping."
        return 0
    fi

    if [[ -f "$HOME/.vimrc" ]]; then
        # vim -e -s -c 'quit' exits 0 if .vimrc loads cleanly
        if vim -u "$HOME/.vimrc" -e -s -c 'quit' 2>/dev/null; then
            log_success "vimrc loads without errors."
        else
            log_error "vimrc has errors."
            (( ok++ )) || true
        fi
    else
        log_warning "~/.vimrc not found."
    fi

    return "$ok"
}
