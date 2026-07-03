#!/usr/bin/env bash
# modules/shell/module.sh — Shell configuration module
#
# Manages: bashrc, zshrc, profile, bash_aliases
# plus the shared shell/ utility layer (env, functions, aliases).

MODULE_NAME="shell"
MODULE_DESC="Bash / Zsh shell configuration and shared utilities"
MODULE_DEPS=()  # No hard binary deps — shell is always available

# ── Paths ─────────────────────────────────────────────────────────────────────
_SHELL_CONF="${TERMKIT_ROOT}/dotfiles/config"
_SHELL_SHARED="${_SHELL_CONF}/shell"

# ── install ───────────────────────────────────────────────────────────────────
module_install() {
    log_section "Module: shell"

    # Shared utilities (sourced by both bash and zsh)
    safe_copy "${_SHELL_SHARED}/env.sh"       "$HOME/.config/termkit/shell/env.sh"
    safe_copy "${_SHELL_SHARED}/aliases.sh"   "$HOME/.config/termkit/shell/aliases.sh"
    safe_copy "${_SHELL_SHARED}/functions.sh" "$HOME/.config/termkit/shell/functions.sh"

    # Per-shell rc files
    local shell_name; shell_name="$(detect_shell)"

    case "$shell_name" in
        bash|unknown)
            safe_copy "${_SHELL_CONF}/bashrc"       "$HOME/.bashrc"
            safe_copy "${_SHELL_CONF}/bash_aliases" "$HOME/.bash_aliases"
            safe_copy "${_SHELL_CONF}/profile"      "$HOME/.profile"
            ;;
    esac

    case "$shell_name" in
        zsh|unknown)
            safe_copy "${_SHELL_CONF}/zshrc" "$HOME/.zshrc"
            ;;
    esac

    log_success "Shell module installed."
}

# ── uninstall ─────────────────────────────────────────────────────────────────
module_uninstall() {
    log_section "Uninstall: shell"
    safe_remove "$HOME/.bashrc"
    safe_remove "$HOME/.bash_aliases"
    safe_remove "$HOME/.profile"
    safe_remove "$HOME/.zshrc"
    safe_remove "$HOME/.config/termkit/shell/env.sh"
    safe_remove "$HOME/.config/termkit/shell/aliases.sh"
    safe_remove "$HOME/.config/termkit/shell/functions.sh"
    log_success "Shell module uninstalled. Original files backed up."
}

# ── validate ──────────────────────────────────────────────────────────────────
module_validate() {
    log_section "Validate: shell"
    local ok=0

    _validate_bash_syntax() {
        local f="$1"
        if [[ -f "$f" ]]; then
            if bash -n "$f" 2>/dev/null; then
                log_success "Syntax OK: $f"
            else
                log_error  "Syntax error: $f"
                (( ok++ )) || true
            fi
        else
            log_warning "Not found: $f"
        fi
    }

    _validate_bash_syntax "$HOME/.bashrc"
    _validate_bash_syntax "$HOME/.bash_aliases"
    _validate_bash_syntax "$HOME/.profile"
    _validate_bash_syntax "$HOME/.config/termkit/shell/env.sh"
    _validate_bash_syntax "$HOME/.config/termkit/shell/aliases.sh"
    _validate_bash_syntax "$HOME/.config/termkit/shell/functions.sh"

    return "$ok"
}
