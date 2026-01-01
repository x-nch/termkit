#!/usr/bin/env bash

# Utility Tools Installation Module
# Installs: doggo, glow, tealdeer, difftastic, jqp

install_utility_tools() {
    # doggo
    install_tool "doggo|Modern DNS Tool|doggo|doggo|--|https://github.com/ogham/dog#installation|Please install doggo manually using the provided guide"
    
    # glow
    install_tool "glow|Markdown Renderer|glow|glow|--|https://github.com/charmbracelet/glow#installation|Please install glow manually using the provided guide"
    
    # tealdeer (tldr)
    install_tool "tealdeer|TLDR Pages|tealdeer|tealdeer|--|https://github.com/dbrgn/tealdeer#installation|Please install tealdeer manually using the provided guide"
    
    # difftastic
    install_tool "difftastic|Structural Diffs|difftastic|difftastic|--|https://github.com/willemml/difftastic#installation|Please install difftastic manually using the provided guide"
    
    # jqp (interactive jq)
    install_tool "jqp|Interactive JSON Processor|jqp|jqp|--|https://github.com/noamr/jqp#installation|Please install jqp manually using the provided guide"
    
    # Update tealdeer cache if installed
    if command_exists tldr; then
        print_section "Updating tealdeer cache..."
        tldr --update 2>/dev/null || true
        print_success "tealdeer cache updated"
    fi
}