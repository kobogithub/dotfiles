# Implementation Plan: Sync README Package List with install.sh

**Branch**: `002-sync-readme-packages` | **Date**: 2026-07-16 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-sync-readme-packages/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Fix the current drift between `README.md`'s documented package list and the real
`DOTFILE_PACKAGES` array in `install.sh` (remove the nonexistent `devscripts`,
add `ghostty`/`herdr`), then extend `dotfiles-doctor` with a fourth read-only
category (`docs`) that diffs the two lists on every run and WARNs by name on
any future divergence. No new dependencies: reuses the script's existing
`parse_dotfile_packages` extractor and `report_check`/`bump_category`/
`print_summary` reporting engine, adding one symmetric parser for README plus
a small portable set-diff (the script targets Bash 3.2 for macOS, so no
associative arrays or GNU-only `comm`).

## Technical Context

**Language/Version**: Bash, 3.2-compatible (macOS ships an old bash; see existing `resolve_link` comment in `dotfiles-doctor`)

**Primary Dependencies**: Coreutils already used elsewhere in the script (`awk`, `sed`, `grep`, `tr`) — no new external tools

**Storage**: N/A — reads `README.md` and `install.sh` as plain text on each invocation; no persisted state

**Testing**: `bash -n`, `shellcheck` (if installed), manual `dotfiles-doctor --only docs` runs against both a synced and a deliberately-desynced README — same validation approach as the rest of this repo (no test framework in-repo)

**Target Platform**: Arch Linux + macOS (same as the rest of the repo; the check is pure text parsing so it has no OS-specific branch)

**Project Type**: Single-file CLI tool extension (`scripts/.local/bin/dotfiles-doctor`)

**Performance Goals**: Negligible — parses two small text files (~20 package entries); must not perceptibly slow down `dotfiles-doctor`'s existing sub-second run time

**Constraints**: Read-only (Principle II / FR-005); Bash 3.2 compatible; no new runtime dependency; must reuse the existing category/report engine rather than introduce a parallel output format (FR-006)

**Scale/Scope**: ~20 packages today (`DOTFILE_PACKAGES`); parser and diff must handle that comfortably with simple linear loops, no need for indexed/associative-array tricks

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|---|---|---|
| I. Stow Is the Single Source of Truth | Feature makes docs match `DOTFILE_PACKAGES`, not the other way around; doesn't touch stow linking itself | PASS |
| II. Installs Are Idempotent and Reversible | New check is read-only, no file writes, safe to run any number of times | PASS |
| III. Cross-Platform by Detection, Not Assumption | Parsing is plain-text, identical on Arch/macOS; no OS branch needed | PASS |
| IV. Secrets Never Enter the Repo | Not applicable — no secrets involved | PASS |
| V. Validate Before Commit (NON-NEGOTIABLE) | `bash -n` + `shellcheck` + manual run required before commit, per existing workflow | PASS (process gate, applied at implementation/commit time) |
| Shell Script Standards | New functions follow existing `snake_case`, quoting, `[[ ]]`, emoji-output conventions already in the file | PASS |

No violations — Complexity Tracking section is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/002-sync-readme-packages/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   └── cli.md
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
README.md                              # Fix: remove devscripts, add ghostty/herdr (US1)
scripts/.local/bin/dotfiles-doctor      # Extend: new `docs` category (US2)
```

**Structure Decision**: This is a documentation fix plus a same-file extension
of an existing single-script CLI tool — no new project, package, or directory.
Both touched paths already exist: `README.md` at the repo root, and
`scripts/.local/bin/dotfiles-doctor` inside the existing `scripts` Stow
package (unchanged package boundary — `scripts` is already in
`DOTFILE_PACKAGES`, so no restow is needed beyond the normal edit-in-repo
workflow since the file is reached via its existing symlink).

## Complexity Tracking

Not applicable — no Constitution Check violations.
