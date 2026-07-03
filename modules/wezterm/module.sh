#!/usr/bin/env bash
# modules/wezterm/module.sh — WezTerm terminal emulator config

MODULE_NAME="wezterm"
MODULE_DESC="WezTerm GPU-accelerated terminal configuration"
MODULE_DEPS=()  # Optional — we configure if present, install if requested

_WEZTERM_CONF="${TERMKIT_ROOT}/dotfiles/config/wezterm.lua"
_WEZTERM_DEST="$HOME/.config/wezterm/wezterm.lua"

_install_wezterm_linux() {
    local distro; distro="$(detect_distro)"
    local pm; pm="$(detect_package_manager)"

    case "$distro" in
        ubuntu|debian)
            log_info "Installing WezTerm via apt..."
            run_cmd curl -fsSL https://apt.fury.io/wez/gpg.key | run_cmd sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | run_cmd sudo tee /etc/apt/sources.list.d/wezterm.list
            run_cmd sudo apt-get update -q
            pm_install wezterm
            ;;
        fedora|rhel|centos|rocky|alma)
            pm_install wezterm
            ;;
        arch|manjaro)
            pm_install wezterm
            ;;
        *)
            log_warning "Automatic WezTerm install not supported for '$distro'."
            log_info "Download from: https://wezfurlong.org/wezterm/installation.html"
            ;;
    esac
}

_install_wezterm_macos() {
    if command -v brew >/dev/null 2>&1; then
        run_cmd brew install --cask wezterm
    else
        log_warning "Homebrew not found. Download WezTerm from: https://wezfurlong.org/wezterm/"
    fi
}

module_install() {
    log_section "Module: wezterm"

    if ! command -v wezterm >/dev/null 2>&1; then
        if prompt_yes_no "WezTerm not found. Install it?" n; then
            local os; os="$(detect_os)"
            case "$os" in
                linux)  _install_wezterm_linux  ;;
                macos)  _install_wezterm_macos  ;;
                windows) log_warning "Download WezTerm manually for Windows: https://wezfurlong.org/wezterm/" ;;
                *)       log_warning "Unsupported OS for automatic WezTerm install." ;;
            esac
        else
            log_info "Skipping WezTerm binary install. Config will still be copied."
        fi
    else
        log_success "WezTerm already installed: $(wezterm --version 2>/dev/null || echo 'unknown version')"
    fi

    safe_copy "$_WEZTERM_CONF" "$_WEZTERM_DEST"
    log_success "WezTerm module installed."
}

module_uninstall() {
    log_section "Uninstall: wezterm"
    safe_remove "$_WEZTERM_DEST"
    log_success "WezTerm config removed."
}

module_validate() {
    log_section "Validate: wezterm"
    local ok=0

    if ! command -v wezterm >/dev/null 2>&1; then
        log_warning "wezterm not installed, skipping validation."
        return 0
    fi

    log_success "wezterm installed: $(wezterm --version 2>/dev/null)"

    if [[ -f "$_WEZTERM_DEST" ]]; then
        log_success "Config present: $_WEZTERM_DEST"
    else
        log_warning "Config missing: $_WEZTERM_DEST"
        (( ok++ )) || true
    fi

    return "$ok"
}
