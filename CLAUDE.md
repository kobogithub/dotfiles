# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal dotfiles for **Arch Linux**, managed with **GNU Stow**. Owner: Kevin Barroso. A detailed style/conventions guide already exists in `AGENTS.md` — read it for shell-script style rules, naming, and commit conventions. This file covers the architecture and the commands you'll actually run.

## The Stow model (most important thing to understand)

Each top-level directory is a **Stow package**. Stow symlinks the package's contents into `$HOME`, mirroring the internal directory layout. So a file's path inside a package equals its destination path under `~`:

- `git/.gitconfig` → `~/.gitconfig`
- `zsh/.zshrc` → `~/.zshrc`
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `scripts/.local/bin/<x>` and `devscripts/.local/bin/<x>` → `~/.local/bin/<x>`

Consequences for editing:
- **Edit files here in the repo, never the symlinked copies in `~`.** Since they're symlinks, edits in `~` actually modify the repo files — but always work from the repo to stay oriented.
- When adding a new config file to an existing package, place it at the path matching its `~` destination, then `stow -R <package>` to pick up new files.
- A new package must also be added to the `DOTFILE_PACKAGES` array in `install.sh` to be included in full installs.

## install.sh

`install.sh` is the entry point; it drives Stow plus Arch-specific setup. Key behaviors:
- Backs up conflicting files to `~/.dotfiles-backup/TIMESTAMP/` before stowing (via `stow -n` dry-run parsing).
- System-package install uses `pacman` and is **Arch-only** (gated by `check_arch`); Docker is handled separately to avoid conflicts.
- Post-install steps (full install only): installs `nvm` + `pyenv`, sets up locale (`C.UTF-8`), adds user to `docker` group, sets `zsh` as default shell, inits `atuin`.

```bash
./install.sh                 # full: system packages + all dotfiles + setup
./install.sh -d git zsh nvim # stow only these packages (no system packages)
./install.sh -s              # system packages only
./install.sh -u git zsh      # unstow (uninstall) these packages
./install.sh -h              # help; lists all available packages

# Manual stow operations (from repo root):
stow -n -d . -t $HOME <pkg>  # dry-run, check for conflicts
stow -d . -t $HOME <pkg>     # install
stow -R -d . -t $HOME <pkg>  # restow (after adding/removing files in a package)
stow -D -d . -t $HOME <pkg>  # uninstall
```

## Shell config loading (zsh)

`~/.zshrc` is the hub. It sources `~/.profile` first, then near the end sources tool-specific configs **directly from `~/.dotfiles/`** (not from stowed `~` paths):
`zsh/.aliases_general`, `docker/.docker_aliases`, `kubectl/.aliases_k8s`, `python/.python_config`, `nodejs/.nodejs_config`. Finally it sources `~/.env`.

So changes to those alias/config files take effect on a new shell **without re-stowing** (they're sourced by absolute path), but `.zshrc` itself only updates in `~` if the `zsh` package is stowed.

## Secrets

Secrets are **not stored in the repo**. `zsh/.env` (→ `~/.env`) populates env vars at shell startup by calling `pass show <path>` (the `pass` password manager) — e.g. API keys for MCP servers, GCP OAuth creds. To add a secret: store it in `pass`, then add an `export VAR="$(pass show <path>)"` line to `zsh/.env`. `.gitignore` excludes `*.key`, `*.pem`, `secrets/`, `*.db`, and kube config.

## Validation before committing

```bash
bash -n install.sh           # syntax-check a shell script
shellcheck <script>          # lint (if installed)
source ~/.zshrc              # test shell config changes in current shell
```

Test shell config in a subshell/new terminal before committing — a malformed `.zshrc` can break login. Default branch is `dev`; commit messages use imperative mood (see `AGENTS.md`).

## OpenCode package

`opencode/` holds AI agent definitions and skills (FastAPI, PostgreSQL, Supabase, Docker, Astro, docs, QA) stowed into `~/.config/opencode/`. See `opencode/README.md` for the catalog. This is configuration content, not application code.
</content>
</invoke>
