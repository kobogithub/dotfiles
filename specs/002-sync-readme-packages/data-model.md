# Data Model: Sync README Package List with install.sh

No persistent storage — same as the base `dotfiles-doctor` tool this feature
extends (see `specs/001-dotfiles-doctor/data-model.md` for the `Check` and
`Category` entities this feature reuses unchanged). This document only adds
the entities and rules introduced by the new `docs` category.

## Entity: DocumentedPackage

A package name as it appears in `README.md`'s `## 📁 Estructura` fenced block.

| Field | Type | Notes |
|-------|------|-------|
| name | string | e.g. `zsh`, `ghostty` — stripped of tree-drawing chars, trailing `/`, and the `# comment` |
| line | string | The full original tree line, kept only for error messages/debugging, not compared |

**Rules**:
- Only lines representing a directory (trailing `/` before the comment) count
  as a package; `install.sh` and `README.md` themselves, listed in the same
  block as files, are excluded (US1 edge case).

## Entity: InstalledPackage

A package name as it appears in `DOTFILE_PACKAGES` in `install.sh`. Identical
in shape to the `Package.name` field already defined in
`specs/001-dotfiles-doctor/data-model.md` — this feature does not redefine it,
it reuses the existing `parse_dotfile_packages` output verbatim as the
comparison's other side.

## Entity: Category (extended)

Extends the existing `Category` entity (`specs/001-dotfiles-doctor/data-model.md`)
with a fourth member.

| Field | Type | Notes |
|-------|------|-------|
| name | enum | `Stow` \| `Tools` \| `Secrets` \| **`Docs`** (new) |
| rollup | enum | Same severity rule: FAIL > WARN > OK (docs never emits FAIL — see rule below) |

**Rules**:
- The `Docs` category only ever reports `OK` or `WARN`, never `FAIL` — a
  documentation mismatch doesn't break anyone's install (spec FR-004,
  Acceptance Scenario 4), so it can't push the overall exit code to `1` by
  itself.
- One `WARN` check is emitted per package name found on only one side of the
  comparison, naming both the package and which source (README vs
  `DOTFILE_PACKAGES`) it's missing from.
- If both lists match exactly (including the empty-diff case), a single `OK`
  check is emitted for the category rather than one per package, mirroring how
  `check_secrets` reports a single OK when there are no secret refs at all.

## Status severity ordering

Unchanged from `specs/001-dotfiles-doctor/data-model.md`:

```
FAIL  (2)  →  non-zero exit, red ❌   (never emitted by Docs)
WARN  (1)  →  exit 0,       yellow ⚠️
OK    (0)  →  exit 0,       green ✅
```
