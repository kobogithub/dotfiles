# Quickstart & Validation: dotfiles-doctor

End-to-end validation guide. Proves the feature works on both the healthy path
and the broken path without touching the real environment for the broken case.

## Prerequisites

- Repo cloned and the `scripts` package stowed (`./install.sh -d scripts`, or
  `stow -R -d . -t $HOME scripts` from repo root).
- `~/.local/bin` on `PATH` (already handled by the `zsh`/profile config).
- Optional: `pass` initialized (Secrets category degrades to WARN if absent).

## Static validation (Principle V — before commit)

```bash
bash -n scripts/.local/bin/dotfiles-doctor      # syntax
shellcheck scripts/.local/bin/dotfiles-doctor   # lint (if installed)
```

Expected: no syntax errors; shellcheck clean (or only justified suppressions).

## Scenario 1 — Healthy machine (SC-001)

```bash
dotfiles-doctor ; echo "exit=$?"
```

Expected:
- Every category reports OK (Secrets may be WARN if `pass` is not set up).
- `exit=0`.

## Scenario 2 — Broken Stow (SC-002, SC-003, FR-003)

Run against a throwaway `$HOME` so the real environment is untouched
(Principle II):

```bash
tmp="$(mktemp -d)"
# Simulate a conflict: a real file where a package symlink should be
mkdir -p "$tmp/.local/bin"
echo "not a symlink" > "$tmp/.local/bin/alias-manager"
HOME="$tmp" dotfiles-doctor --only stow ; echo "exit=$?"
rm -rf "$tmp"
```

Expected:
- Stow category shows FAIL for `scripts` (conflict, names the path + `stow -R`
  hint).
- `exit=1`.

## Scenario 3 — Missing secret (FR-006, FR-011)

```bash
# A bogus reference should FAIL when pass is available…
pass show does/not/exist >/dev/null 2>&1 ; echo "pass rc=$?"
dotfiles-doctor --only secrets ; echo "exit=$?"
```

Expected:
- If `pass` is available: each referenced path that resolves → OK; a missing one
  → FAIL naming the path; overall `exit=1` only if a real reference fails.
- If `pass` is NOT available: Secrets category → WARN, `exit=0`.

## Scenario 4 — Cross-platform (SC-004, FR-005)

Run on both an Arch and a macOS machine:

```bash
dotfiles-doctor --only tools ; echo "exit=$?"
```

Expected:
- Tool set matches the detected OS; no Linux-only items (systemd, docker group)
  are reported as failures on macOS.
- Missing *optional* tools → WARN (exit stays 0); missing *critical* tools →
  FAIL (exit 1).

## Scenario 5 — Pipe safety & read-only (FR-012)

```bash
dotfiles-doctor | cat            # no color codes, clean text
git -C "$DOTFILES_DIR" status    # working tree unchanged after any run
```

Expected: plain output when piped; `git status` shows no modifications caused by
running the doctor.

## Reference

- Interface details: [contracts/cli.md](./contracts/cli.md)
- Entity/status rules: [data-model.md](./data-model.md)
- Technical decisions: [research.md](./research.md)
