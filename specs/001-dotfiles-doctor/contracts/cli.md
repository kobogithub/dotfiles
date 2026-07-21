# CLI Contract: dotfiles-doctor

The tool's external interface. This is a CLI, so the "contract" is its
invocation, output format, and exit codes.

## Invocation

```text
dotfiles-doctor [OPTIONS]
```

### Options

| Option | Effect |
|--------|--------|
| (none) | Run all categories (Stow, Tools, Secrets), print full report |
| `-h`, `--help` | Print usage and exit 0 |
| `-q`, `--quiet` | Suppress per-check OK lines; show only WARN/FAIL + summary |
| `--only <cat>` | Run a single category: `stow` \| `tools` \| `secrets` |

- Invocable from any working directory (resolves repo root itself; FR-013).
- Unknown option → usage to stderr, exit 2.

## Output format

Human-readable, grouped by category. Colorized via tput **only when stdout is a
TTY** (`[ -t 1 ]`); plain text when piped/redirected.

```text
🔧 dotfiles-doctor — <os> (<DOTFILES_DIR>)

Stow
  ✅ git         linked
  ✅ zsh         linked
  ❌ scripts     conflict: ~/.local/bin/alias-manager is a real file, not a symlink
                 → run: stow -R scripts

Tools
  ✅ stow, git, zsh, nvim, tmux, starship, atuin, jq
  ⚠️ kubectl     not found (optional) → brew install kubectl

Secrets
  ✅ mcps/context7   resolves

Summary
  Stow     FAIL  (1 fail)
  Tools    WARN  (1 warn)
  Secrets  OK
  ───────────────────────
  Overall  FAIL
```

### Line grammar

Each check line: `<emoji> <item>   <message>[ → <hint>]`
- `✅` OK, `⚠️` WARN, `❌` FAIL (repo emoji convention).
- Hint (after `→`) present on every non-OK line (FR-010).
- Secret values are NEVER printed — only the `pass` path and resolve/fail.

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | No FAIL checks (all OK, or OK+WARN) — SC-003 |
| `1` | At least one FAIL check |
| `2` | Usage error (unknown option / bad `--only` value) |

## Guarantees

- **Read-only**: never creates/removes symlinks, installs packages, or writes
  files anywhere (FR-012, Principle II). Repeated runs are identical.
- **No network**: purely local inspection.
- **Deterministic exit**: exit code is a pure function of the checks' statuses.
