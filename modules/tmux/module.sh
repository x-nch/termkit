#!/usr/bin/env bash
# modules/tmux/module.sh — Tmux terminal multiplexer configuration

MODULE_NAME="tmux"
MODULE_DESC="Tmux terminal multiplexer configuration"
MODULE_DEPS=()  # optional

_TMUX_CONF="${TERMKIT_ROOT}/dotfiles/config/tmux.conf"

module_install() {
    log_section "Module: tmux"

    if ! command -v tmux >/dev/null 2>&1; then
        log_warning "tmux not found."
        if ! prompt_yes_no "Install tmux?" n; then
            log_info "Skipping tmux install."
            return 0
        fi
        pm_install tmux || return 1
    fi

    safe_copy "$_TMUX_CONF" "$HOME/.tmux.conf"
    log_success "Tmux module installed."
}

module_uninstall() {
    log_section "Uninstall: tmux"
    safe_remove "$HOME/.tmux.conf"
    log_success "Tmux config removed."
}

module_validate() {
    log_section "Validate: tmux"
    local ok=0

    if ! command -v tmux >/dev/null 2>&1; then
        log_warning "tmux not installed, skipping."
        return 0
    fi

    if [[ -f "$HOME/.tmux.conf" ]]; then
        # tmux source-file validates syntax without launching a server
        if tmux -f "$HOME/.tmux.conf" new-session -d -s _termkit_check 2>/dev/null; then
            tmux kill-session -t _termkit_check 2>/dev/null || true
            log_success "tmux.conf loaded cleanly."
        else
            log_warning "tmux.conf may have errors (or no server available)."
        fi
    else
        log_warning "~/.tmux.conf not found."
        (( ok++ )) || true
    fi

    return "$ok"
}
