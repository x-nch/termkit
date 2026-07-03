#!/usr/bin/env bash
# modules/starship/module.sh — Starship prompt installation and configuration

MODULE_NAME="starship"
MODULE_DESC="Starship cross-shell prompt"
MODULE_DEPS=()  # We install starship ourselves if absent

# Official installer — update hash after pinning to a specific release.
# To pin: download the installer, run sha256sum, paste the output below.
_STARSHIP_URL="https://starship.rs/install.sh"
_STARSHIP_HASH=""   # Leave empty to skip hash check (not recommended for prod)

_STARSHIP_CONF="${TERMKIT_ROOT}/dotfiles/config/starship.toml"

_install_binary() {
    if command -v starship >/dev/null 2>&1; then
        log_info "starship already installed: $(starship --version)"
        return 0
    fi

    if [[ -z "$_STARSHIP_HASH" ]]; then
        log_warning "No hash pinned for starship installer — downloading anyway."
        log_warning "For reproducible installs, pin _STARSHIP_HASH in modules/starship/module.sh"

        local tmp; tmp="$(mktemp)"
        if curl -fsSL "$_STARSHIP_URL" -o "$tmp"; then
            chmod 700 "$tmp"
            run_cmd bash "$tmp" -y
            rm -f "$tmp"
        else
            log_error "Failed to download starship installer."
            return 1
        fi
    else
        secure_execute "$_STARSHIP_URL" "$_STARSHIP_HASH" -y
    fi
}

module_install() {
    log_section "Module: starship"

    _install_binary || return 1

    safe_copy "$_STARSHIP_CONF" "$HOME/.config/starship.toml"

    log_success "Starship module installed."
    log_info "Add 'eval \"\$(starship init <shell>)\"' to your rc if not already present."
}

module_uninstall() {
    log_section "Uninstall: starship"
    safe_remove "$HOME/.config/starship.toml"
    log_info "starship binary not removed — uninstall manually if desired."
    log_success "Starship config removed."
}

module_validate() {
    log_section "Validate: starship"
    local ok=0

    if ! command -v starship >/dev/null 2>&1; then
        log_warning "starship binary not found."
        return 0
    fi

    log_success "starship installed: $(starship --version)"

    local cfg="$HOME/.config/starship.toml"
    if [[ -f "$cfg" ]]; then
        log_success "Config present: $cfg"
    else
        log_warning "Config not found: $cfg"
        (( ok++ )) || true
    fi

    return "$ok"
}
