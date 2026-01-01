#!/usr/bin/env bash

# Essential CLI Tools Installation Module
# Installs: fzf, ripgrep, fd, bat, eza, zoxide

install_cli_tools() {
    # fzf
    install_tool "fzf|Fuzzy Finder|fzf|fzf|--|https://github.com/junegunn/fzf#installation|Please install fzf manually using the provided URL"
    
    # Install fzf key bindings and fuzzy completion if just installed
    if command_exists fzf && [[ ! -f ~/.fzf.bash ]]; then
        print_section "Setting up fzf key bindings..."
        if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
            $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
        fi
        print_success "fzf key bindings configured"
    fi
    
    # ripgrep
    install_tool "ripgrep|Fast Code Search|ripgrep|ripgrep|--|https://github.com/BurntSushi/ripgrep#installation|Please install ripgrep manually using the provided URL"
    
    # fd
    install_tool "fd|Fast File Finder|fd|findutils|--|https://github.com/sharkdp/fd#installation|Please install fd manually using the provided URL"
    
    # bat
    install_tool "bat|Syntax Highlighted Cat|bat|bat|--|https://github.com/sharkdp/bat#installation|Please install bat manually using the provided URL"
    
    # eza
    install_tool "eza|Modern LS|eza|eza|--|https://github.com/eza-community/eza#installation|Please install eza manually using the provided URL"
    
    # zoxide
    install_tool "zoxide|Smart Directory Jumper|zoxide|zoxide|--|https://github.com/ajeetdsouza/zoxide#installation|Please install zoxide manually using the provided URL"
}