#!/usr/bin/env bash
# dotfiles/config/shell/env.sh
# Shared environment variables for bash and zsh.
# Sourced by both .bashrc and .zshrc via ~/.config/termkit/shell/env.sh
#
# Rule: Only exports that make sense in both shells go here.

# ── TermKit identity ──────────────────────────────────────────────────────────
export TERMKIT_VERSION="2.0.0"
export TERMKIT_CONFIG="$HOME/.config/termkit"

# ── Editor / Pager ────────────────────────────────────────────────────────────
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export LESS='-R --use-color'

# ── XDG base dirs (sane defaults if not set) ──────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# ── PATH additions (idempotent) ───────────────────────────────────────────────
_prepend_path() {
    [[ -d "$1" && ":${PATH}:" != *":$1:"* ]] && export PATH="$1:$PATH"
}
_prepend_path "$HOME/.local/bin"
_prepend_path "$HOME/.cargo/bin"
unset -f _prepend_path

# ── Language toolchains (optional — loaded only when present) ─────────────────
# Go
if command -v go >/dev/null 2>&1; then
    export GOPATH="${GOPATH:-$HOME/go}"
    [[ ":${PATH}:" != *":${GOPATH}/bin:"* ]] && export PATH="${GOPATH}/bin:$PATH"
fi

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Node / nvm
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"
[[ -s "${NVM_DIR}/bash_completion" ]] && source "${NVM_DIR}/bash_completion"

# Python
if command -v python3 >/dev/null 2>&1; then
    _py3_site="$(python3 -c 'import site; print(site.getusersitepackages())' 2>/dev/null || true)"
    [[ -n "$_py3_site" ]] && export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}${_py3_site}"
    unset _py3_site
fi

# Ruby / rbenv
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - 2>/dev/null)"
fi
