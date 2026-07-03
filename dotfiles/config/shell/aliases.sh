#!/usr/bin/env bash
# dotfiles/config/shell/aliases.sh
# Shared aliases for bash and zsh.
# Sourced by both .bashrc and .zshrc.

# ── ls ────────────────────────────────────────────────────────────────────────
# Use eza/exa when available (better ls), otherwise fall back to ls.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first'
    alias ll='eza -lh --group-directories-first --git'
    alias la='eza -lha --group-directories-first --git'
    alias lt='eza --tree --level=2'
elif command -v exa >/dev/null 2>&1; then
    alias ls='exa --group-directories-first'
    alias ll='exa -lh --group-directories-first --git'
    alias la='exa -lha --group-directories-first --git'
else
    alias ll='ls -lhF'
    alias la='ls -lhAF'
    alias l='ls -CF'
fi

# ── grep ──────────────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ── disk / memory ─────────────────────────────────────────────────────────────
alias df='df -h'
alias du='du -h'
alias free='free -h'

# ── navigation ────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'
alias wget='wget -c'

# ── git ───────────────────────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpl='git pull --rebase'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gco='git checkout'
alias gsw='git switch'
alias gl='git log --oneline --graph --decorate'

# ── process inspection ────────────────────────────────────────────────────────
alias psa='ps aux'
alias psmem='ps aux --sort=-%mem | head -15'
alias pscpu='ps aux --sort=-%cpu | head -15'

# ── Docker (optional) ─────────────────────────────────────────────────────────
if command -v docker >/dev/null 2>&1; then
    alias d='docker'
    alias dps='docker ps'
    alias di='docker images'
    alias dprune='docker system prune -f'
fi

if command -v docker compose >/dev/null 2>&1; then
    alias dc='docker compose'
elif command -v docker-compose >/dev/null 2>&1; then
    alias dc='docker-compose'
fi

# ── Kubernetes (optional) ─────────────────────────────────────────────────────
if command -v kubectl >/dev/null 2>&1; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kga='kubectl get all'
    alias kd='kubectl describe'
    command -v kubecolor >/dev/null 2>&1 && alias kubectl='kubecolor'
fi

# ── Misc ──────────────────────────────────────────────────────────────────────
alias tree='tree -C'
alias path='echo -e "${PATH//:/\\n}"'
alias reload='exec ${SHELL}'
alias termkit-update='cd "${TERMKIT_ROOT:-$HOME/.termkit/termkit}" && git pull && termkit install'
