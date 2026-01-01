#!/usr/bin/env bash

# TermKit - Cross-Platform Workstation Setup Installer
# This script provides interactive installation of workstation components

set -euo pipefail

# Constants
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TERMKIT_VERSION="1.0.0"
readonly MIN_BASH_VERSION="4.0"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# System detection
detect_platform() {
    local platform
    platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
    
    case "$platform" in
        linux*)
            echo "linux"
            ;;
        darwin*)
            echo "macos"
            ;;
        mingw*|cygwin*|msys*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

detect_distro() {
    local platform
    platform="$(detect_platform)"
    
    if [[ "$platform" == "linux" ]]; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            echo "$ID"
        elif command -v lsb_release >/dev/null 2>&1; then
            lsb_release -si | tr '[:upper:]' '[:lower:]'
        else
            echo "unknown"
        fi
    else
        echo "n/a"
    fi
}

# Shell detection
detect_shell() {
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "zsh"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        echo "bash"
    elif [[ -n "${FISH_VERSION:-}" ]]; then
        echo "fish"
    else
        echo "unknown"
    fi
}

# Bash version check
check_bash_version() {
    local bash_version
    bash_version="${BASH_VERSION%%.*}"
    
    if (( bash_version < MIN_BASH_VERSION )); then
        log_error "Bash version $BASH_VERSION is too old. Minimum required: $MIN_BASH_VERSION"
        exit 1
    fi
}

# Dependency checks
check_dependencies() {
    local missing_deps=()
    local required_deps=("curl" "git" "tar")
    
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again."
        exit 1
    fi
}

# Backup existing configurations
backup_configs() {
    local backup_dir
    backup_dir="$HOME/.termkit_backup_$(date +%Y%m%d_%H%M%S)"
    
    log_info "Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir"
    
    local configs=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.config/starship.toml"
        "$HOME/.config/wezterm/wezterm.lua"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            local backup_path="$backup_dir/$(basename "$config")"
            cp "$config" "$backup_path"
            log_info "Backed up: $config -> $backup_path"
        fi
    done
    
    echo "$backup_dir"
}

# Interactive prompts
prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$prompt [Y/n]: " -r response
            response=${response:-Y}
        else
            read -p "$prompt [y/N]: " -r response
            response=${response:-N}
        fi
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) log_warning "Please respond with 'yes' or 'no'" ;;
        esac
    done
}

prompt_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    local default="${options[0]}"
    
    log_info "Available options:"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[i]}"
    done
    
    while true; do
        read -p "$prompt [1-${#options[@]}]: " -r response
        response=${response:-1}
        
        if [[ "$response" =~ ^[0-9]+$ ]] && (( response >= 1 && response <= ${#options[@]} )); then
            echo "${options[((response-1))]}"
            return 0
        else
            log_warning "Please enter a number between 1 and ${#options[@]}"
        fi
    done
}

# Installation modules
install_starship() {
    if ! prompt_yes_no "Install Starship prompt?" y; then
        return 0
    fi
    
    log_info "Installing Starship..."
    local starship_url="https://starship.rs/install.sh"
    local starship_hash="sha256:8c5b31b1f4c5b6d7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1"  # Placeholder
    
    if curl -fsSL "$starship_url" > /tmp/install_starship.sh; then
        if echo "$starship_hash /tmp/install_starship.sh" | sha256sum -c - 2>/dev/null; then
            chmod +x /tmp/install_starship.sh
            bash /tmp/install_starship.sh -y
            rm -f /tmp/install_starship.sh
            log_success "Starship installed successfully"
        else
            log_error "Hash verification failed for Starship installer"
            return 1
        fi
    else
        log_error "Failed to download Starship installer"
        return 1
    fi
}

install_wezterm() {
    if ! prompt_yes_no "Install WezTerm terminal?" n; then
        return 0
    fi
    
    local platform
    platform="$(detect_platform)"
    
    log_info "Installing WezTerm for $platform..."
    
    case "$platform" in
        linux)
            install_wezterm_linux
            ;;
        macos)
            install_wezterm_macos
            ;;
        windows)
            log_warning "WezTerm installation on Windows requires manual setup"
            log_info "Please download from: https://wezfurlong.org/wezterm/"
            ;;
        *)
            log_error "Unsupported platform for WezTerm: $platform"
            ;;
    esac
}

install_wezterm_linux() {
    local distro
    distro="$(detect_distro)"
    
    case "$distro" in
        ubuntu|debian)
            log_info "Adding WezTerm PPA for Ubuntu/Debian..."
            # Add installation logic here
            ;;
        fedora)
            log_info "Installing WezTerm via dnf..."
            # Add installation logic here
            ;;
        arch)
            log_info "Installing WezTerm via pacman..."
            sudo pacman -S wezterm
            ;;
        *)
            log_warning "Manual installation required for $distro"
            ;;
    esac
}

install_wezterm_macos() {
    if command -v brew >/dev/null 2>&1; then
        log_info "Installing WezTerm via Homebrew..."
        brew install --cask wezterm
    else
        log_warning "Homebrew not found. Manual installation required."
    fi
}

# Main installation flow
display_welcome() {
    echo
    echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        TermKit Installation           ║${NC}"
    echo -e "${BLUE}║     Cross-Platform Workstation       ║${NC}"
    echo -e "${BLUE}║           Version: $TERMKIT_VERSION              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo
}

display_system_info() {
    local platform distro shell
    platform="$(detect_platform)"
    distro="$(detect_distro)"
    shell="$(detect_shell)"
    
    log_info "System Information:"
    echo "  Platform: $platform"
    echo "  Distribution: $distro"
    echo "  Shell: $shell"
    echo "  Bash Version: $BASH_VERSION"
    echo
}

main() {
    # Initial checks
    check_bash_version
    check_dependencies
    
    # Display welcome and system info
    display_welcome
    display_system_info
    
    # Confirmation
    if ! prompt_yes_no "Proceed with TermKit installation?" y; then
        log_info "Installation cancelled by user."
        exit 0
    fi
    
    # Create backup
    local backup_dir
    backup_dir="$(backup_configs)"
    log_success "Configuration backup created: $backup_dir"
    
    # Installation modules
    install_starship
    install_wezterm
    
    # Install dotfiles
    log_info "Installing dotfiles..."
    if [[ -f "$SCRIPT_DIR/dotfiles/install.sh" ]]; then
        "$SCRIPT_DIR/dotfiles/install.sh" || log_warning "Dotfiles installation encountered issues"
    else
        log_warning "Dotfiles installer not found at $SCRIPT_DIR/dotfiles/install.sh"
    fi
    
    # Completion
    echo
    log_success "TermKit installation completed!"
    log_info "Backup location: $backup_dir"
    log_info "Please restart your shell to see changes."
    echo
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "TermKit Cross-Platform Workstation Installer"
        echo
        echo "Usage: $SCRIPT_NAME [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --version      Show version information"
        echo "  --check        Check system requirements only"
        echo
        exit 0
        ;;
    --version)
        echo "TermKit version $TERMKIT_VERSION"
        exit 0
        ;;
    --check)
        log_info "Checking system requirements..."
        check_bash_version
        check_dependencies
        log_success "System requirements met"
        exit 0
        ;;
esac

# Run main function
main "$@"