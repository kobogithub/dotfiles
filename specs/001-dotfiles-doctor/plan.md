# Implementation Plan: dotfiles-doctor

**Branch**: `001-dotfiles-doctor` | **Date**: 2026-07-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-dotfiles-doctor/spec.md`

## Summary

A read-only diagnostic CLI, `dotfiles-doctor`, that reports the health of the
dotfiles installation across three categories — **Stow** (every package in
`DOTFILE_PACKAGES` is symlinked into `$HOME` and points back into the repo),
**Tools** (the key tools expected for the detected OS are installed), and
**Secrets** (every `pass` entry referenced in `zsh/.env` resolves). It prints an
`OK`/`WARN`/`FAIL` line per check plus a per-category and overall summary, and
exits non-zero if any check is `FAIL`. It is a Bash script shipped in the
`scripts` package at `scripts/.local/bin/dotfiles-doctor`, reusing the repo's
existing conventions (`detect_os`, `DOTFILES_DIR` resolution, tput colors).

## Technical Context

**Language/Version**: Bash, compatible with macOS system Bash 3.2 (no `mapfile`,
no associative arrays, no `set -u` on empty-array expansion)

**Primary Dependencies**: GNU Stow, `pass` (optional — degrades to WARN),
coreutils (`readlink`, `find`); reuses logic mirrored from `install.sh`
(`detect_os`, `DOTFILE_PACKAGES`)

**Storage**: N/A — read-only; reads `install.sh`, `zsh/.env`, and the filesystem

**Testing**: `bash -n` + `shellcheck` for static checks; manual/scripted
end-to-end runs on a healthy tree and on a deliberately broken tree (see
quickstart.md)

**Target Platform**: Arch Linux and macOS (behavior chosen at runtime via
`detect_os`); `other` degrades gracefully

**Project Type**: CLI tool (single Bash script in the `scripts` Stow package)

**Performance Goals**: Full run completes in a few seconds on a typical machine;
suitable for habitual interactive use after installs

**Constraints**: Strictly read-only (no symlink/package/state mutation);
self-contained single file; no network calls

**Scale/Scope**: ~20 packages, ~20 tools, a handful of secret references — small
fixed inputs

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Compliance |
|-----------|------------|
| I. Stow is single source of truth | ✅ Ships inside the `scripts` package at `scripts/.local/bin/dotfiles-doctor` (mirrors `~/.local/bin/dotfiles-doctor`). No new package, so `DOTFILE_PACKAGES` is unchanged. The tool *validates* Stow correctness; it never creates symlinks. |
| II. Installs idempotent & reversible | ✅ Read-only diagnostic — no state change, infinitely re-runnable, nothing to reverse. |
| III. Cross-platform by detection | ✅ Uses `detect_os` (arch/macos/other) to pick the expected tool set and to skip Linux-only checks (systemd, docker group) on macOS. No hardcoded absolute paths — tools resolved via `command -v`. |
| IV. Secrets never in repo | ✅ Parses the `export VAR="$(pass show <path>)"` pattern in `zsh/.env` textually; verifies resolution via `pass show <path> >/dev/null`. Never prints secret values, never writes them anywhere. |
| V. Validate before commit | ✅ Script authored with `set -e`/`set -o pipefail`, quoted expansions, `[[ ]]`, `command -v` guards, emoji message convention; validated with `bash -n` + `shellcheck` + real runs before commit. |
| Shell Script Standards | ✅ Shebang, snake_case documented functions, UPPERCASE constants, Bash 3.2-safe constructs. |

**Result**: PASS — no violations, Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-dotfiles-doctor/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 — technical decisions
├── data-model.md        # Phase 1 — Check/Category/Package/SecretRef entities
├── quickstart.md        # Phase 1 — end-to-end validation guide
├── contracts/
│   └── cli.md           # Phase 1 — CLI contract (args, output, exit codes)
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 — created by /speckit-tasks (not here)
```

### Source Code (repository root)

```text
scripts/
├── .local/
│   └── bin/
│       ├── alias-manager      # existing (style/DOTFILES_DIR-resolution reference)
│       └── dotfiles-doctor    # NEW — the diagnostic tool
└── README.md                  # updated: document dotfiles-doctor
```

**Structure Decision**: Single self-contained Bash script added to the existing
`scripts` Stow package. No new package (Principle I: `DOTFILE_PACKAGES` untouched;
`stow -R scripts` picks up the new file). `scripts/README.md`, `CLAUDE.md`, and
`AGENTS.md` are updated in the same change per the documentation-honesty rule.

## Complexity Tracking

> No constitution violations — section intentionally empty.
