# Feature Specification: dotfiles-doctor

**Feature Branch**: `001-dotfiles-doctor`

**Created**: 2026-07-15

**Status**: Draft

**Input**: User description: "Script `dotfiles-doctor` (en el paquete scripts, destino ~/.local/bin) que diagnostica la salud de la instalación de dotfiles: verifica que cada paquete de DOTFILE_PACKAGES esté correctamente stoweado (symlinks apuntando al repo, sin archivos huérfanos ni conflictos), que las herramientas clave estén instaladas segun el OS detectado, y que los secretos referenciados en zsh/.env existan en `pass`. Debe reportar un resumen con estado OK/WARN/FAIL por categoria y salir con codigo distinto de cero si hay algun FAIL. Multiplataforma (Arch/macOS)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verify the installation is healthy (Priority: P1)

As the owner of the dotfiles, after running `install.sh` on a machine (or after
pulling changes on an existing one), I run a single command that tells me whether
my environment is correctly wired: are all packages symlinked, are the tools I
depend on present, and are my secrets reachable. I get a categorized summary and
a clear pass/fail so I know at a glance whether the machine is set up.

**Why this priority**: This is the core value — a one-shot health check that
replaces manually eyeballing symlinks and remembering which tools should exist.
Without it, the feature delivers nothing.

**Independent Test**: On a freshly stowed machine, run `dotfiles-doctor` and
confirm it reports every category as OK and exits `0`. Then deliberately break
one symlink and confirm the relevant category reports FAIL and the exit code is
non-zero.

**Acceptance Scenarios**:

1. **Given** all packages are correctly stowed, the key tools are installed, and
   every secret resolves in `pass`, **When** the user runs `dotfiles-doctor`,
   **Then** every category shows OK and the command exits `0`.
2. **Given** a stowed package whose symlink was replaced by a real file (or points
   outside the repo), **When** the user runs `dotfiles-doctor`, **Then** the Stow
   category reports FAIL for that package with the offending path, and the command
   exits non-zero.
3. **Given** everything is healthy except a missing optional tool, **When** the
   user runs `dotfiles-doctor`, **Then** that item reports WARN, the overall exit
   code stays `0`, and the summary makes clear nothing is broken.

---

### User Story 2 - Understand *what* is wrong and how to fix it (Priority: P2)

When a check does not pass, I want the report to name the specific package, tool,
or secret and give me enough context to fix it (e.g. "run `stow -R zsh`",
"`git` not found", "`pass show <path>` failed"), rather than a bare FAIL.

**Why this priority**: A health check that says "something is wrong" without
saying what is only marginally better than no check. Actionable output is what
makes it worth running, but it builds on the P1 detection engine.

**Independent Test**: Break three different things (a symlink, an uninstalled
tool, a missing secret) and confirm each failing line identifies the exact item
and includes a remediation hint.

**Acceptance Scenarios**:

1. **Given** a package that has never been stowed, **When** the check runs,
   **Then** the output distinguishes "not stowed" from "stowed but conflicting".
2. **Given** a secret referenced in `zsh/.env` that is absent from `pass`, **When**
   the check runs, **Then** the output names the `pass` path that failed to
   resolve.

---

### User Story 3 - Works the same on Arch and macOS (Priority: P3)

I use the same dotfiles on an Arch Linux laptop and a macOS Mac mini. The doctor
must adapt its expectations to the detected OS — checking the tools that OS is
supposed to have — without me passing flags.

**Why this priority**: Cross-platform parity is a standing requirement of the
repo, but the check is still useful on a single platform first; multi-platform
correctness is a refinement.

**Independent Test**: Run `dotfiles-doctor` on both an Arch and a macOS machine
and confirm each reports against the correct expected tool set and neither flags
platform-inapplicable items (e.g. no systemd/docker-group checks on macOS).

**Acceptance Scenarios**:

1. **Given** the script runs on macOS, **When** it checks system tooling, **Then**
   it does not report Linux-only expectations (systemd, `docker` group) as
   failures.
2. **Given** the script runs on an unsupported OS (`other`), **When** it runs,
   **Then** it skips OS-specific tool checks with a WARN rather than failing hard.

---

### Edge Cases

- **`pass` not installed / no GPG agent**: secret checks cannot run — reported as
  WARN (environment limitation), not FAIL, so a machine that legitimately has no
  `pass` is not marked broken.
- **Package listed in `DOTFILE_PACKAGES` but directory missing from repo**: report
  FAIL — the manifest and the repo disagree.
- **A file exists in `~` shadowing a package file but is a real file, not a symlink
  into the repo**: report FAIL (conflict), distinct from a correct symlink.
- **Symlink exists but is dangling** (points to a repo path that no longer exists):
  report FAIL.
- **Run with no arguments vs. a single category filter**: default runs all
  categories; the tool should not crash if invoked from any working directory.
- **Repo location differs from `~/.dotfiles`**: the check resolves the repo root
  rather than assuming a hardcoded path.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The tool MUST read the authoritative list of packages from the
  `DOTFILE_PACKAGES` definition in `install.sh` so the check never drifts from
  what is actually installed.
- **FR-002**: For each package, the tool MUST verify that its contained files are
  symlinked into `$HOME` and that each symlink resolves to the corresponding file
  inside the dotfiles repo.
- **FR-003**: The tool MUST distinguish and separately report: correctly stowed,
  not stowed at all, and stowed-but-conflicting (a real file or a foreign symlink
  occupying the target path).
- **FR-004**: The tool MUST detect the operating system at runtime (Arch / macOS /
  other) and check the set of key tools expected for that OS, without requiring
  the user to specify the platform.
- **FR-005**: The tool MUST NOT report platform-inapplicable checks as failures on
  a platform where they do not apply (e.g. no systemd/`docker`-group checks on
  macOS).
- **FR-006**: The tool MUST parse the secret references in `zsh/.env` and verify
  that each referenced `pass` entry resolves successfully.
- **FR-007**: The tool MUST classify every individual check as exactly one of
  `OK`, `WARN`, or `FAIL`, and group results under named categories (at minimum:
  Stow, Tools, Secrets).
- **FR-008**: The tool MUST print a summary per category and an overall verdict.
- **FR-009**: The tool MUST exit with a non-zero status if any check is `FAIL`,
  and with status `0` if there are only `OK` and/or `WARN` results.
- **FR-010**: For every non-`OK` result, the output MUST identify the specific item
  (package name, tool name, or `pass` path) and include a short remediation hint.
- **FR-011**: When a prerequisite for a category is absent (e.g. `pass` or GPG not
  available), the tool MUST degrade that category to `WARN` with an explanation
  rather than emitting misleading `FAIL`s.
- **FR-012**: The tool MUST run read-only — it MUST NOT modify symlinks, install
  packages, or change any state; it only diagnoses.
- **FR-013**: The tool MUST resolve the dotfiles repository root at runtime rather
  than assuming a fixed path, so it works regardless of where the repo is cloned.

### Key Entities

- **Check**: A single diagnostic assertion with a category, a target item, a
  status (`OK`/`WARN`/`FAIL`), and a human-readable message/hint.
- **Category**: A named group of checks (Stow, Tools, Secrets) with an aggregated
  status shown in the summary.
- **Package**: An entry from `DOTFILE_PACKAGES`; the unit against which Stow checks
  are performed.
- **Secret reference**: A `pass show <path>` invocation extracted from `zsh/.env`;
  the unit against which Secrets checks are performed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a correctly installed machine, `dotfiles-doctor` reports every
  category as OK and exits `0` in a single run with no arguments.
- **SC-002**: Any single broken symlink, missing key tool, or unresolvable secret
  is surfaced as a distinct line naming the exact item, in one run.
- **SC-003**: Presence of at least one FAIL always yields a non-zero exit code, so
  the tool is usable as a gate in scripts/CI; a run with only OK/WARN always exits
  `0`.
- **SC-004**: The same command, with no flags, produces correct platform-appropriate
  results on both Arch Linux and macOS.
- **SC-005**: A full run completes fast enough for interactive use (target: under a
  few seconds on a typical machine) so it can be run habitually after installs.
- **SC-006**: Running the tool never changes system state — repeated runs are
  side-effect free.

## Assumptions

- The "key tools" to verify are the ones the repo already installs per OS
  (the `pacman`/Homebrew package sets and the tools sourced by the shell config,
  e.g. `stow`, `git`, `zsh`, `nvim`, `atuin`, `starship`, plus `nvm`/`pyenv`
  bootstraps). The precise list is refined during planning against `install.sh`.
- Secret references follow the documented `export VAR="$(pass show <path>)"`
  pattern in `zsh/.env`; the tool parses that pattern rather than executing the
  file.
- The tool lives in the `scripts` package at `scripts/.local/bin/dotfiles-doctor`
  and is invoked as `dotfiles-doctor` once `~/.local/bin` is on `PATH`.
- WARN is the correct severity for "cannot determine" (missing prerequisite,
  unsupported OS), reserving FAIL for "verified broken".
- The tool targets Bash and must remain compatible with macOS's system Bash 3.2,
  consistent with the rest of the repo's scripts.
