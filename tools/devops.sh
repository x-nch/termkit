#!/usr/bin/env bash

# DevOps Tools Installation Module
# Installs: lazydocker, k9s

install_devops_tools() {
    # lazydocker
    install_tool "lazydocker|Docker TUI|lazydocker|lazydocker|--|https://github.com/jesseduffield/lazydocker#installation|Please install lazydocker manually using the provided guide"
    
    # k9s
    install_tool "k9s|Kubernetes TUI|k9s|k9s|--|https://github.com/derailed/k9s#installation|Please install k9s manually using the provided guide"
}