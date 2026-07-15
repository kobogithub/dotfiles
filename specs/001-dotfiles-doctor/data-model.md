# Data Model: dotfiles-doctor

The tool has no persistent storage. These are the in-memory/conceptual entities
that structure the diagnostic. In a Bash script they are represented as plain
variables and iteration, not structs — this document defines their shape and
rules so the implementation stays consistent.

## Entity: Check

A single diagnostic assertion — the atomic unit of output.

| Field | Type | Notes |
|-------|------|-------|
| category | enum | `stow` \| `tools` \| `secrets` |
| item | string | The subject: package name, tool binary, or `pass` path |
| status | enum | `OK` \| `WARN` \| `FAIL` |
| message | string | Human-readable result + remediation hint (FR-010) |

**Rules**:
- Every check MUST have exactly one status (FR-007).
- Non-`OK` checks MUST name `item` specifically and include a hint (FR-010).
- Emitting a check updates the running counters (`fail_count`, `warn_count`).

## Entity: Category

A named group of checks with a rolled-up status shown in the summary.

| Field | Type | Notes |
|-------|------|-------|
| name | enum | `Stow` \| `Tools` \| `Secrets` |
| rollup | enum | Worst status among its checks: FAIL > WARN > OK |
| prerequisite_ok | bool | e.g. Secrets requires `pass`; if false → category WARN |

**Rules**:
- Category rollup = the most severe check status it contains (FR-008).
- If a category's prerequisite is unavailable, the whole category degrades to
  `WARN` with an explanatory check rather than emitting misleading FAILs
  (FR-011).

## Entity: Package

An entry from `DOTFILE_PACKAGES` (parsed from `install.sh`); the unit of Stow
checks.

| Field | Type | Notes |
|-------|------|-------|
| name | string | e.g. `zsh`, `scripts` |
| repo_dir | path | `$DOTFILES_DIR/<name>` |
| files | path[] | Tracked files under `repo_dir` (`find -type f`) |

**Derived per-file classification** (R2):

| Target state under `$HOME` | Result |
|----------------------------|--------|
| symlink → matching repo file | `OK` |
| missing | `FAIL` (not stowed) |
| regular file / foreign symlink | `FAIL` (conflict) |
| symlink → repo file that no longer exists (dangling) | `FAIL` |

**Rules**:
- A package whose `repo_dir` is missing but is listed in `DOTFILE_PACKAGES` →
  `FAIL` (manifest/repo disagreement, edge case).
- Package rollup follows the worst per-file result.

## Entity: SecretRef

A `pass` reference extracted from `zsh/.env`; the unit of Secrets checks.

| Field | Type | Notes |
|-------|------|-------|
| pass_path | string | e.g. `mcps/context7` |
| source_var | string | The env var it populates (context only, not printed as value) |

**Rules**:
- Verified via `pass show "<pass_path>" >/dev/null 2>&1` — resolution success →
  `OK`, failure → `FAIL` naming the path (never the value).
- If `pass`/GPG is unavailable, all SecretRefs degrade to the category-level
  `WARN` (do not probe).

## Status severity ordering

```
FAIL  (2)  →  non-zero exit, red ❌
WARN  (1)  →  exit 0,       yellow ⚠️
OK    (0)  →  exit 0,       green ✅
```

Overall exit code = `1` iff `fail_count > 0`, else `0` (SC-003).
