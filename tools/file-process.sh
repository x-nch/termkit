#!/usr/bin/env bash

# File & Process Tools Installation Module
# Installs: yazi, procs, sd, choose

install_file_process_tools() {
    # yazi
    install_tool "yazi|Terminal File Manager|yazi|yazi|--|https://github.com/sxyazi/yazi#installation|Please install yazi manually using the provided guide"
    
    # procs
    install_tool "procs|Modern PS|procs|procs|--|https://github.com/dalance/probs#installation|Please install procs manually using the provided guide"
    
    # sd (sed alternative)
    install_tool "sd|Find & Replace Alternative|sd|sd|--|https://github.com/chmln/sd#installation|Please install sd manually using the provided guide"
    
    # choose (cut alternative)
    install_tool "choose|Cut Alternative|choose|choose|--|https://github.com/theryangeary/choose#installation|Please install choose manually using the provided guide"
}