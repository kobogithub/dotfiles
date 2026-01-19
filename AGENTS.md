# AGENTS.md - Coding Agent Guide for Dotfiles Repository

This document provides essential information for AI coding agents working in this dotfiles repository.

## Repository Overview

This is a personal dotfiles repository for Arch Linux using GNU Stow for symlink management. It contains shell configurations, development environment setups, and utility scripts for a full-stack development environment.

**Owner**: Kevin Barroso
**Primary Languages**: Shell (Bash/Zsh), Python, JavaScript/TypeScript
**Structure**: GNU Stow packages - each directory represents a stow package that gets symlinked to $HOME

## Build/Test/Lint Commands

### Installation & Deployment
```bash
# Install all dotfiles and system packages (Arch Linux only)
./install.sh

# Install specific dotfile packages only
./install.sh -d git zsh nvim tmux

# Install only system packages
./install.sh -s

# Uninstall specific dotfiles
./install.sh -u git zsh

# Test installation (dry run with stow)
stow -n -d . -t $HOME <package-name>

# Manually install a package
stow -d . -t $HOME <package-name>

# Manually uninstall a package
stow -D -d . -t $HOME <package-name>
```

### Testing Shell Scripts
```bash
# Syntax check bash/zsh scripts
bash -n script.sh
zsh -n script.zsh

# ShellCheck linting (if available)
shellcheck script.sh

# Execute scripts in test mode
bash -x script.sh  # Debug mode with trace
```

### Development Environment Status
```bash
# Check development environment status
~/.local/bin/dev-status

# Verify stow installation
stow --version
```

## Code Style Guidelines

### Shell Scripts (.sh, .bash, .zsh)

**Shebang**: Always include at start of executable scripts
```bash
#!/bin/bash
# or
#!/usr/bin/env bash
```

**Comments**: 
- File header comment describing purpose
- Inline comments for complex logic
- Function documentation before each function

**Variables**:
- UPPERCASE for constants and environment variables: `DOTFILES_DIR`, `PATH`
- lowercase for local variables: `package`, `env_name`, `project_name`
- Use descriptive names: `project_name` not `pn`
- Quote variables: `"$variable"` not `$variable`
- Local variables in functions: `local var_name="value"`

**Functions**:
- Use snake_case: `install_system_packages()`, `backup_conflicting_files()`
- Document with comment before function
- Return early on errors with meaningful messages
```bash
# Example function pattern
function_name() {
    local param1="$1"
    
    if [[ -z "$param1" ]]; then
        echo "Error: parameter required"
        return 1
    fi
    
    # Function logic here
    echo "Success message"
}
```

**Error Handling**:
- Use `set -e` at script top for critical scripts (install.sh uses this)
- Check command existence: `command -v tool >/dev/null 2>&1`
- Validate parameters before use
- Provide helpful error messages with suggestions
- Use return codes: 0 for success, 1+ for errors

**Conditionals**:
- Use `[[ ]]` for tests (not `[ ]`)
- Quote variables: `[[ "$var" == "value" ]]`
- Check file existence: `[[ -f file ]]`, `[[ -d dir ]]`

**Output**:
- Use emoji prefixes for user messages: `🔧`, `✅`, `❌`, `⚠️`, `💡`
- Success: `echo "✅ Operation successful"`
- Error: `echo "❌ Operation failed"`
- Warning: `echo "⚠️ Warning message"`
- Info: `echo "💡 Helpful tip"`

**Aliases**:
- Short and memorable: `gs='git status'`, `ll='lsd -alF'`
- Group by category in config files
- Comment sections clearly

### File Organization

**Stow Package Structure**:
```
package-name/
├── .config/package-name/   # For ~/.config/ files
│   └── config.conf
├── .local/bin/             # For ~/.local/bin/ scripts
│   └── script-name
└── .package-rc             # For ~/. files
```

**Naming Conventions**:
- Scripts in bin/: lowercase with hyphens: `dev-status`, `dev-init`, `backup-files`
- Config files: follow upstream naming: `.zshrc`, `.bashrc`, `.gitconfig`
- Stow packages: lowercase: `git/`, `zsh/`, `nvim/`, `docker/`

### Git Commit Messages

Follow this repository's style (from git log analysis):
- Use descriptive, imperative mood: "Add feature", "Fix bug", "Update config"
- Be concise but clear
- Examples from this repo:
  - "Add comprehensive README with full documentation"
  - "Improve install script with better error handling"
  - "Update zsh configuration for atuin integration"

### Python Code (when present)

**Style**: PEP 8 compliant
- Indentation: 4 spaces
- Line length: 79-88 characters
- Imports: stdlib, third-party, local (in that order)
- Docstrings: Triple quotes for functions/classes
- Type hints: Use when appropriate

**Tools**: black, flake8, mypy, pytest
```bash
# Format code
black .

# Lint code  
flake8 .

# Type check
mypy .

# Run tests
pytest
```

### JavaScript/Node.js Code (when present)

**Style**: StandardJS or Prettier compatible
- Indentation: 2 spaces
- Semicolons: Optional (project dependent)
- Quotes: Single quotes preferred
- Use const/let, not var

**Tools**: eslint, prettier, jest
```bash
# Format code
npm run format

# Lint code
npm run lint

# Run tests
npm test
```

## Key Conventions

### PATH Management
- User scripts go in `~/.local/bin/` (managed by scripts/ and devscripts/ packages)
- System binaries stay in system directories
- PATH additions in shell configs: `export PATH=$HOME/.local/bin:$PATH`

### Configuration Loading Order
Zsh loads configs in this order:
1. `~/.profile` (system)
2. `~/.zshrc` (main config)
3. Tool-specific configs: `.docker_aliases`, `.python_config`, `.nodejs_config`, `.aliases_k8s`

### Backup Strategy
- `install.sh` automatically backs up conflicting files to `~/.dotfiles-backup/TIMESTAMP/`
- Before major changes, manual backups recommended: `cp file file.backup`

### Documentation
- Every script should have usage/help: `-h` or `--help` flag
- Main README.md documents user-facing features
- AGENTS.md (this file) documents for agents

## Development Workflows

### Adding New Dotfile Package
```bash
# 1. Create package structure
mkdir -p new-package/.config/new-package

# 2. Add configuration files
cp ~/.config/new-package/config new-package/.config/new-package/

# 3. Test with stow dry-run
stow -n -d . -t $HOME new-package

# 4. Install if no conflicts
stow -d . -t $HOME new-package

# 5. Add to DOTFILE_PACKAGES array in install.sh

# 6. Commit with descriptive message
git add new-package/
git commit -m "Add new-package configuration"
```

### Modifying Existing Scripts
```bash
# 1. Edit file in dotfiles directory
nvim ~/github/dotfiles/zsh/.zshrc

# 2. Restow if needed (usually automatic with symlinks)
stow -R -d ~/github/dotfiles -t $HOME zsh

# 3. Test changes
source ~/.zshrc  # or restart shell

# 4. Commit changes
git commit -am "Update zsh configuration for feature X"
```

### Testing Changes Before Commit
- Shell configs: `source ~/.zshrc` or open new shell
- Scripts: Run with `bash -x script.sh` for debugging
- Stow: Use `-n` flag for dry run
- Always test in development first

## Important Notes for Agents

1. **Never modify system files directly** - always work through dotfiles directory
2. **Use stow for symlinking** - don't manually create symlinks
3. **Respect user's Arch Linux setup** - package manager commands use pacman
4. **Preserve emoji style** in user messages - this is a convention in this repo
5. **Test before committing** - shell configs can break login if malformed
6. **Follow existing patterns** - look at similar configs before adding new ones
7. **Backup before major changes** - use install.sh backup functionality
8. **Quote all variables** - prevents word splitting issues
9. **Use `[[` not `[`** - it's more robust in bash/zsh
10. **Check command existence** before using with `command -v`

## Available Development Tools

**Scripts**: dev-status, dev-init, dev-clean, backup-files, alias-manager
**Shells**: bash, zsh (default)
**Editors**: vim, neovim (default)
**Terminal**: tmux (Ctrl-a prefix)
**Prompt**: starship
**History**: atuin
**Version Managers**: nvm (Node.js), pyenv (Python)
**Containers**: docker, docker-compose
**Kubernetes**: kubectl, k9s
**Package Manager**: pacman (Arch Linux)

## Quick Reference

**Git User**: Kevin Barroso <kobouharriet@gmail.com>
**Default Branch**: dev
**Editor**: nvim
**Shell**: zsh
**Working Directory**: /home/kobo/github/dotfiles
