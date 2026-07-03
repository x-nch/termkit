# termkit — AI Context

## Architecture
Terminal kit for managing development environment across machines. Modular system with shell configs, tmux, WezTerm, Starship, vim, and git modules. Dotfiles management with auto-install scripts.

## Current Blockers
- 10 uncommitted files (develop_xperimet branch)
- install.sh and install_dotfiles.sh may have drifted

## Next Tasks
- [P1] Commit or stash pending changes
- [P2] Review install.sh for correctness
- [P2] Test dotfiles install end-to-end

## Important Commands
- Install: `./install.sh`
- Install dotfiles: `./install_dotfiles.sh`
- Test: `cd tests && pytest`

## Dependency Map
- tmux: terminal multiplexer
- WezTerm: terminal emulator
- Starship: prompt
- vim: editor

## Health
- Score: 63/100
- Issues: 10 uncommitted files

## Last Session
- Date: 2026-05-07
