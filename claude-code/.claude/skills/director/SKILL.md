---
name: director
description: Dirigir agentes worker en herdr — partir una tarea, lanzar varios agentes (Claude, Codex, Kiro, OpenCode…) en panes, workspaces o worktrees propios, esperarlos, leer sus resultados y consolidar. Usar cuando Kevin pida "dirigí", "hacé de director", "repartilo en agentes", "lanzá workers en herdr", o quiera trabajo en paralelo visible en herdr. NO usar para delegar algo chico que un subagente nativo resuelve; esto abre sesiones completas que cuestan.
---

# Director — dirigir workers en herdr

Sos el director: no hacés el trabajo de fondo, lo repartís, lo esperás y lo
consolidás. Los workers son sesiones de agente completas en herdr, visibles para
Kevin, que sobreviven a tu sesión.

## 0. Antes de lanzar nada

```bash
test "${HERDR_ENV:-}" = 1 || echo "no estoy dentro de herdr"
```

Si falla, decilo y frená. La sintaxis de herdr manda el binario: ante una duda,
`herdr --skill` o `herdr <grupo> --help`. **Nunca corras `herdr` pelado** (abre la
TUI) ni un subcomando que muta sin argumentos (`workspace create` ejecuta con
defaults).

Mostrale a Kevin el reparto antes de lanzar: cuántos workers, qué hace cada uno,
en qué carpeta, dónde viven y con qué agente/modelo. Cada worker es una sesión
completa; con más de 3, confirmá.

### La corrida: `~/.local/state/director/<AAAA-MM-DD>-<tarea>/`

Todo lo de una corrida vive ahí, fuera de cualquier repo y fuera del scratchpad
(que muere con la sesión — los workers no):

```
~/.local/state/director/2026-10-06-auditoria/
├── plan.md        ← el reparto: worker, carpeta, dónde vive, tarea, estado
├── w-tests.md     ← resultado de cada worker, terminado en DONE
└── w-review.md
```

Escribí `plan.md` **antes** de lanzar y actualizá el estado de cada worker al
cerrarlo. Si la sesión del director se corta o hace `/clear`, un director nuevo
retoma leyendo `plan.md` + `herdr agent list`.

## 1. Dónde vive cada worker

| `--where` | Cuándo | Qué crea |
|---|---|---|
| `split` (default) | Tareas cortas que Kevin quiere ver al lado | Un pane hermano en el tab actual |
| `workspace` | Tareas largas, o más de 2 workers (los splits se vuelven ilegibles) | Un workspace nuevo con label = nombre del worker |
| `worktree` | Workers que **editan código** en paralelo sobre el mismo repo | Worktree + rama + workspace — sin worktree se pisan los archivos |

En `split`, alterná dirección: el primero `--direction right`, los siguientes
`--direction down --split-from <pane del anterior>`.

## 2. Varias carpetas

El director no salta entre carpetas: **cada worker vive en la suya** con
`--cwd`. Así cada uno carga el `CLAUDE.md`/`AGENTS.md` de su repo y respeta sus
reglas (el de `~/taligent` propone antes de tocar sistemas de la empresa; el de
dotfiles sigue `AGENTS.md`), y sus permisos de edición quedan acotados a ese
repo.

```bash
D=~/.claude/skills/director/spawn-worker.sh
$D w-taligent --cwd ~/taligent  --where workspace --results "$RUN"
$D w-kobo     --cwd ~/kobo      --where workspace --results "$RUN"
$D w-dots     --cwd ~/.dotfiles --where worktree --branch fix-x --results "$RUN"
```

- Con carpetas distintas, un **workspace por carpeta** (`--where workspace`).
- Un worker que necesita **dos carpetas** (ej. escribe en `~/taligent` y lee el
  design system de `~/ds-taligent`): `--cwd` la principal, `--add-dir` la otra
  (repetible).
- **Dónde se para el director**: tarea de un repo → en ese repo. Tarea que cruza
  varios → arrancá en `$RUN`, para que ningún `CLAUDE.md` de proyecto sesgue el
  reparto; el director solo necesita leer los resultados.

## 3. Lanzar

Usá el script de esta skill — hace el reintento de `agent_pane_busy` (zsh tarda
~3s en cargar en un pane nuevo) y cierra el lugar si el agente no arranca:

```bash
RUN=~/.local/state/director/$(date +%F)-<tarea>   # un dir por corrida
~/.claude/skills/director/spawn-worker.sh w-tests --results "$RUN" --where workspace --model haiku
# → {"name":"w-tests","pane_id":"wB6:p1","workspace_id":"wB6","where":"workspace"}
```

- **Nombres**: `[a-z][a-z0-9_-]{0,31}`, únicos entre los agentes vivos. Prefijo
  `w-` + qué hace (`w-tests`, `w-review`).
- **Modelo**: para claude, `--model haiku` en tareas mecánicas (contar, buscar,
  resumir); sin `--model` (default) cuando hay que razonar o editar código.
- **Otros agentes**: `--kind codex|kiro|opencode|gemini…`. El script solo agrega
  permisos para claude; con otro kind, el worker puede trabarse en `blocked`
  al escribir (ver §5).

## 4. Encargar y esperar

Todo prompt a un worker lleva **el archivo de resultado y la línea `DONE`**:

```bash
herdr agent prompt w-tests "<tarea>. Escribí el resultado en $RUN/w-tests.md y terminá el archivo con la línea DONE. No hagas nada fuera de la tarea." >/dev/null
```

- Para varios workers en paralelo: mandá todos los prompts **sin** `--wait`,
  y después esperalos uno por uno.
- **Esperar = `agent prompt --wait`** cuando es uno solo. Si esperás con
  `agent wait --until idle` justo después de un prompt sin `--wait`, devuelve
  al instante porque el worker todavía no arrancó (comprobado). Entonces:
  primero confirmá que salió de `idle` (`herdr agent get <name>` muestra
  `working`), recién ahí `herdr agent wait <name> --until done --until idle --until blocked --timeout 600000`.
- **El resultado es el archivo**, no la pantalla. Está listo cuando existe y su
  última línea es `DONE`. `herdr agent read` es solo para diagnosticar.

## 5. Si un worker queda `blocked`

Está esperando una aprobación o una pregunta. Mirá qué pide:

```bash
herdr agent read <name> --lines 30
```

**No la respondas vos.** Mostrale a Kevin qué pide y esperá su decisión; después
`herdr agent send-keys <name> <tecla>`. Única excepción: que pida escribir
exactamente el archivo de resultado que le encargaste.

## 6. Consolidar y cerrar

1. Leé los archivos de `$RUN`, contrastalos (si dos workers se contradicen,
   decilo — no elijas en silencio) y armá una respuesta única.
2. Marcá cada worker como cerrado en `$RUN/plan.md`.
3. Cerrá lo que abriste: `herdr pane close <pane>` para splits,
   `herdr workspace close <ws>` para workspaces. Antes, `herdr agent list` para
   no cerrar un worker que Kevin esté usando.
4. **Worktrees: no los borres.** Contale la rama y el path, y que decida él si
   mergea, abre PR o lo descarta (`herdr worktree remove --workspace <ws>`).

## Gotchas comprobados

- `agent start` exige el pane en el prompt de la shell; por eso el reintento.
- `agent_name_taken`: un worker de una corrida anterior sigue vivo con ese
  nombre — `herdr agent list` y cerralo o usá otro nombre.
- Un pane movido de workspace cambia de ID: seguí por el nombre del agente.
- Con claude, sin `--permission-mode acceptEdits --add-dir $RUN` el worker
  hace el trabajo pero queda `blocked` en "Do you want to create …?".
