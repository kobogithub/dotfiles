# Dotfiles Constitution

Personal dotfiles for Kevin Barroso, managed with GNU Stow across Arch Linux and
macOS. These principles govern every change to this repository and take
precedence over convenience or habit.

## Core Principles

### I. Stow Is the Single Source of Truth

Every configuration lives inside a Stow package, and a file's path within the
package equals its destination under `$HOME` (`git/.gitconfig` → `~/.gitconfig`).
Files are edited **in the repo, never in the symlinked `~` copies**. Adding a
config to an existing package means placing it at its `~`-mirroring path and
running `stow -R <package>`. A new package is not real until it is also added to
the `DOTFILE_PACKAGES` array in `install.sh`. No manual symlinks — Stow owns the
linking.

### II. Installs Are Idempotent and Reversible

`install.sh` must be safe to run repeatedly. Conflicting files are backed up to
`~/.dotfiles-backup/TIMESTAMP/` before anything is overwritten, every package can
be uninstalled (`-u` / `stow -D`), and changes are previewed with `stow -n`
before applying. A change that cannot be undone or re-run without side effects
does not ship.

### III. Cross-Platform by Detection, Not Assumption

The repo targets both Arch Linux and macOS. OS-specific behavior is chosen at
runtime via `detect_os` (`arch` / `macos` / `other`), never hardcoded: package
installs branch to `pacman` or Homebrew, and Linux-only steps (systemd, the
`docker` group, `/etc/locale.conf`) are guarded out elsewhere. Paths that differ
across machines are resolved through `PATH`/lookup (`!gh`, not `/usr/bin/gh`), so
the same config works everywhere it is stowed.

### IV. Secrets Never Enter the Repo

No keys, tokens, or credentials are committed. Secrets live in `pass` and enter
the environment at shell startup via `export VAR="$(pass show <path>)"` in
`zsh/.env`. `.gitignore` (repo + global) excludes `*.key`, `*.pem`, `secrets/`,
`*.db`, kube config, and `**/.claude/settings.local.json`. Machine-local state is
gitignored, not committed.

### V. Validate Before Commit (NON-NEGOTIABLE)

A malformed `.zshrc` or `install.sh` can break login, so every shell change is
verified before it is committed: `bash -n` / `zsh -n` for syntax, `shellcheck`
when available, and sourcing in a subshell or new terminal for config. Scripts
use `set -e` and `set -o pipefail`. "It probably works" is not verification.

## Shell Script Standards

- Shebang on every executable script (`#!/bin/bash` or `#!/usr/bin/env bash`).
- Quote all variable expansions (`"$var"`); use `[[ ]]` over `[ ]`.
- `UPPERCASE` for constants/env, `lowercase` + `local` for function-scoped vars;
  functions are `snake_case` and documented with a leading comment.
- Guard external tools with `command -v tool >/dev/null 2>&1` before use.
- User-facing messages keep the emoji convention: `🔧` `✅` `❌` `⚠️` `💡`.
- Beware macOS ships Bash 3.2: avoid constructs that break there (e.g. `set -u`
  on empty-array expansion) unless guarded.

## Development Workflow

- Default branch is `dev`; commit messages use imperative mood and are concise.
- Git identity is per-folder via `includeIf`; commits in this repo sign with the
  personal key, and push/fetch route to the correct account through SSH host
  aliases (`me` / `work`) so account selection is automatic, not manual.
- Shared repo tooling (`install.sh`, `CLAUDE.md`, `AGENTS.md`, `.specify/`,
  `.claude/skills/`) lives at the repo root and is **not** a Stow package.
- Documentation stays honest: when behavior changes, `CLAUDE.md` / `AGENTS.md`
  are updated in the same change.

## Governance

This constitution supersedes ad-hoc practice. Any change that violates a
principle must either be reworked to comply or the constitution amended in the
same breath — with the version bumped and the rationale recorded. `AGENTS.md`
remains the detailed style reference and `CLAUDE.md` the architecture guide;
where they conflict with this document, this document wins. Amendments follow
semantic versioning: MAJOR for removing/redefining a principle, MINOR for adding
one or a new section, PATCH for clarifications.

**Version**: 1.0.0 | **Ratified**: 2026-07-15 | **Last Amended**: 2026-07-15
