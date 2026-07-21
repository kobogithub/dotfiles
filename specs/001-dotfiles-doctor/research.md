# Research: dotfiles-doctor

Phase 0 technical decisions. No `NEEDS CLARIFICATION` markers remained in the
spec; the items below resolve *how* to implement each requirement.

## R1 — Source of the package list (`DOTFILE_PACKAGES`)

- **Decision**: Parse the `DOTFILE_PACKAGES=( … )` array out of `install.sh` at
  runtime by reading the file, rather than re-declaring the list in the doctor.
- **Rationale**: FR-001 demands the check never drift from what is installed.
  A duplicated list would rot. Extracting from the single source of truth keeps
  them coupled.
- **How**: Locate the repo root (R6), then read the block between
  `DOTFILE_PACKAGES=(` and the closing `)`, stripping comments (`# …`) and
  quotes. `awk`/`sed` range extraction is Bash-3.2 safe. Guard: if the array
  can't be parsed, emit a single FAIL for the Stow category ("cannot read
  DOTFILE_PACKAGES from install.sh").
- **Alternatives considered**: (a) `source install.sh` — rejected: it has
  top-level side effects (echoes, `cd`, arg parsing, even package installs).
  (b) Hardcode the list — rejected: violates FR-001.

## R2 — Detecting correct vs. conflicting vs. not-stowed

- **Decision**: For each package, enumerate its tracked files (the files under
  `scripts/…` etc. that Stow would link), compute each one's target path under
  `$HOME`, and classify the target:
  - target is a symlink resolving (via `readlink`) into the repo package file →
    **OK**
  - target does not exist → **not stowed** (FAIL, unless the whole package is
    uniformly absent → still FAIL per FR-003; reported as "not stowed")
  - target exists but is a regular file, or a symlink pointing elsewhere →
    **conflict** (FAIL)
  - target is a symlink into the repo but dangling (repo file missing) → FAIL
- **Rationale**: Directly satisfies FR-002/FR-003 and the edge cases (dangling,
  foreign symlink, real-file shadow).
- **How**: `find "$pkg" -type f` to list package files; map `pkg/rel/path` →
  `$HOME/rel/path`; compare `readlink -f`/`readlink` of the target against the
  absolute repo path. Use plain `find` + `while read` (Bash 3.2 safe; no
  `mapfile`). Account for `--no-folding` (install.sh stows with `--no-folding`,
  so each file is linked individually, not the directory) — checking per-file is
  exactly right.
- **Alternatives considered**: `stow -n -R <pkg>` dry-run parsing — rejected as
  the primary mechanism because its output is about *actions to take*, not a
  clean OK/conflict classification, and it's noisier to parse portably. May be
  used as a secondary signal but per-file `readlink` is the contract.

## R3 — Which tools to check per OS

- **Decision**: Derive the expected tool set from `install.sh`'s package arrays,
  mapped to their runtime binary names, split by criticality:
  - **Critical (FAIL if missing)**: `stow`, `git`, `zsh`, `nvim`, `tmux`,
    `starship`, `atuin`, `jq`, plus `pass` handled under Secrets.
  - **Optional (WARN if missing)**: `lsd`, `kubectl`, `k9s`, `docker`,
    `docker-compose`, `node`, `yarn`, `htop`, `tree`, `code`/`gh`.
  - Package name ≠ binary name is normalized (Arch `github-cli`→`gh`,
    `neovim`→`nvim`, `nodejs`→`node`; macOS already uses `gh`, `node`).
- **Rationale**: FR-004/FR-005. Critical = things the shell/dotfiles actively
  depend on to function; optional = nice-to-have dev tooling whose absence
  doesn't break the environment (maps to WARN, keeping exit 0 per SC-001/edge).
- **How**: `command -v <bin> >/dev/null 2>&1` per tool (Principle III: no
  absolute paths). On `macos`, skip systemd/docker-group notions entirely. On
  `other`, skip the OS-specific tool set with a WARN (edge case).
- **Alternatives considered**: Re-parse `SYSTEM_PACKAGES`/`BREW_PACKAGES` arrays
  for the exact list — rejected as over-coupling: those are *install* manifests
  with package-manager names; a curated binary list keyed by criticality is more
  accurate for a *health* check. The curated list is documented in data-model.md
  so it stays reviewable.

## R4 — Parsing secret references from `zsh/.env`

- **Decision**: Textually scan `zsh/.env` for the documented pattern
  `pass show <path>` (inside `export VAR="$(pass show <path>)"`), collect each
  `<path>`, and verify with `pass show "<path>" >/dev/null 2>&1`.
- **Rationale**: FR-006. Constitution Principle IV forbids executing the env
  file or printing secret values; a textual scan + existence probe reads nothing
  sensitive into output.
- **How**: `grep -oE 'pass show [^")]+'` then trim; for each, run `pass show`
  discarding stdout. Currently `zsh/.env` references `mcps/context7`.
- **Degradation** (FR-011, edge case): if `pass` is not installed or the GPG
  agent can't unlock, report the whole Secrets category as **WARN**
  ("pass unavailable — cannot verify secrets"), not FAIL.
- **Alternatives considered**: `source zsh/.env` and inspect the vars — rejected:
  executes arbitrary code and would leak values; violates Principle IV.

## R5 — Status model, output, and exit code

- **Decision**: Three statuses `OK`/`WARN`/`FAIL`. Per-check line with emoji
  (✅/⚠️/❌ per the repo convention) + item + hint. Per-category rollup =
  worst status in the category. Overall exit code: `1` if any check is FAIL,
  else `0` (WARN does not fail the run).
- **Rationale**: FR-007/008/009/010, SC-003. WARN-doesn't-fail makes the tool
  usable as a CI/script gate that only trips on real breakage.
- **How**: tput colors guarded by `[ -t 1 ]` (calqued from `alias-manager`), so
  output is clean when piped/redirected. Track counts with plain integer vars
  (Bash 3.2: no associative arrays) — e.g. `fail_count`, `warn_count`.

## R6 — Locating the repo root

- **Decision**: Resolve `DOTFILES_DIR` with the same ladder `alias-manager`
  uses: prefer `$HOME/.dotfiles`, then `$HOME/github/dotfiles`, else derive from
  the script's own location (`.../scripts/.local/bin/dotfiles-doctor` → four
  levels up).
- **Rationale**: FR-013 / SC (works regardless of clone location). Reusing the
  existing, proven pattern keeps the two scripts consistent.
- **How**: Copy the resolution block from `scripts/.local/bin/alias-manager`
  (lines 6–13). When invoked via the symlink in `~/.local/bin`, `BASH_SOURCE`
  resolution still lands in the repo because the symlink target is the repo file.

## R7 — Testing approach

- **Decision**: Static (`bash -n`, `shellcheck`) + a scripted end-to-end check
  that (a) runs against the real healthy tree expecting exit 0 and all-OK, and
  (b) builds a throwaway broken fixture (a foreign file shadowing a package
  target, a bogus secret path) in a temp `$HOME` to assert FAIL + non-zero exit.
- **Rationale**: Principle V (validate before commit); SC-002/SC-003 require
  proving both the healthy and broken paths.
- **How**: Documented as runnable steps in quickstart.md; the broken-tree run
  uses a temp dir as `HOME` so it never touches the real environment (Principle
  II — no side effects).
