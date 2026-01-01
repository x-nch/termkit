#!/usr/bin/env bash

# Git & Data Tools Installation Module
# Installs: lazygit, git-delta, jq, jless, xh

install_git_data_tools() {
    # lazygit
    install_tool "lazygit|Git TUI|lazygit|lazygit|--|https://github.com/jesseduffield/lazygit#installation|Please install lazygit manually using the provided URL"
    
    # git-delta
    install_tool "git-delta|Better Git Diffs|git-delta|git-delta|--|https://github.com/dandavison/delta#installation|Please install git-delta manually using the provided URL"
    
    # jq
    install_tool "jq|JSON Processor|jq|jq|--|https://stedolan.github.io/jq/download/|Please install jq manually using the provided URL"
    
    # jless
    install_tool "jless|JSON Viewer|jless|jless|--|https://github.com/PaulJuliusMartinez/jless#installation|Please install jless manually using the provided URL"
    
    # xh
    install_tool "xh|HTTP Client|xh|xh|--|https://github.com/ducaale/xh#installation|Please install xh manually using the provided URL"
    
    # Configure git delta if installed
    if command_exists delta; then
        print_section "Configuring git delta..."
        if git config --global core.pager "delta" 2>/dev/null; then
            git config --global interactive.diffFilter "delta --color-only"
            git config --global delta.navigate "true"
            git config --global delta.light "false"
            git config --global delta.side-by-side "true"
            git config --global merge.conflictstyle "diff3"
            git config --global diff.colorMoved "default"
            print_success "Git delta configured"
        fi
    fi
}