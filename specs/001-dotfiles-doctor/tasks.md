---
description: "Task list for dotfiles-doctor implementation"
---

# Tasks: dotfiles-doctor

**Input**: Design documents from `/specs/001-dotfiles-doctor/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cli.md, quickstart.md

**Tests**: No automated test suite requested. Validation is via static checks
(`bash -n`, `shellcheck`) and the runnable scenarios in `quickstart.md`, per
Constitution Principle V. Test tasks below are validation tasks, not a TDD suite.

**Organization**: Tasks grouped by user story. Note: this feature is a single
self-contained Bash script (`scripts/.local/bin/dotfiles-doctor`), so most
implementation tasks touch the **same file** and therefore run **sequentially**
(few `[P]` markers). Parallelism is mostly in the docs/polish phase.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 / US2 / US3 (maps to spec.md user stories)
- Exact file paths included

## Path Conventions

- Script: `scripts/.local/bin/dotfiles-doctor` (Stow package `scripts` → `~/.local/bin/`)
- Docs: `scripts/README.md`, `CLAUDE.md`, `AGENTS.md` at repo root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the script skeleton and shared scaffolding.

- [x] T001 Create `scripts/.local/bin/dotfiles-doctor` with `#!/bin/bash`, header comment (name/usage), `set -e` + `set -o pipefail`, and `chmod +x`
- [x] T002 Add repo-root resolution to `scripts/.local/bin/dotfiles-doctor` — the `DOTFILES_DIR` ladder calqued from `scripts/.local/bin/alias-manager` (`$HOME/.dotfiles` → `$HOME/github/dotfiles` → derive from `BASH_SOURCE`)
- [x] T003 Add the tput color block to `scripts/.local/bin/dotfiles-doctor` guarded by `command -v tput` + `[ -t 1 ]` (GREEN/YELLOW/RED/BOLD/NC), plus ✅/⚠️/❌ emoji constants

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The status/reporting engine and CLI surface that ALL categories use.

**⚠️ CRITICAL**: No category check can be implemented until this phase is done.

- [x] T004 Implement the reporting core in `scripts/.local/bin/dotfiles-doctor`: `report_check <category> <status> <item> <message>` that prints the emoji line (respecting `--quiet` for OK) and increments `fail_count` / `warn_count` integer globals (Bash 3.2-safe, no associative arrays)
- [x] T005 Implement `detect_os` in `scripts/.local/bin/dotfiles-doctor` mirroring `install.sh` (darwin→`macos`, `/etc/arch-release`→`arch`, else `other`)
- [x] T006 Implement CLI arg parsing + `show_help` in `scripts/.local/bin/dotfiles-doctor`: `-h/--help` (exit 0), `-q/--quiet`, `--only <stow|tools|secrets>`, unknown option → usage to stderr + exit 2 (per contracts/cli.md)
- [x] T007 Implement the final verdict logic in `scripts/.local/bin/dotfiles-doctor`: per-category rollup (worst status), `print_summary`, and exit `1` iff `fail_count > 0` else `0` (data-model.md severity ordering, SC-003)

**Checkpoint**: The harness runs, prints a header + (empty) summary, and exits 0.

---

## Phase 3: User Story 1 - Verify the installation is healthy (Priority: P1) 🎯 MVP

**Goal**: One command that checks Stow health across all `DOTFILE_PACKAGES`,
prints a categorized summary, and returns a correct pass/fail exit code.

**Independent Test**: On a healthy tree, `dotfiles-doctor` reports Stow OK and
exits 0; replace a package symlink with a real file and it reports Stow FAIL and
exits non-zero.

- [x] T008 [US1] Implement `parse_dotfile_packages` in `scripts/.local/bin/dotfiles-doctor` — extract the `DOTFILE_PACKAGES=( … )` array from `install.sh` (strip comments/quotes; FAIL the Stow category if unreadable) per research R1
- [x] T009 [US1] Implement per-package symlink verification in `scripts/.local/bin/dotfiles-doctor`: for each package, `find "$pkg" -type f`, map `pkg/rel` → `$HOME/rel`, and classify target as linked-OK vs broken via `readlink` (research R2) — emit one `report_check stow …` per package
- [x] T010 [US1] Wire the Stow category and overall run in `scripts/.local/bin/dotfiles-doctor` so a no-arg invocation runs Stow + summary and returns the right exit code

**Checkpoint**: MVP — healthy machine → all-OK exit 0; broken symlink → FAIL exit 1.

---

## Phase 4: User Story 2 - Understand what is wrong and how to fix it (Priority: P2)

**Goal**: Non-OK output names the exact item and gives a remediation hint;
distinguishes not-stowed vs conflict vs dangling; adds the Secrets category.

**Independent Test**: Break a symlink, remove a tool, and point a secret at a
bad path — each failing line identifies the item and includes a fix hint.

- [x] T011 [US2] Enrich Stow classification in `scripts/.local/bin/dotfiles-doctor` to distinguish `not stowed` / `conflict (real file or foreign symlink)` / `dangling` / missing-`repo_dir`, each with a specific message + hint (e.g. `→ run: stow -R <pkg>`) per data-model.md + FR-003/FR-010
- [x] T012 [US2] Implement `parse_secret_refs` in `scripts/.local/bin/dotfiles-doctor` — textual scan of `zsh/.env` for `pass show <path>` (never source the file; research R4)
- [x] T013 [US2] Implement the Secrets category in `scripts/.local/bin/dotfiles-doctor`: verify each ref with `pass show "<path>" >/dev/null 2>&1` (OK/FAIL naming the path, never the value); degrade whole category to WARN if `pass` unavailable (FR-011)

**Checkpoint**: US1 + US2 — every failure is specific and actionable; Secrets checked.

---

## Phase 5: User Story 3 - Works the same on Arch and macOS (Priority: P3)

**Goal**: OS-adaptive Tools category — check the expected binaries for the
detected OS, skip Linux-only notions on macOS, degrade on `other`.

**Independent Test**: Run `--only tools` on Arch and on macOS; each checks the
right set and no Linux-only item is flagged on macOS.

- [x] T014 [US3] Define the critical vs optional tool lists in `scripts/.local/bin/dotfiles-doctor` (research R3), normalizing package→binary names (`neovim`→`nvim`, `github-cli`→`gh`, `nodejs`→`node`)
- [x] T015 [US3] Implement the Tools category in `scripts/.local/bin/dotfiles-doctor`: `command -v <bin>` per tool → critical missing = FAIL, optional missing = WARN; on `other` skip the OS set with a WARN (FR-004/FR-005, edge case)

**Checkpoint**: All three categories functional and platform-appropriate.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validation and honest documentation (Constitution Principle V + doc rule).

- [x] T016 Static validation: `bash -n scripts/.local/bin/dotfiles-doctor` and `shellcheck scripts/.local/bin/dotfiles-doctor` — fix findings
- [x] T017 Run the `quickstart.md` scenarios (healthy run, broken-Stow temp-`$HOME` run, secrets, pipe-safety) and confirm exit codes match
- [x] T018 `stow -R -d . -t $HOME scripts` to link the new script, then confirm `dotfiles-doctor` runs from any directory
- [x] T019 [P] Document `dotfiles-doctor` in `scripts/README.md`
- [x] T020 [P] Update `CLAUDE.md` (validation/commands section) and `AGENTS.md` if needed to mention `dotfiles-doctor`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational.
  - US1 is the MVP. US2 enriches US1's Stow output and adds Secrets. US3 adds Tools.
  - US2 and US3 are independent of each other (different categories) and could be
    done in either order after US1's engine exists.
- **Polish (Phase 6)**: After the desired stories are complete.

### Within the script (single file)

- T001→T002→T003 sequential (same file, foundational scaffolding).
- Phase 2 sequential (all edit the same file's shared helpers).
- T008→T009→T010 sequential (Stow builds on package parsing).
- T011 depends on T009; T012→T013 sequential; T013 depends on T012.
- T014→T015 sequential.

### Parallel Opportunities

- Genuine parallelism is limited because the implementation is one file.
- **T019 and T020 are `[P]`** — different files (`scripts/README.md` vs
  `CLAUDE.md`/`AGENTS.md`), no shared edits.
- Conceptually, once Phase 2 is done, the US2 (Secrets) and US3 (Tools) category
  functions are independent and could be authored by different people, but they
  land in the same file so coordinate the merge.

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1: Setup (T001–T003)
2. Phase 2: Foundational engine (T004–T007) — CRITICAL
3. Phase 3: US1 Stow health (T008–T010)
4. **STOP and VALIDATE**: healthy → exit 0; broken symlink → exit 1
5. This alone is a usable tool.

### Incremental Delivery

1. Setup + Foundational → harness runs
2. + US1 → **MVP**: Stow health check with correct verdict
3. + US2 → actionable hints + Secrets category
4. + US3 → cross-platform Tools category
5. Polish → validate + document, then `stow -R scripts` and commit

---

## Notes

- Single-file Bash tool: prefer small documented `snake_case` functions over
  splitting files; keep Bash 3.2 compatibility (no `mapfile`, no assoc arrays).
- `[P]` only on the two doc tasks (different files).
- Read-only guarantee (FR-012) must hold — no task may create/modify symlinks or
  install anything; the broken-tree test uses a temp `$HOME`.
- Commit after logical groups; validate with `bash -n`/`shellcheck` before commit
  (Principle V).
