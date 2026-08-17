# alias-manager

Herramienta para gestionar aliases en tus dotfiles de forma sencilla.

## Instalación

El script ya está incluido en tu dotfiles. Solo necesitas:

```bash
cd ~/.dotfiles  # o ~/github/dotfiles
./install.sh -d scripts
```

O si ya tienes stow configurado:
```bash
stow scripts
```

## Uso

### Comandos principales

```bash
# Ver ayuda
alias-manager help

# Agregar un nuevo alias
alias-manager add <nombre> <comando>
alias-manager add gst 'git status'
alias-manager add ll 'ls -la --color=auto'

# Eliminar un alias
alias-manager remove <nombre>
alias-manager remove gst

# Listar todos los aliases
alias-manager list              # Todos
alias-manager list general      # Solo generales
alias-manager list k8s          # Solo Kubernetes
alias-manager list docker       # Solo Docker

# Buscar aliases (busca en general/k8s/docker Y en .zshrc)
alias-manager search git        # Busca "git" en nombre o comando
alias-manager search docker
# Para un buscador interactivo con fzf sobre TODOS los aliases activos: `als`

# Editar archivos de aliases
alias-manager edit              # Edita aliases generales
alias-manager edit k8s          # Edita aliases de Kubernetes
alias-manager edit docker       # Edita aliases de Docker

# Recargar configuración
alias-manager reload
```

### Aliases cortos

Para mayor comodidad, se incluyen estos aliases:

```bash
alm                 # alias-manager
alias-add           # alias-manager add
alias-rm            # alias-manager remove
alias-list          # alias-manager list
alias-search        # alias-manager search
```

### Ejemplos

```bash
# Agregar un alias personalizado para git
alm add gp 'git push'
alm add gc 'git commit -m'

# Ver todos tus aliases
alm list

# Buscar aliases relacionados con docker
alm search docker

# Editar aliases manualmente
alm edit

# Recargar después de editar
alm reload
```

## Archivos de aliases

El gestor trabaja con estos archivos:

- **General**: `zsh/.aliases_general` - Aliases generales y de sistema
- **Kubernetes**: `kubectl/.aliases_k8s` - Aliases de kubectl y k9s
- **Docker**: `docker/.docker_aliases` - Aliases de Docker

## Características

- ✅ Agregar aliases de forma interactiva
- ✅ Validación de aliases duplicados
- ✅ Búsqueda en todos los archivos de aliases
- ✅ Edición directa con tu editor preferido
- ✅ Colores para mejor legibilidad
- ✅ Recarga automática de configuración
- ✅ Soporte para múltiples tipos de aliases (general, k8s, docker)

## Nota

Después de agregar o eliminar aliases, recuerda recargar tu shell:

```bash
alias-manager reload
# o
source ~/.zshrc
```

---

# dotfiles-doctor

Diagnóstico de salud de la instalación de dotfiles, en modo **solo lectura**
(no modifica nada). Verifica cuatro categorías y sale con código `!= 0` si hay
algún `FAIL`, de modo que sirve como *gate* en scripts/CI.

## Qué verifica

- **Stow**: cada paquete de `DOTFILE_PACKAGES` (leído de `install.sh`) está
  correctamente enlazado a este repo. Distingue *enlazado* / *no stoweado* /
  *conflicto* (archivo real o symlink ajeno) / *symlink roto*. Replica la lista
  de ignore por defecto de GNU Stow (`README*`, `LICENSE*`, `COPYING*`).
- **Tools**: herramientas clave instaladas según el SO detectado (`detect_os`:
  arch/macos/other). Críticas → `FAIL` si faltan; opcionales → `WARN`.
- **Secrets**: cada `pass show <ruta>` referenciado en `zsh/.env` resuelve.
  Nunca ejecuta `.env` ni imprime valores. Si `pass` no está disponible, la
  categoría degrada a `WARN` (no `FAIL`).
- **Docs**: el listado de paquetes en el bloque "📁 Estructura" de `README.md`
  coincide exactamente con `DOTFILE_PACKAGES`. Un paquete de más o de menos en
  cualquiera de los dos lados → `WARN` nombrando el paquete y de qué lado falta
  (nunca `FAIL`, un desfase de documentación no rompe ninguna instalación).

## Uso

```bash
dotfiles-doctor                    # todas las categorías
dotfiles-doctor -q                 # oculta líneas OK; solo WARN/FAIL
dotfiles-doctor --only stow        # una sola categoría: stow|tools|secrets|docs
dotfiles-doctor -h                 # ayuda
```

## Omitir paquetes por máquina

Para deviaciones intencionales en un equipo puntual (ej. no stowear `atuin` en
una Mac porque su config apunta a otra db), listá los paquetes a omitir —uno por
línea, con comentarios `#`— en `~/.dotfiles-doctor-skip` (archivo local, no
trackeado). El check de `stow` los reporta como OK con la nota "omitido a
propósito", sin marcar FAIL.

```
# ~/.dotfiles-doctor-skip
atuin   # se usa la config default en esta máquina
```

## Códigos de salida

| Código | Significado |
|--------|-------------|
| `0` | Sin `FAIL` (todo OK, o solo `WARN`) |
| `1` | Al menos un `FAIL` |
| `2` | Error de uso (opción/categoría inválida) |

---

# claude-sessions

Buscador **global** de sesiones de Claude Code con `fzf`. Lee todas las
sesiones guardadas en `~/.claude/projects/*/*.jsonl` (de **todos** los
repositorios), las lista ordenadas por más reciente, y al elegir una hace
`cd` al proyecto correcto y ejecuta `claude --resume <sessionId>`.

Cada fila muestra: antigüedad relativa, título de la sesión (el `aiTitle`
que genera Claude, o el primer prompt como fallback) y el nombre del
proyecto. El panel de preview muestra los últimos prompts de esa sesión.

Requiere `python3` y `fzf` (ambos ya en el `Brewfile`).

## Uso

```bash
claude-sessions            # abre el selector con todas las sesiones
claude-sessions bunge      # abre el selector con "bunge" como query inicial
claude-sessions --print    # imprime "<sessionId>TAB<cwd>" en vez de reanudar
claude-sessions -h         # ayuda
ccs                        # alias (zsh/.aliases_general)
```

`--print` existe para que otros programas puedan usar este mismo buscador sin
heredar el `cd` + `exec` final. Lo usa el **plugin de herdr**
(`herdr/.config/herdr/plugins/claude-sessions/`), que abre la sesión elegida en
un workspace propio en vez de comerse el pane actual — el listado y el preview
siguen viviendo acá, para no terminar con dos implementaciones.

Dentro de `fzf`: escribí para filtrar, `Enter` reanuda la sesión en su
proyecto, `Ctrl-C` cancela. Diferencia con `claude --resume`: ese solo
muestra las sesiones del directorio actual; `claude-sessions` las cruza
todas sin importar en qué repo estés parado.

---

# claude-usage

Analisis de uso de **tokens y costos** de Claude Code. Recorre todas las
sesiones de `~/.claude/projects/*/*.jsonl`, lee el campo `usage` de cada
respuesta del asistente (input/output, cache read/write, modelo) y estima
el costo para evaluar estrategias de optimizacion.

Muestra: costo total estimado, **cache hit ratio**, desglose de costo por
componente (output / cache_write / cache_read / input), costo por modelo,
y top de proyectos por costo. Con `--html` genera un dashboard autocontenido
(sin dependencias externas, tema claro/oscuro) que incluye la evolucion diaria.

Precios embebidos (USD/millon de tokens): Opus 4.8 `$5/$25`, Sonnet 5 y 4.6
`$3/$15`, Haiku 4.5 `$1/$5`. Cache: escritura 1h = 2x input, escritura 5m =
1.25x input, lectura = 0.1x input. El costo es una **estimacion API
pay-as-you-go** (valor consumido), no el gasto real si hay suscripcion.

Requiere `python3` (ya en el `Brewfile`).

## Uso

```bash
claude-usage                       # reporte en terminal (historico completo)
claude-usage --days 30             # solo ultimos 30 dias
claude-usage --html ~/uso.html     # ademas genera el dashboard HTML
claude-usage -h                    # ayuda
ccu                                # alias (zsh/.aliases_general)
```

---

# macos-defaults

Aplica un **baseline reproducible de preferencias de macOS** vía `defaults write`
(nivel usuario, sin sudo, idempotente). Cubre: teclado (repetición rápida +
repetir tecla al mantener), Finder (extensiones visibles, path/status bar,
buscar en carpeta actual, sin `.DS_Store` en red/USB), screenshots (a
`~/Screenshots`, PNG, sin sombra), Dock (autohide instantáneo, sin recientes),
trackpad (tap para click) y varios ajustes de UX.

Solo corre en **macOS** (en otro SO sale sin hacer nada). Lo ejecuta
`install.sh` en la instalación completa; también se puede correr a mano. Cada
bloque del script está comentado para togglear a gusto — **son tus preferencias,
revisalas**.

## Uso

```bash
macos-defaults              # aplica y reinicia Finder/Dock/SystemUIServer
macos-defaults --no-restart # aplica sin reiniciar apps
macos-defaults -h           # ayuda
```

---

# clip-file

Copia archivos al **portapapeles del sistema** en el formato que necesites, para
pegarlos después en una app gráfica (Google Chat, Slack, Gmail, Finder). Nació
para usarse desde `yazi` con las teclas `C t` / `C i` / `C f` / `C p`, pero sirve
igual desde la terminal.

En macOS usa `pbcopy` y `osascript`; en Linux, `wl-copy` o `xclip`. Para el modo
`image` convierte a PNG con `sips` (nativo) o `magick` si el archivo no lo es.

| Modo | Qué deja en el portapapeles | Para qué sirve |
|---|---|---|
| `text` | El **contenido** del archivo como texto plano | Pegar un `.md` en un chat |
| `image` | La imagen (PNG) | Que se pegue **inline** en el chat |
| `file` | El **archivo en sí** (referencia) | Adjuntarlo pegando, o pegar en Finder |
| `path` | La ruta absoluta | Mandar una ruta por mensaje |
| `auto` | Según el tipo MIME: imagen→`image`, texto→`text`, resto→`file` | Es el modo por defecto |

## Uso

```bash
clip-file notas.md            # auto -> copia el texto
clip-file text README.md      # fuerza el contenido como texto
clip-file image captura.jpg   # la convierte a PNG y la deja pegable inline
clip-file file informe.pdf    # para adjuntarlo en un chat
clip-file path *.md           # las rutas, una por línea
clip-file -h                  # ayuda
```

Con varios archivos: `text` los concatena poniendo `--- nombre ---` como
separador; `file` y `path` los copian todos.

---

# logo

Biblioteca local de logos de tecnologías, para diagramas.

Fuente: **[logos.lndev.me](https://logos.lndev.me)** — colección abierta de 15k+
SVG limpios de marcas, apps y herramientas (repo
[`ln-dev7/logos-apps`](https://github.com/ln-dev7/logos-apps), licencia abierta;
los logos siguen siendo marcas registradas de cada empresa).

El catálogo son 15k nombres, así que se cachea en
`~/.cache/logo-index.txt` (se refresca solo cada 7 días) y se filtra con `fzf`,
igual que `als` o `ccs`. Cada logo elegido se guarda **una sola vez** en la
biblioteca.

## Uso

```bash
logo docker           # busca "docker", baja el que elijas
logo                  # catálogo completo, a filtrar en fzf
logo -p postgres      # además del SVG, un PNG de 512px con fondo transparente
logo -l               # qué hay ya en la biblioteca
logo -u               # refrescar el catálogo a mano
logo -o               # abrir la biblioteca en Finder
```

Con `Tab` se marcan varios de una.

## Por qué copia el SVG como texto

Excalidraw convierte a formas cualquier SVG que le pegues, así que pegar la
fuente es un paso menos que arrastrar el archivo. La **ruta absoluta se imprime
igual**, que es lo que pide LikeC4 en su DSL para un icono propio.

El PNG (`-p`) es para cuando hace falta un raster: usa `rsvg-convert` si está, y
si no `magick` (ya es dep de yazi).

## Dónde viven

| Qué | Dónde | Se cambia con |
|---|---|---|
| Biblioteca | `~/Pictures/logos/` | `LOGO_LIB` |
| Cache del catálogo | `~/.cache/logo-index.txt` | `XDG_CACHE_HOME` |

> El repo de origen usa la rama `master`, no `main` — está fijado en el script.
> Si algún día migran, hay que tocar `BRANCH`.
