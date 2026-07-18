---
description: "Task list for Sync README Package List with install.sh"
---

# Tasks: Sync README Package List with install.sh

**Input**: Design documents from `/specs/002-sync-readme-packages/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cli.md, quickstart.md

**Tests**: No automated test suite requested. Validation is via static checks
(`bash -n`, `shellcheck`) and the runnable scenarios in `quickstart.md`, per
Constitution Principle V. There are no test tasks below beyond those
validation steps.

**Organization**: Tasks grouped by user story. US1 touches only `README.md`;
US2 touches only `scripts/.local/bin/dotfiles-doctor` (reusing the
`report_check`/`bump_category`/`print_summary` engine already built in
`001-dotfiles-doctor`) — the two stories are independent and can be done in
either order, though P1→P2 is the natural sequence.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1 / US2 (maps to spec.md user stories)
- Exact file paths included

## Path Conventions

- Docs: `README.md` at repo root
- Script: `scripts/.local/bin/dotfiles-doctor` (Stow package `scripts` → `~/.local/bin/`)

---

## Phase 1: Setup

Not applicable — both target files already exist; no new scaffolding, package,
or dependency is introduced.

## Phase 2: Foundational

Not applicable — this feature reuses the reporting engine
(`report_check`/`bump_category`/`print_summary`) already implemented in
`001-dotfiles-doctor`. Nothing blocks either user story from starting.

---

## Phase 3: User Story 1 - Correct the current documentation drift (Priority: P1) 🎯 MVP

**Goal**: `README.md`'s package list matches `DOTFILE_PACKAGES` in `install.sh`
exactly — no `devscripts`, includes `ghostty` and `herdr`.

**Independent Test**: Diff every package name in `README.md`'s "📁 Estructura"
block against `DOTFILE_PACKAGES`; the two sets are identical.

- [X] T001 [US1] Remove the `devscripts/` line from the "📁 Estructura" fenced block in `README.md`
- [X] T002 [US1] Add `ghostty/` and `herdr/` entries to the "📁 Estructura" fenced block in `README.md`, one-line description each, matching the existing style (e.g. `# Configuración de <tool>`)
- [X] T003 [US1] Verify: every package name in `README.md`'s block and every entry in `DOTFILE_PACKAGES` (install.sh) match 1:1, per quickstart.md Scenario 1

**Checkpoint**: `README.md` accurately reflects what `install.sh` actually installs.

---

## Phase 4: User Story 2 - Detect future drift automatically (Priority: P2)

**Goal**: `dotfiles-doctor` gains a `docs` category that diffs `README.md`'s
package list against `DOTFILE_PACKAGES` and WARNs by name on any mismatch,
without ever FAILing or writing to either file.

**Independent Test**: Run `dotfiles-doctor --only docs` against a
deliberately-desynced copy of the repo (per quickstart.md Scenario 3) and
confirm it reports WARN naming the exact mismatched package(s), with exit 0.

- [X] T004 [US2] Add the `CAT_DOCS="OK"` global and extend `bump_category`'s category `case` statement to include `docs`, in `scripts/.local/bin/dotfiles-doctor`
- [X] T005 [US2] Implement `parse_readme_packages` in `scripts/.local/bin/dotfiles-doctor`: awk-isolate the "📁 Estructura" fenced block in `README.md`, keep only tree lines (`├──`/`└──`) whose entry ends in `/` (directories = packages, excluding `install.sh`/`README.md` file entries), strip the tree prefix, trailing `/`, and `# comment` (research.md Decision 1)
- [X] T006 [US2] Implement a portable `list_contains <list> <item>` helper in `scripts/.local/bin/dotfiles-doctor` for the Bash-3.2-safe membership check used by the diff (research.md Decision 2 — no associative arrays, no `comm`)
- [X] T007 [US2] Implement `check_docs` in `scripts/.local/bin/dotfiles-doctor`: diff `parse_readme_packages` output against the existing `parse_dotfile_packages` output using `list_contains`; emit one `report_check docs WARN <pkg> "..."` per package present on only one side (naming which source it's missing from, per contracts/cli.md), or a single `report_check docs OK` when the sets match exactly (depends on T004, T005, T006)
- [X] T008 [US2] Wire `docs` into the CLI surface of `scripts/.local/bin/dotfiles-doctor`: add `docs` to the `--only` enum validation, `show_help` text, the execution section (call `check_docs` alongside Stow/Tools/Secrets), and `print_summary`'s category list (depends on T007)

**Checkpoint**: `dotfiles-doctor --only docs` reports OK on a synced repo, WARN
naming the exact package(s) on drift, and never affects the process exit code
by itself.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T009 Static validation: `bash -n scripts/.local/bin/dotfiles-doctor` and `shellcheck scripts/.local/bin/dotfiles-doctor` — fix any findings
- [X] T010 Run all four `quickstart.md` scenarios and confirm output/exit codes match what's documented
- [X] T011 [P] Document the `docs` category in `scripts/README.md` (new category alongside Stow/Tools/Secrets)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup / Foundational**: N/A — no blocking prerequisites.
- **User Story 1 (Phase 3)**: No dependencies — can start immediately.
- **User Story 2 (Phase 4)**: No hard dependency on US1 (the parser/diff logic
  works regardless of README's current content), but doing US1 first means
  Scenario 2 in quickstart.md (OK on a synced repo) passes against the real
  `README.md` right away instead of only against a temp copy.
- **Polish (Phase 5)**: After both stories are complete.

### Within Each Story

- US1: T001 → T002 → T003 sequential (same file, `README.md`).
- US2: T004 → T005 → T006 → T007 → T008 sequential (same file,
  `scripts/.local/bin/dotfiles-doctor`; T007 needs all three of T004–T006,
  T008 needs T007).

### Parallel Opportunities

- Genuine parallelism is limited: US1 and US2 touch different files
  (`README.md` vs `scripts/.local/bin/dotfiles-doctor`) so could be done by
  different people in parallel, but each story's own tasks are sequential
  same-file edits.
- **T011 is `[P]`** relative to T009/T010 — different file (`scripts/README.md`).

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 3: US1 (T001–T003)
2. **STOP and VALIDATE**: `README.md` package list matches `DOTFILE_PACKAGES` exactly
3. This alone already fixes the reported bug — no code change required.

### Incremental Delivery

1. US1 → **MVP**: docs no longer lie about what gets installed
2. + US2 → drift becomes self-detecting via `dotfiles-doctor --only docs`
3. Polish → validate, document, commit

---

## Notes

- Single-file Bash tool edit for US2: keep Bash 3.2 compatibility (no
  associative arrays, no `comm`), matching the rest of `dotfiles-doctor`.
- `docs` category must never emit `FAIL` (data-model.md rule) — only `OK`/`WARN`.
- Read-only guarantee holds: no task may modify `install.sh`; `README.md` is
  only edited by US1's own tasks, never by the `dotfiles-doctor` check itself.
- Commit after each story; validate with `bash -n`/`shellcheck` before commit
  (Principle V).
