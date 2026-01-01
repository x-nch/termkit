# TermKit

TermKit is a specialized cross-platform workstation setup and dotfile management system designed for consistent shell environments across Linux, macOS, and Windows (WSL).

## Features

- **Interactive Installation** - User-guided setup process with clear prompts
- **Cross-Platform Support** - Works seamlessly across different operating systems
- **Security-First Design** - Hash verification for all remote script execution
- **Dry-Run Mode** - Safe preview of changes before execution
- **Configuration Validation** - Built-in syntax and configuration checking
- **Comprehensive Tooling** - Support for wezterm, starship, and other terminal tools

## Quick Start

### Main Installation (Interactive)
```bash
./install.sh
```

### Dotfiles Installation
```bash
cd dotfiles && ./install.sh
```

### Dry Run Mode
```bash
cd dotfiles && ./install.sh --dry-run
```

## Security

All remote script downloads use hash verification to prevent malicious execution:

```bash
# Example of required pattern
readonly SCRIPT_URL="https://example.com/script.sh"
readonly SCRIPT_HASH="sha256:abcdef1234567890"

if curl -fsSL "$SCRIPT_URL" > /tmp/script.sh; then
    if echo "$SCRIPT_HASH /tmp/script.sh" | sha256sum -c -; then
        chmod +x /tmp/script.sh && /tmp/script.sh
        rm -f /tmp/script.sh
    else
        echo "Hash verification failed"
        exit 1
    fi
fi
```

## Project Structure

```
termkit/
├── install.sh           # Main interactive installer
├── dotfiles/           # Configuration files
│   ├── install.sh      # Dotfiles installer with dry-run
│   ├── config/         # Application configs
│   └── scripts/        # Utility scripts
├── scripts/            # Helper scripts
└── docs/              # Documentation
```

## Validation

### Script Syntax Validation
```bash
bash -n install.sh
bash -n dotfiles/install.sh
```

### Configuration Validation
```bash
./scripts/validate.sh
```

### Quick Validation
```bash
./scripts/validate.sh --quick
```

## Development

### Code Style
- **Shebang**: Always use `#!/usr/bin/env bash`
- **Error Handling**: Use `set -euo pipefail`
- **Function Naming**: `snake_case` with descriptive names
- **Variable Naming**: `UPPER_CASE` for constants, `snake_case` for variables

### Testing
Run validation tests to ensure setup integrity:
```bash
./scripts/validate.sh
```

### Security Audit
Check for security vulnerabilities:
```bash
./scripts/security.sh --audit
```

## Configuration Files

The following configuration files are managed by TermKit:

- **Shell Configurations**: `.bashrc`, `.zshrc`, `.profile`, `.bash_aliases`
- **Git Configuration**: `.gitconfig`, `.gitignore_global`
- **Editor Configuration**: `.vimrc`
- **Terminal Configuration**: `.tmux.conf`
- **Tool Configurations**: Starship, WezTerm, VS Code, Neovim

## Platform Support

TermKit supports the following platforms:

- **Linux**: All major distributions (Ubuntu, Debian, Fedora, Arch, etc.)
- **macOS**: All recent versions
- **Windows**: Windows Subsystem for Linux (WSL)

## Troubleshooting

### Installation Issues

1. **Permission Denied**: Make scripts executable:
   ```bash
   chmod +x install.sh
   chmod +x dotfiles/install.sh
   ```

2. **Hash Verification Failed**: Update expected hashes in scripts

3. **Configuration Conflicts**: Check local `.local` files

### Debug Mode

Enable debug logging:
```bash
export TERMKIT_DEBUG=1
./install.sh
```

### Log Analysis

Check installation logs:
```bash
tail -f ~/.termkit_install.log
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following coding standards
4. Run validation tests
5. Submit a pull request

### Development Workflow

See [docs/workflow.md](docs/workflow.md) for detailed development guidelines.

## License

Proprietary - Part of the Nexi ecosystem

## Recovery Notice

This project has been reconstructed from documentation following the loss of the original codebase. The implementation follows the documented requirements and security patterns from the AGENTS.md specification.