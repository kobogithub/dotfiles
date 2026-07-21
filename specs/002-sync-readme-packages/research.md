# Research: Sync README Package List with install.sh

The Technical Context has no unresolved `NEEDS CLARIFICATION` markers. This
document records the two implementation decisions worth writing down before
Phase 1, since both affect how the new `docs` category is built inside
`dotfiles-doctor`.

## Decision 1: How to extract the package list from README.md

- **Decision**: Extract package names from the fenced code block under the
  `## 📁 Estructura` heading in `README.md` using `awk` to isolate the block
  (mirroring the existing `parse_dotfile_packages` pattern that isolates the
  `DOTFILE_PACKAGES=( ... )` block in `install.sh`), then `sed`/`grep` to keep
  only lines with a tree-drawing prefix (`├──`/`└──`) and a trailing `/`
  (directories, i.e. packages — as opposed to `install.sh` and `README.md`,
  which are listed in the same block but are files, not packages), stripping
  the tree characters, the trailing `/`, and the `# comment`.
- **Rationale**: Reuses the same awk-then-strip idiom already in the file
  (`parse_dotfile_packages`), so the new parser reads as a sibling function
  rather than a new style. Keeps the dependency footprint at zero (`awk`,
  `sed`, `grep`, `tr` are already required by the script).
- **Alternatives considered**:
  - *Parsing the whole README with a markdown parser* — rejected, adds an
    external dependency (no markdown CLI tool is currently required anywhere
    in this repo) for a fixed, simple format the repo controls itself.
  - *Hardcoding the expected README format as a fixed line range* — rejected,
    fragile to any unrelated edit above the structure block; the heading-anchored
    awk approach only cares about the fenced block's own boundaries.

## Decision 2: How to diff two package lists in Bash 3.2

- **Decision**: Since the script must stay Bash 3.2-compatible (macOS ships
  3.2; no associative arrays, per the existing portability comment on
  `resolve_link`), the diff is a plain double loop: for each package in list A,
  check membership in list B with a `grep -Fxq` style match (exact line match,
  no regex surprises), and vice versa. Anything in A but not B, or B but not A,
  is reported as a `docs` WARN naming the package and which side it's missing
  from.
- **Rationale**: At ~20 packages the O(n·m) cost is irrelevant (worst case
  ~400 string comparisons, sub-millisecond), and it avoids `comm` (GNU/BSD
  behave differently on flag support and require pre-sorted input, which is
  exactly the kind of cross-platform footgun Principle III exists to avoid)
  and avoids associative arrays (not available in Bash 3.2).
- **Alternatives considered**:
  - *`comm -3` on two sorted temp files* — rejected: requires writing/reading
    temp files (the rest of the script does everything in-memory via
    here-strings) and `comm`'s exact flag behavior/locale sort order differs
    between GNU coreutils (Arch) and BSD (macOS), risking a false diff on one
    OS but not the other — a correctness risk for zero benefit at this scale.
  - `sort` + `diff` on the two lists — same cross-platform sort-order concern,
    plus an extra process fork per comparison for no real gain over a loop.
