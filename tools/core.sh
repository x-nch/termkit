#!/usr/bin/env bash

# Core Tools Installation Module
# Installs: WezTerm, Starship, NeoVim, btop, Browsh

install_core_tools() {
    # WezTerm
    install_tool "wezterm|Terminal Emulator with GPU acceleration|wezterm|--|https://wezfurlong.org/wezterm/install/linux.html|Please install WezTerm manually using the provided URL"
    
    # Starship
    install_tool "starship|Fast, minimal shell prompt|starship|starship|--|https://starship.rs/guide/|Please install Starship manually using the provided guide"
    
    # NeoVim
    install_tool "neovim|Modern Vim-based text editor|neovim|neovim|--|https://github.com/neovim/neovim/releases|Please install NeoVim manually from releases page"
    
    # btop
    install_tool "btop|Beautiful system monitor|btop|btop|--|https://github.com/aristocratos/btop/releases|Please install btop manually from releases page"
    
    # Browsh (platform-specific)
    if [[ "$PLATFORM" == "macos" ]]; then
        install_tool "browsh|Text-based web browser|browsh|browsh|--|https://www.brow.sh/docs/installation/|Please install Browsh manually using the provided URL"
    else
        print_info "Browsh requires manual installation on Linux. Visit: https://www.brow.sh/docs/installation/"
        ((SKIPPED_COUNT++))
        SKIPPED_TOOLS+=("Browsh (Linux - manual install required)")
    fi
}

install_nerd_font() {
    if [[ "$PLATFORM" == "macos" ]]; then
        if ! brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
            ask_install "JetBrains Mono Nerd Font" "Font with glyphs for development tools" y
            if [[ $? -eq 0 ]]; then
                print_section "Installing JetBrains Mono Nerd Font..."
                brew tap homebrew/cask-fonts 2>/dev/null || true
                if safe_brew_install "font-jetbrains-mono-nerd-font" "cask"; then
                    print_success "Nerd Font installed"
                    ((INSTALLED_COUNT++))
                else
                    print_error "Failed to install Nerd Font"
                    ((FAILED_COUNT++))
                    FAILED_TOOLS+=("JetBrains Mono Nerd Font")
                fi
            else
                print_warning "Skipped Nerd Font"
                ((SKIPPED_COUNT++))
                SKIPPED_TOOLS+=("JetBrains Mono Nerd Font")
            fi
        else
            print_success "Nerd Font already installed"
        fi
    else
        print_warning "Please install a Nerd Font manually for your system"
        print_info "Recommended: JetBrains Mono Nerd Font"
        print_info "URL: https://github.com/ryanoasis/nerd-fonts/releases"
        ((SKIPPED_COUNT++))
        SKIPPED_TOOLS+=("JetBrains Mono Nerd Font (Linux - manual install required)")
    fi
}