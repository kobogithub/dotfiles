# 📂 yazi — gestor de archivos en terminal

Reemplazo de Finder para navegar, buscar y abrir archivos sin salir de la
terminal. Config en `~/.config/yazi/` (paquete stow `yazi/`), tema alineado a la
paleta **Lich King / Frostmourne** de ghostty.

## Instalación

```bash
./install.sh -d yazi                 # solo los dotfiles
brew bundle --file="$HOME/.dotfiles/Brewfile"   # yazi + deps de preview
```

Dependencias de preview (ya en el `Brewfile` / `SYSTEM_PACKAGES`):
`poppler` (PDF), `ffmpegthumbnailer` (video), `sevenzip` (comprimidos),
`imagemagick` (HEIC/AVIF/SVG).

Para **leer** PDFs (no solo previsualizarlos) se usa `tdf`, un visor de PDF que
corre dentro de la terminal: renderiza la pagina como imagen usando el protocolo
grafico de Kitty, que ghostty soporta. Esta en el `Brewfile`, no en
`SYSTEM_PACKAGES` (en Arch vive en AUR y el nombre no se verifico).

## Uso

```bash
yz            # abre yazi en el directorio actual
yz ~/Github   # abre yazi en una ruta
```

`yz` es una función de `zsh/.aliases_general` (se llama `yz` porque `y` ya es
alias de `yarn`): al salir con `q` el shell queda
**en el directorio donde estabas navegando**. Con `Q` sale sin cambiar de
directorio.

## Reglas de apertura (`yazi.toml`)

| Archivo | Se abre con |
|---|---|
| `.md`, `.markdown`, texto plano | `nvim` (LazyVim), en bloque |
| Código y configs (`.ts`, `.py`, `.toml`, `.yaml`, …) | `nvim` |
| `.pdf` | `tdf` (visor en la terminal), en bloque |
| `.html` | Google Chrome |
| Imágenes, audio, video | app por defecto de macOS (`open`) |
| Comprimidos | extraer en el lugar |

Con `O` se abre el selector "Abrir con…" para elegir otra opción (nvim, Chrome,
`tdf`, o revelar en Finder) sobre cualquier archivo — es la salida para cuando un
PDF hay que imprimirlo o firmarlo y conviene Chrome.

## Teclas

Las del preset de yazi siguen todas activas. Las más usadas:

| Tecla | Acción |
|---|---|
| `s` / `S` | buscar por **nombre** (fd) / por **contenido** (rg) |
| `z` / `Z` | saltar con **fzf** / con **zoxide** |
| `f` | filtrar el directorio actual |
| `/` `n` `N` | buscar dentro de la vista |
| `Space` / `v` | marcar archivo / modo visual |
| `y` `x` `p` | copiar, cortar, pegar |
| `d` / `D` | a la papelera / borrar definitivo |
| `a` / `r` | crear (dir si termina en `/`) / renombrar |
| `.` | alternar archivos ocultos |
| `J` / `K` | mover el preview (en PDF, de pagina) |
| `~` | ayuda con todas las teclas |
| `q` / `Q` | salir con cd / salir sin cd |

> ⚠️ `ya`, la CLI de yazi (plugins: `ya pkg add …`), está tapada por
> `alias ya='yarn add'` de `nodejs/.nodejs_config`. Si la necesitás, usá la ruta
> completa: `$(brew --prefix)/bin/ya`. Dentro de yazi no molesta, porque los
> comandos corren en `sh` sin aliases.

## Copiar al portapapeles (pegar en Google Chat, Slack, Finder…)

Prefijo `C` mayúscula — llama al script [`clip-file`](../scripts/README.md#clip-file).
Actúa sobre lo que tengas seleccionado, o sobre el archivo hovereado.

| Tecla | Qué copia | Pegás y sale |
|---|---|---|
| `C` `t` | el **contenido** como texto plano | el markdown escrito en el chat |
| `C` `i` | la **imagen** (convierte a PNG si hace falta) | la imagen inline |
| `C` `f` | el **archivo en sí** | como adjunto (o una copia, si pegás en Finder) |
| `C` `p` | la **ruta absoluta** | la ruta como texto |

El `c` minúscula del preset sigue intacto: `cc` copia la URL del archivo, `cd` el
directorio, `cf` el nombre, `cn` el nombre sin extensión.

Para un `.md` que generó Claude, `C t` es lo que querés el 90% del tiempo: el
texto queda listo para pegar en el chat sin adjuntar nada.

> Los comandos corren en segundo plano, así que el mensaje de confirmación va al
> gestor de tareas, no a la pantalla: si algo falla, `w` lo muestra.

## Saltos de directorio

Agregados propios (`keymap.toml`), prefijo `g`:

| Tecla | Va a |
|---|---|
| `g` `.` | `~/.dotfiles` |
| `g` `G` | `~/Github` |
| `g` `p` | `~/Github/personal` |
| `g` `w` | `~/Github/taligent` |
| `g` `l` | `~/.claude` |
| `g` `D` | `~/Desktop` |
| `g` `t` | `/tmp` |
| `g` `h` / `g` `c` / `g` `d` | `~` / `~/.config` / `~/Downloads` (del preset) |

## Archivos

| Archivo | Qué define |
|---|---|
| `yazi.toml` | layout, preview, openers y reglas de apertura |
| `keymap.toml` | atajos propios (`prepend_keymap`, se suman al preset) |
| `theme.toml` | colores Frostmourne (overrides del tema oscuro) |

Los tres validan contra los schemas oficiales de yazi
(`https://yazi-rs.github.io/schemas/*.json`), que están declarados en la primera
línea de cada archivo para autocompletado en el editor.
