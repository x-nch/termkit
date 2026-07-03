#!/usr/bin/env bash
# dotfiles/config/shell/functions.sh
# Shared shell functions for bash and zsh.

# ── Directory navigation ──────────────────────────────────────────────────────
# mkcd: make a directory and cd into it
mkcd() {
    [[ -z "$1" ]] && { echo "Usage: mkcd <directory>"; return 1; }
    mkdir -p "$1" && cd "$1" || return 1
}

# ── Archive extraction ────────────────────────────────────────────────────────
# Single function — handles any common archive format.
extract() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: extract <file> [file...]"
        return 1
    fi

    local f
    for f in "$@"; do
        if [[ ! -f "$f" ]]; then
            echo "extract: '$f' is not a file." >&2
            continue
        fi
        case "$f" in
            *.tar.bz2|*.tbz2) tar xjf "$f"    ;;
            *.tar.gz|*.tgz)   tar xzf "$f"    ;;
            *.tar.xz|*.txz)   tar xJf "$f"    ;;
            *.tar.zst)        tar --zstd -xf "$f" ;;
            *.tar)            tar xf  "$f"    ;;
            *.bz2)            bunzip2 "$f"    ;;
            *.gz)             gunzip  "$f"    ;;
            *.rar)            unrar x "$f"    ;;
            *.zip)            unzip   "$f"    ;;
            *.Z)              uncompress "$f" ;;
            *.7z)             7z x    "$f"    ;;
            *.zst)            zstd -d "$f"    ;;
            *) echo "extract: unknown format: '$f'" >&2 ;;
        esac
    done
}

# ── File utilities ────────────────────────────────────────────────────────────
# ff: find file by name
ff() {
    [[ -z "$1" ]] && { echo "Usage: ff <pattern> [directory]"; return 1; }
    find "${2:-.}" -name "*${1}*" -not -path '*/.git/*' 2>/dev/null
}

# fif: find text inside files
fif() {
    [[ -z "$1" ]] && { echo "Usage: fif <pattern> [directory]"; return 1; }
    grep -r --include="*.{sh,py,js,ts,go,rs,rb,java,c,cpp,h}" \
        -n "$1" "${2:-.}" 2>/dev/null
}

# ── Process utilities ─────────────────────────────────────────────────────────
# port: show what's listening on a port
port() {
    [[ -z "$1" ]] && { echo "Usage: port <number>"; return 1; }
    if command -v ss >/dev/null 2>&1; then
        ss -tlnp | grep ":${1}"
    else
        netstat -tlnp 2>/dev/null | grep ":${1}"
    fi
}

# ── Network utilities ─────────────────────────────────────────────────────────
myip() {
    # Public IP
    if command -v curl >/dev/null 2>&1; then
        curl -s --max-time 5 https://api.ipify.org 2>/dev/null && echo
    fi
}

# ── Development utilities ─────────────────────────────────────────────────────
# serve: quick HTTP server from current directory
serve() {
    local port="${1:-8000}"
    if command -v python3 >/dev/null 2>&1; then
        echo "Serving on http://localhost:${port}"
        python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        python -m SimpleHTTPServer "$port"
    else
        echo "serve: python not found." >&2
        return 1
    fi
}

# git-root: cd to repo root
git-root() {
    local root
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        echo "git-root: not inside a git repo" >&2
        return 1
    }
    cd "$root" || return 1
}

# ── Misc ──────────────────────────────────────────────────────────────────────
# calc: inline calculator
calc() {
    echo "${*}" | bc -l
}

# repeat: run a command N times
repeat() {
    local n="$1"; shift
    for _ in $(seq 1 "$n"); do "$@"; done
}

# confirm: prompt before running a destructive command
confirm() {
    read -rp "Are you sure? [y/N] " resp
    [[ "${resp,,}" == "y" ]]
}
