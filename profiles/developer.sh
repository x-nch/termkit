#!/usr/bin/env bash
# profiles/developer.sh — Full interactive workstation setup.
#
# Suitable for: local laptops, dedicated dev machines.

PROFILE_NAME="developer"
PROFILE_DESC="Full workstation: shell, git, starship, wezterm, vim, tmux"

profile_modules() {
    echo "shell git starship wezterm vim tmux"
}
