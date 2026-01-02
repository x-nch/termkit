# TermKit Tools Handbook

A comprehensive guide to all the tools installed by the Terminal Control Plane setup.

## Core Foundation Tools

### WezTerm
**Terminal Emulator with GPU acceleration**
- **Website**: https://wezfurlong.org/wezterm/
- **Basic Operations**:
  - `wezterm` - Launch terminal
  - `Ctrl+Shift+T` - New tab
  - `Ctrl+Shift+D` - Split pane horizontally
  - `Ctrl+Shift+Enter` - Toggle fullscreen

### Starship
**Fast, minimal shell prompt**
- **Website**: https://starship.rs/
- **Basic Operations**:
  - Automatically displays in your shell prompt
  - Shows git status, current directory, command duration
  - Customizable via `~/.config/starship.toml`

### NeoVim
**Modern Vim-based text editor**
- **Website**: https://neovim.io/
- **Basic Operations**:
  - `nvim file.txt` - Edit file
  - `:w` - Save file
  - `:q` - Quit
  - `:wq` - Save and quit
  - `i` - Insert mode, `Esc` - Normal mode

### btop
**Beautiful system monitor**
- **Website**: https://github.com/aristocratos/btop
- **Basic Operations**:
  - `btop` - Launch system monitor
  - `h` - Help menu
  - `q` - Quit
  - Arrow keys - Navigate processes

### Browsh
**Text-based web browser**
- **Website**: https://www.brow.sh/
- **Basic Operations**:
  - `browsh` - Launch browser
  - Arrow keys - Navigate
  - Enter - Follow link
  - `q` - Quit

## Essential CLI Tools

### fzf
**Command-line fuzzy finder**
- **Website**: https://github.com/junegunn/fzf
- **Basic Operations**:
  - `Ctrl+T` - Fuzzy file search
  - `Ctrl+R` - Fuzzy history search
  - `Alt+C` - Fuzzy directory navigation
  - `fe` - Fuzzy find and edit file

### ripgrep (rg)
**Fast text search tool**
- **Website**: https://github.com/BurntSushi/ripgrep
- **Basic Operations**:
  - `rg "pattern"` - Search for pattern in current directory
  - `rg -i "pattern"` - Case-insensitive search
  - `rg --type rust "pattern"` - Search in Rust files only
  - `search "pattern"` - Alias for rg

### fd
**Simple, fast alternative to find**
- **Website**: https://github.com/sharkdp/fd
- **Basic Operations**:
  - `fd pattern` - Find files matching pattern
  - `fd -e txt` - Find all .txt files
  - `fd -H` - Include hidden files
  - `fcd pattern` - Fuzzy find and cd to directory

### bat
**Cat clone with syntax highlighting**
- **Website**: https://github.com/sharkdp/bat
- **Basic Operations**:
  - `bat file.txt` - Display file with syntax highlighting
  - `bat -n file.txt` - Show line numbers
  - `less file.txt` - Use bat as pager
  - `cat file.txt` - Alias that uses bat

### eza
**Modern replacement for ls**
- **Website**: https://github.com/eza-community/eza
- **Basic Operations**:
  - `ls` - List files with icons and git status
  - `ll` - Long listing format
  - `la` - Show hidden files
  - `lt` - Tree view

### zoxide (z)
**Smarter cd command**
- **Website**: https://github.com/ajeetdsouza/zoxide
- **Basic Operations**:
  - `z directory` - Smart cd with frecency
  - `zi` - Interactive directory selection
  - `z -` - Go to previous directory
  - `Alt+C` - Fuzzy directory search

## Git & Data Tools

### lazygit
**Simple terminal UI for git**
- **Website**: https://github.com/jesseduffield/lazygit
- **Basic Operations**:
  - `lg` - Launch lazygit
  - Arrow keys - Navigate
  - Enter - Select/action
  - `?` - Help
  - `q` - Quit

### delta
**Syntax-highlighting pager for git**
- **Website**: https://github.com/dandavison/delta
- **Basic Operations**:
  - Automatically used in `git diff`
  - `git show` - Enhanced commit viewing
  - `git log --patch` - Enhanced log with diffs

### jq
**Command-line JSON processor**
- **Website**: https://stedolan.github.io/jq/
- **Basic Operations**:
  - `jq '.key' file.json` - Extract JSON key
  - `jq '.[] | select(.age > 20)' file.json` - Filter array
  - `jq '.name' file.json` - Get name field
  - `cat data.json | jq .` - Pretty print JSON

### jless
**Command-line JSON viewer**
- **Website**: https://github.com/PaulJuliusMartinez/jless
- **Basic Operations**:
  - `jl file.json` - Interactive JSON viewer
  - Arrow keys - Navigate JSON structure
  - Enter - Expand/collapse
  - `/` - Search
  - `q` - Quit

### xh
**Friendly HTTP client**
- **Website**: https://github.com/ducaale/xh
- **Basic Operations**:
  - `xh httpbin.org/get` - GET request
  - `xh POST httpbin.org/post name=john` - POST request
  - `xh --json POST api.example.com/users '{"name":"john"}'` - JSON POST
  - `http` - Alias for xh

## File & Process Tools

### yazi
**Terminal file manager**
- **Website**: https://github.com/sxyazi/yazi
- **Basic Operations**:
  - `fm` - Launch file manager
  - Arrow keys - Navigate
  - Enter - Open file/directory
  - `q` - Quit

### procs
**Modern replacement for ps**
- **Website**: https://github.com/dalance/procs
- **Basic Operations**:
  - `ps` - Show processes with better formatting
  - `procs --tree` - Show process tree
  - `procs -w` - Wide output
  - `procs --sort cpu` - Sort by CPU usage

### sd
**Intuitive find & replace**
- **Website**: https://github.com/chmln/sd
- **Basic Operations**:
  - `sd 'old' 'new' file.txt` - Replace in file
  - `sd -i 'old' 'new'` - Case-insensitive
  - `echo 'hello world' | sd 'world' 'universe'` - Pipe replacement
  - `sed` - Alias that uses sd

### choose
**Human-friendly cut alternative**
- **Website**: https://github.com/theryangeary/choose
- **Basic Operations**:
  - `echo 'a,b,c' | choose 0` - Select first field
  - `echo 'a b c' | choose -1` - Select last field
  - `echo 'a:b:c' | choose -f ':' 1` - Custom delimiter
  - `cut` - Alias that uses choose

## DevOps Tools (Optional)

### lazydocker
**Simple terminal UI for docker**
- **Website**: https://github.com/jesseduffield/lazydocker
- **Basic Operations**:
  - `lzd` - Launch lazydocker
  - Arrow keys - Navigate containers
  - Enter - View logs
  - `q` - Quit

### k9s
**Terminal UI for Kubernetes**
- **Website**: https://github.com/derailed/k9s
- **Basic Operations**:
  - `k` - Launch k9s
  - `0-9` - Switch namespaces
  - Arrow keys - Navigate resources
  - `d` - Describe resource
  - `l` - View logs

## Utility Tools

### doggo
**Command-line DNS client**
- **Website**: https://github.com/mr-karan/doggo
- **Basic Operations**:
  - `doggo example.com` - DNS lookup
  - `doggo -t MX example.com` - MX record lookup
  - `dig example.com` - Alias that uses doggo

### glow
**Render markdown in terminal**
- **Website**: https://github.com/charmbracelet/glow
- **Basic Operations**:
  - `glow README.md` - Render markdown file
  - `readme` - Alias for glow with default styling
  - `glow -p file.md` - Pager mode

### tealdeer (tldr)
**Simplified man pages**
- **Website**: https://github.com/dbrgn/tealdeer
- **Basic Operations**:
  - `tldr tar` - Quick help for tar command
  - `tldr --update` - Update tldr pages
  - `help command` - Alias for tldr

### difftastic
**Syntax-aware diff tool**
- **Website**: https://github.com/Wilfred/difftastic
- **Basic Operations**:
  - `difft file1.txt file2.txt` - Syntax-aware diff
  - `git difftool` - Use with git (configure in .gitconfig)

### jqp
**Interactive jq processor**
- **Website**: https://github.com/noahgorstein/jqp
- **Basic Operations**:
  - `jqp file.json` - Interactive JSON exploration
  - Arrow keys - Navigate
  - Enter - Select fields
  - `q` - Quit

## History Management

TermKit provides comprehensive command history management with fuzzy search and automatic saving:

- `Ctrl+R` - Enhanced fuzzy search through command history with live preview and reload
- `Alt+C` - Alternative fuzzy history search
- `hs` - Interactive history search function
- `hgrep 'pattern'` - Grep through command history
- `hsync` - Manually sync history to disk and reload
- `hrecent [n]` - Show last n commands (default 10)
- History is automatically saved every 30 seconds and on shell exit
- All commands are logged with timestamps
- **Performance**: Instant loading (< 0.001s startup time)

## Enhanced Commands & Aliases

### Git Aliases
- `gs` - `git status -s`
- `ga` - `git add`
- `gc` - `git commit`
- `gp` - `git push`
- `gl` - `git log --oneline --graph -10`
- `gd` - `git diff`
- `gco` - `git checkout`
- `gb` - `git branch`
- `gclean` - `git clean -fd && git gc --aggressive`

### Productivity Functions
- `fe pattern` - Fuzzy find and edit file
- `fcd pattern` - Fuzzy find and cd to directory
- `rge pattern` - Search and edit with preview
- `mkcd dirname` - Create directory and cd into it
- `killport port` - Kill process on specific port
- `qgc "message"` - Quick git commit and push
- `project` - Interactive project switcher
- `web-search query` - Open search in browser
- `sysinfo` - Display system information

### Docker Aliases
- `d` - `docker`
- `dc` - `docker-compose`
- `dps` - `docker ps` with formatting
- `dim` - `docker images` with formatting

## Keyboard Shortcuts

- `Ctrl+T` - Fuzzy file search and edit
- `Ctrl+R` - Enhanced fuzzy history search (with preview, reload, and copy)
- `Alt+C` - Fuzzy command history search
- `Alt+Z` - Fuzzy directory navigation (zoxide)
- `Ctrl+Shift+T` (WezTerm) - New tab
- `Ctrl+Shift+D` (WezTerm) - Split pane

## Getting Help

- `tldr command` - Quick command reference
- `man command` - Full manual pages
- `command --help` - Built-in help
- `?` in interactive tools (lazygit, k9s, etc.) - Help menus

This handbook covers all tools installed by TermKit. Each tool includes basic usage examples and links to official documentation for deeper learning.