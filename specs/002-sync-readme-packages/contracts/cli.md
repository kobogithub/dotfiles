# CLI Contract (delta): dotfiles-doctor `docs` category

This extends the base contract in
`specs/001-dotfiles-doctor/contracts/cli.md`. Everything there still holds;
this file documents only what changes.

## Invocation

### Options (updated)

| Option | Effect |
|--------|--------|
| `--only <cat>` | Run a single category: `stow` \| `tools` \| `secrets` \| **`docs`** (new) |

All other options (`-h`/`--help`, `-q`/`--quiet`, unknown-option handling) are
unchanged.

## Output format (addition)

A new `Docs` section runs alongside `Stow`, `Tools`, `Secrets`, checking
`README.md`'s package list against `DOTFILE_PACKAGES` in `install.sh`.

```text
Docs
  ✅ readme-packages   README.md coincide con DOTFILE_PACKAGES (20 paquetes)
```

Or, on drift:

```text
Docs
  ⚠️  devscripts       en README.md pero no en DOTFILE_PACKAGES (install.sh) → revisa README.md
  ⚠️  ghostty          en DOTFILE_PACKAGES (install.sh) pero no en README.md → agregalo a README.md
```

Summary block gains a `Docs` line, same format as the existing three:

```text
Summary
  Stow     ✅ OK
  Tools    ✅ OK
  Secrets  ✅ OK
  Docs     ⚠️  WARN
  ───────────────────────
  Overall  ⚠️  WARN
```

### Line grammar (unchanged, reused)

Same as the base contract: `<emoji> <item>   <message>[ → <hint>]`. `Docs`
checks always carry a hint on WARN (which file to edit).

## Exit codes (unchanged)

`Docs` never emits `FAIL` (see `data-model.md`), so it can only ever move the
overall result between `OK` and `WARN` — it cannot by itself cause exit code
`1`. The existing exit code table from the base contract is otherwise
unchanged.

## Guarantees (unchanged, reaffirmed for the new category)

- **Read-only**: the `docs` check only reads `README.md` and `install.sh`; it
  never edits either file.
- **No network.**
- **Deterministic**: same two files in, same result out.
