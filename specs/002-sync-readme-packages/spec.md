# Feature Specification: Sync README Package List with install.sh

**Feature Branch**: `002-sync-readme-packages`

**Created**: 2026-07-16

**Status**: Draft

**Input**: User description: "Sincronizar el listado de paquetes documentado en README.md (y CLAUDE.md si aplica) con la fuente de verdad real, que es el array DOTFILE_PACKAGES en install.sh. Hoy README.md lista un paquete 'devscripts/' que no existe en el repo ni en install.sh, y no menciona los paquetes 'ghostty' y 'herdr' que sí existen en DOTFILE_PACKAGES. El objetivo es corregir el drift actual y, si es razonable, dejar una forma de detectar automáticamente futuros drifts (por ejemplo como chequeo adicional en dotfiles-doctor), para cumplir el principio de la constitución 'Documentation stays honest'."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Correct the current documentation drift (Priority: P1)

The repo owner (or anyone cloning the repo for the first time) reads `README.md` to understand which tools get installed and configured. Today it lists a `devscripts/` package that does not exist anywhere in the repository, and omits `ghostty` and `herdr`, which are real, installed packages. A reader following the README gets a wrong picture of what `./install.sh` actually does.

**Why this priority**: This is the actual bug — stale documentation actively misleads. It must be fixed before anything else in this feature has value.

**Independent Test**: Diff the package list in `README.md`'s structure section against `DOTFILE_PACKAGES` in `install.sh`; after the fix, every entry in one list has a corresponding entry in the other, with no extras and no omissions.

**Acceptance Scenarios**:

1. **Given** `README.md` currently lists `devscripts/` as a package, **When** the fix is applied, **Then** `devscripts/` no longer appears anywhere in `README.md`.
2. **Given** `install.sh` defines `ghostty` and `herdr` in `DOTFILE_PACKAGES`, **When** the fix is applied, **Then** both appear in `README.md`'s package structure list with an accurate one-line description.
3. **Given** the corrected `README.md`, **When** every package name in its structure list is compared against `DOTFILE_PACKAGES`, **Then** the two sets are identical.

---

### User Story 2 - Detect future drift automatically (Priority: P2)

The repo owner adds, renames, or removes a stow package over time (as already happened with `ghostty`, `herdr`, and the since-removed `devscripts`). Without an automated check, `README.md` silently goes stale again the next time a package changes, repeating the exact problem User Story 1 fixes.

**Why this priority**: Fixing today's drift without a way to catch tomorrow's drift only delays the same bug. This is the second most valuable slice because it makes the fix durable, but the repo is still correct without it (P1 alone already delivers value).

**Independent Test**: Run `dotfiles-doctor` against a deliberately-desynced README (e.g. temporarily add a phantom package to the README or remove a real one) and confirm it reports a WARN identifying the exact mismatch, without modifying any file.

**Acceptance Scenarios**:

1. **Given** `README.md`'s package list matches `DOTFILE_PACKAGES` exactly, **When** `dotfiles-doctor` runs, **Then** the new check reports OK.
2. **Given** `README.md` lists a package absent from `DOTFILE_PACKAGES`, **When** `dotfiles-doctor` runs, **Then** it reports WARN and names the extra package.
3. **Given** `DOTFILE_PACKAGES` contains a package missing from `README.md`, **When** `dotfiles-doctor` runs, **Then** it reports WARN and names the missing package.
4. **Given** the drift check fails, **When** `dotfiles-doctor` finishes, **Then** the overall exit code follows the existing WARN convention (non-zero only on FAIL, per current `dotfiles-doctor` behavior) — a docs drift is a WARN, not a FAIL, since it doesn't break anyone's install.

---

### Edge Cases

- What happens when a package exists in `DOTFILE_PACKAGES` but the corresponding package directory was deleted from the repo (a different, pre-existing drift already partially covered by `check_stow`)? Out of scope here — this feature only compares `README.md` against `DOTFILE_PACKAGES`, not against the filesystem.
- How does the check handle packages commented out or listed only as a blank/spacer line inside the `DOTFILE_PACKAGES` array (e.g. the blank line already present between the base tools and the "Nuevos paquetes de desarrollo" comment)? It must skip blank lines and comment lines the same way the existing `parse_dotfile_packages` helper in `dotfiles-doctor` already does, reusing that parser rather than re-implementing array parsing.
- How does the check handle `CLAUDE.md`? `CLAUDE.md` does not currently enumerate the package list (verified: it references packages by example, not as an exhaustive list), so there is nothing to desync there today. If a future edit adds such a list to `CLAUDE.md`, it is out of scope for this feature to anticipate.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `README.md`'s package structure list MUST contain exactly the same set of package names as `DOTFILE_PACKAGES` in `install.sh` — no extras, no omissions — at the time this feature ships.
- **FR-002**: Each package entry in `README.md` MUST keep (or gain, if new) a short one-line description of what it configures, consistent with the style of existing entries.
- **FR-003**: `dotfiles-doctor` MUST gain a check that parses the package names out of `README.md`'s structure list and compares them against `DOTFILE_PACKAGES` (reusing the existing `parse_dotfile_packages` parser for the install.sh side).
- **FR-004**: The new check MUST report OK when the two sets match exactly, and WARN — listing the specific package name(s) involved — for each package present in only one of the two sources.
- **FR-005**: The new check MUST NOT modify `README.md`, `install.sh`, or any other file — `dotfiles-doctor` remains read-only, per its existing design.
- **FR-006**: The new check MUST integrate into `dotfiles-doctor`'s existing category/summary reporting (`report_check`, `print_summary`) rather than introducing a separate output format.

### Key Entities

- **Package list (README.md)**: The set of package names documented in the "📁 Estructura" section of `README.md`, each with a short description.
- **Package list (install.sh)**: The `DOTFILE_PACKAGES` bash array in `install.sh` — the existing source of truth for what a full install actually stows.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Immediately after this feature ships, comparing `README.md`'s package list against `DOTFILE_PACKAGES` by hand shows zero mismatches.
- **SC-002**: Running `dotfiles-doctor` on the corrected repo reports OK for the new documentation-sync check, with no change to any other check's status.
- **SC-003**: When a package is added to or removed from `DOTFILE_PACKAGES` without a matching `README.md` update, the very next `dotfiles-doctor` run surfaces a WARN naming that package — drift is caught on the next run, not silently carried forward indefinitely.

## Assumptions

- `README.md`'s "📁 Estructura" section is the only place in the repo that enumerates the full package list in prose form; `CLAUDE.md` and `AGENTS.md` reference individual packages by example but do not maintain an exhaustive list, so they are out of scope for this feature.
- `DOTFILE_PACKAGES` in `install.sh` remains the single source of truth for "which packages exist"; this feature documents and checks against it, it does not change what `install.sh` installs.
- The new drift check is a WARN, not a FAIL, consistent with `dotfiles-doctor`'s existing severity model where issues that don't break an install (as opposed to e.g. a broken symlink or missing secret) are reported as warnings.
- No CI/automation is assumed by this feature beyond the existing manual/local `dotfiles-doctor` invocation — wiring it into a CI pipeline is a separate, not-yet-decided feature.
