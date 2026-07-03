#!/usr/bin/env bash
# profiles/server.sh — Headless server setup.
#
# Suitable for: VPS, CI runners, cloud instances — no GUI tools.

PROFILE_NAME="server"
PROFILE_DESC="Headless server: shell, git, vim, tmux (no GUI tools)"

profile_modules() {
    echo "shell git vim tmux"
}
