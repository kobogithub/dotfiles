# Quickstart & Validation: Sync README Package List with install.sh

End-to-end validation guide, covering both the doc fix (US1) and the new
`docs` drift check (US2) — the healthy path and the deliberately-broken path,
without touching the real environment for the broken case.

## Prerequisites

- Repo cloned and the `scripts` package stowed (same as
  `specs/001-dotfiles-doctor/quickstart.md`).
- No new tools required beyond what `dotfiles-doctor` already needs (`awk`,
  `sed`, `grep`, `tr`).

## Static validation (Principle V — before commit)

```bash
bash -n scripts/.local/bin/dotfiles-doctor      # syntax
shellcheck scripts/.local/bin/dotfiles-doctor   # lint (if installed)
```

Expected: no syntax errors; shellcheck clean (or only justified suppressions).

## Scenario 1 — Current drift is fixed (US1, SC-001)

```bash
grep -n 'devscripts' README.md ; echo "grep rc=$?"
grep -n 'ghostty\|herdr' README.md
```

Expected:
- First `grep` finds nothing → `rc=1` (no more `devscripts` in `README.md`).
- Second `grep` finds both `ghostty` and `herdr` listed.

## Scenario 2 — Docs category reports OK on a synced repo (US2, SC-002)

```bash
dotfiles-doctor --only docs ; echo "exit=$?"
```

Expected:
- `Docs` category prints a single OK line (README matches `DOTFILE_PACKAGES`).
- `exit=0`.

## Scenario 3 — Docs category catches a deliberately-introduced drift (US2, SC-003)

Run against a throwaway copy of the repo so the real `README.md` is untouched
(Principle II):

```bash
tmp="$(mktemp -d)"
cp -r "$DOTFILES_DIR" "$tmp/dotfiles"
# Simulate drift: add a phantom package (via awk — portable across GNU/BSD sed), remove a real one
awk '{print} /Configuración de Git/{print "├── phantom-pkg/            # No existe en DOTFILE_PACKAGES"}' \
  "$tmp/dotfiles/README.md" > "$tmp/dotfiles/README.md.new" && mv "$tmp/dotfiles/README.md.new" "$tmp/dotfiles/README.md"
sed -i.bak '/"ghostty"/d' "$tmp/dotfiles/install.sh"
HOME="$tmp" "$tmp/dotfiles/scripts/.local/bin/dotfiles-doctor" --only docs ; echo "exit=$?"
rm -rf "$tmp"
```

Expected:
- `Docs` category reports WARN for `phantom-pkg` (in README, not in
  `DOTFILE_PACKAGES`) and WARN for `ghostty` (in `DOTFILE_PACKAGES`, not in
  README).
- `exit=0` — a docs WARN never fails the run (FR-004, data-model.md rule).

## Scenario 4 — Pipe safety & read-only (unchanged guarantee)

```bash
dotfiles-doctor --only docs | cat     # no color codes, clean text
git -C "$DOTFILES_DIR" status         # working tree unchanged after any run
```

Expected: plain output when piped; `git status` shows no modifications caused
by running the doctor.

## Reference

- Interface details (delta): [contracts/cli.md](./contracts/cli.md)
- Entity/status rules (delta): [data-model.md](./data-model.md)
- Technical decisions: [research.md](./research.md)
- Base tool contract/data model: `specs/001-dotfiles-doctor/`
