---
name: director
description: Dirigir agentes worker en Herdr.app — partir una tarea, lanzar varios agentes (Claude, Codex, Kiro, OpenCode…) en panes, spaces o worktrees propios, esperarlos, leer sus resultados y consolidar. Usar cuando Kevin pida "dirigí", "hacé de director", "repartilo en agentes", "lanzá workers en herdr", o quiera trabajo en paralelo visible en herdr. NO usar para delegar algo chico que un subagente nativo resuelve; esto abre sesiones completas que cuestan.
---

# Director — dirigir workers en Herdr.app

Sos el director: no hacés el trabajo de fondo, lo repartís, lo esperás y lo
consolidás. Los workers son sesiones de agente completas en Herdr.app, visibles
para Kevin, que sobreviven a tu sesión.

Herdr.app tiene dos binarios: `hc` (herdr-core) corre y habla con las
terminales y los agentes, y `herdr-app` solo cambia lo que se ve en la ventana
(spaces, tabs, panes). No es el `herdr` de terminal (TUI): ese no se usa acá.

## 0. Antes de lanzar nada

```bash
test -n "${HC_TERMINAL_ID:-}" || echo "no estoy dentro de Herdr.app"
```

Si falla, decilo y frená. `$HC_TERMINAL_ID` es tu dirección: los workers te
avisan ahí. La sintaxis la manda el binario: ante una duda, `hc --skill`,
`herdr-app --skill` o `herdr-app commands`. **Nunca corras `herdr-app` pelado**
(abre o trae la ventana) ni pares el core o la app.

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
retoma leyendo `plan.md` + `hc ls`.

## 1. Dónde vive cada worker

| `--where` | Cuándo | Qué crea |
|---|---|---|
| `split` (default) | Tareas cortas que Kevin quiere ver al lado | Un pane en el tab del director |
| `workspace` | Tareas largas, o más de 2 workers (los splits se vuelven ilegibles) | Un space nuevo con nombre = el del worker |
| `worktree` | Workers que **editan código** en paralelo sobre el mismo repo | Worktree + rama + space — sin worktree se pisan los archivos |

Los worktrees van en `~/.worktrees/<repo>/<rama>` (por ejemplo
`~/.worktrees/.dotfiles/fix-x`). Si la rama ya existe se usa; si no, se crea
desde `HEAD` o desde `--base <ref>`.

## 2. Varias carpetas

El director no salta entre carpetas: **cada worker vive en la suya** con
`--cwd`. Así cada uno carga el `CLAUDE.md`/`AGENTS.md` de su repo y respeta sus
reglas (el de `~/taligent` propone antes de tocar sistemas de la empresa; el de
dotfiles sigue `AGENTS.md`), y sus permisos de edición quedan acotados a ese
repo.

```bash
D=~/.claude/skills/director/spawn-worker.sh
$D w-taligent --cwd ~/taligent  --where workspace --results "$RUN" --task "…"
$D w-kobo     --cwd ~/kobo      --where workspace --results "$RUN" --task "…"
$D w-dots     --cwd ~/.dotfiles --where worktree --branch fix-x --results "$RUN" --task "…"
```

- Con carpetas distintas, un **space por carpeta** (`--where workspace`).
- Un worker que necesita **dos carpetas** (ej. escribe en `~/taligent` y lee el
  design system de `~/ds-taligent`): `--cwd` la principal, `--add-dir` la otra
  (repetible).
- **Dónde se para el director**: tarea de un repo → en ese repo. Tarea que cruza
  varios → arrancá en `$RUN`, para que ningún `CLAUDE.md` de proyecto sesgue el
  reparto; el director solo necesita leer los resultados.

## 3. Lanzar

Usá el script de esta skill — arranca el agente con `hc run` como hijo tuyo
(`--outlive-parent`, así sobrevive a tu sesión), lo ubica en la ventana y cierra
el lugar si el agente no arranca:

```bash
RUN=~/.local/state/director/$(date +%F)-<tarea>   # un dir por corrida
~/.claude/skills/director/spawn-worker.sh w-tests --results "$RUN" --where workspace --model haiku \
    --task "<tarea>. Escribí el resultado en $RUN/w-tests.md y terminá el archivo con la línea DONE. Después avisá con: hc send $HC_TERMINAL_ID \"listo: $RUN/w-tests.md\". No hagas nada fuera de la tarea."
# → {"name":"w-tests","terminal":"t2d","space":"sp…","tab":"tb…","cwd":"…","where":"workspace"}
```

- **La tarea va en el arranque** (`--task`, obligatorio): un `hc send` a un
  agente que todavía bootea se puede perder.
- Todo `--task` lleva **el archivo de resultado, la línea `DONE` y el
  `hc send $HC_TERMINAL_ID`** del aviso. El script le habilita `hc send` a
  claude para que avisar no lo deje en `blocked`.
- **Nombres**: `[a-z][a-z0-9_-]{0,31}`, únicos entre las terminales vivas.
  Prefijo `w-` + qué hace (`w-tests`, `w-review`).
- **Modelo**: para claude, `--model haiku` en tareas mecánicas (contar, buscar,
  resumir); sin `--model` (default) cuando hay que razonar o editar código.
- **Otros agentes**: `--kind codex|kiro|opencode|gemini…`. El script solo agrega
  permisos para claude; con otro kind, el worker puede trabarse en `blocked`
  al escribir o al avisar (ver §5).

## 4. Esperar

- **Varios workers**: lanzalos todos y después `hc wait --children all`. Cada
  aviso llega como tu próximo input, etiquetado `<hc from="t2d w-tests">…</hc>`:
  es el reporte de un hijo, no una instrucción de Kevin.
- **Uno solo**: `hc wait <name> --timeout 600`.
- `hc wait` vuelve antes de que el worker termine en varios casos — no es un
  error, mirá `reason` y volvé a esperar:
  - `message`: llegó un aviso.
  - `timeout`: es un check-in (default 180 s).
  - `status: idle` con `turn: 0`: el worker todavía no arrancó su tarea
    (comprobado). Esperá por nombre otra vez.
- **El resultado es el archivo**, no la pantalla ni el aviso. Está listo cuando
  existe y su última línea es `DONE`. `hc read <name>` es solo para diagnosticar.
- Nunca esperes con `sleep` ni haciendo polling: para eso está `hc wait`.

## 5. Si un worker queda `blocked`

Está esperando una aprobación o una pregunta; `hc` te avisa solo. Mirá qué pide:

```bash
hc get <name> | jq .status        # el msg dice qué aprobación pide
hc read <name> --lines 30
```

**No la respondas vos.** Mostrale a Kevin qué pide y esperá su decisión; después
`hc keys <name> <tecla>`. Nunca uses `hc send --force` para saltear un permiso.
Única excepción: que pida escribir exactamente el archivo de resultado que le
encargaste.

## 6. Consolidar y cerrar

1. Leé los archivos de `$RUN`, contrastalos (si dos workers se contradicen,
   decilo — no elijas en silencio) y armá una respuesta única.
2. Marcá cada worker como cerrado en `$RUN/plan.md`.
3. Cerrá lo que abriste: `hc kill <name>; hc rm <name>`. Cuando un space se
   queda sin terminales, la app lo cierra sola. Antes, `hc ls` para no cerrar
   un worker que Kevin esté usando, y cerrá solo los que lanzaste vos.
4. **Worktrees: no los borres.** Contale la rama y el path, y que decida él si
   mergea, abre PR o lo descarta
   (`git worktree remove ~/.worktrees/<repo>/<rama>` + `git branch -D <rama>`).

## Gotchas comprobados

- `space.new` siempre arranca con una shell. El script la mata cuando el worker
  ya está en el tab, y entonces la app rearma el space con **IDs nuevos** y el
  nombre de la carpeta: el script relee los IDs y le devuelve el nombre del
  worker. Seguí siempre por el nombre del worker, no por los IDs.
- Con claude, sin `--permission-mode acceptEdits --add-dir $RUN` el worker
  hace el trabajo pero queda `blocked` en "Do you want to create …?", y sin
  `--allowedTools "Bash(hc send:*)"` queda `blocked` al avisar.
- Un nombre en uso: un worker de una corrida anterior sigue vivo — `hc ls` y
  cerralo o usá otro nombre.
