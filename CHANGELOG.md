# 📓 Changelog

Resumen curado de los cambios del repo, **agrupado por mes y por feature** (no por
commit). La fuente de verdad sigue siendo el historial de git: los mensajes de
commit explican el *por qué* y las trampas encontradas, que acá no se repiten.

```bash
git log --oneline            # el detalle real
git log --oneline --since=1.month
```

No se usan versiones semánticas: esto son dotfiles personales, no un paquete que
alguien instale por número de versión. Cada bloque es un mes.

> El `opencode/CHANGELOG.md` es aparte e histórico: cubre solo la config de
> OpenCode y está congelado desde enero de 2026.

---

## 2026-08

### ✨ Agregado
- **Plugins de herdr de terceros** con sus teclas versionadas: `memex`
  (`prefix+m`, busca sesiones de todos los agentes), `herdr-navigator`
  (`prefix+f`), `herdr-zoxide` (`prefix+d`), `vim-herdr-navigation`
  (`ctrl+hjkl`, con su lado de Neovim en `after/plugin/`) y `collie` (UI del
  celular por Tailscale). Se suman `bun` y el cask `tailscale-app` como
  dependencias.
- **Plugin de herdr `claude-sessions`**: con `prefix+shift+s` abre un popup con
  todas las sesiones de Claude Code y reanuda la elegida en su propio workspace,
  sin comerse el pane actual. Envuelve al script `claude-sessions`, que suma un
  modo `--print` para no duplicar el buscador.
- **`logo`**: busca en los 15k+ SVG de [logos.lndev.me](https://logos.lndev.me)
  con `fzf` y arma una biblioteca local en `~/Pictures/logos`. Deja el SVG en el
  portapapeles para pegar en Excalidraw e imprime la ruta para LikeC4.
- **Declaradas herramientas que ya se usaban sin declarar**: `pass` +
  `pinentry-mac` (los llama `zsh/.env` en cada arranque de shell), `herdr` y
  `ghostty` (tenían paquete stow pero no se instalaban). `dotfiles-doctor` ahora
  los chequea, con una lista aparte para lo que es solo de macOS (`aerospace`,
  `sketchybar`, `herdr`).
- **Sección de pasos manuales** en el README para una máquina nueva: `brew trust`
  de sketchybar, `herdr integration install claude` y el store de `pass`.
- **CLIs de trabajo al Brewfile**: nubes y redes (`awscli`, `azure-cli`,
  `gcloud-cli`, `cloudflared`, `wireguard-tools`, `rclone`) y dev/agentes (`uv`,
  `supabase`, `railway`, `playwright-mcp`, `pyenv-virtualenv`). Solo macOS: en
  Arch varias son de AUR y los nombres de pacman están sin verificar.
- **yazi** como gestor de archivos en la terminal (paquete stow nuevo, tema
  Frostmourne), con `yz` para que el shell herede el directorio al salir, y sus
  deps de preview (poppler, ffmpegthumbnailer, 7zip/sevenzip, imagemagick).
- **`clip-file`**: copia archivos al portapapeles como texto, imagen, adjunto o
  ruta — para pegar en Google Chat, Slack o Finder desde la terminal.
- **sketchybar**: barra Frostmourne para AeroSpace, con items de clima, CPU,
  memoria y Docker (estado del daemon + contenedores corriendo), y control de
  volumen (click, rueda y popup con slider).
- **AeroSpace**: paquete propio con la config del home, gaps de 8px entre
  ventanas, integración con sketchybar (gap superior + hook de workspace) y la
  menu bar de macOS oculta para dejar una sola barra.
- **CLI modernas**: `rg`, `fd`, `bat`, `delta`, `yq`, `lazygit`, `lazydocker`,
  `btop`, `dust`, `duf`, `tealdeer`.
- **`claude-sessions`** (`ccs`) y **`claude-usage`** (`ccu`): buscador global de
  sesiones de Claude Code y análisis de tokens/costos.
- **`als`**: buscador interactivo (fzf) de todos los aliases activos.
- **`macos-defaults`**: baseline de preferencias de macOS, idempotente.
- **CI de shell** en GitHub Actions.
- **Este `CHANGELOG.md`**, reconstruido desde el historial de git.
- **Skill `nuevo-paquete`** (`.claude/skills/`): el checklist real para dar de
  alta una herramienta, que toca 7+ archivos y dos ramas de SO.
- Aliases `cmu`/`cun` (mute/unmute del TTS) y `tsync`/`tsync-dry` (vault Taligent).
- `lazyvim.json` para fijar el estado de los extras de LazyVim.

### 🔧 Cambiado
- Los paquetes de macOS pasan al **`Brewfile`** (`brew bundle`) como única fuente
  de verdad; `install.sh` instala Homebrew solo si falta.
- README rehecho como multiplataforma (macOS/Arch), con los scripts reales.
- Se eliminó VS Code de los dotfiles (no se usa).
- **herdr**: el estado "working" del agente pasa a ámbar (`[theme.custom]`). Con
  el tema `terminal` salía del ANSI 3 de Frostmourne, que es celeste, y no se
  distinguía de "done", "idle" ni del texto normal.
- El cask `docker` pasa a llamarse `docker-desktop`, su nombre actual en
  Homebrew.
- `kubectl` queda comentado en el Brewfile y en `SYSTEM_PACKAGES`: no hay cluster
  en uso y Docker Desktop ya deja uno en `~/.docker/bin`.
- El hook de herdr en `claude-code/.claude/settings.json` deja de usar una ruta
  absoluta `/Users/kobo` y tolera que el archivo no exista.

### 🐛 Arreglado
- En una Mac nueva `install.sh` instalaba un **segundo pyenv**: chequeaba el
  directorio `~/.pyenv` (que es el `PYENV_ROOT` de cualquier pyenv, incluido el
  de Homebrew) en vez del comando. El de `pyenv.run` encima ganaba el PATH.
- `install.sh` usaba una feature de bash 4 y se rompía con el bash 3.2 de macOS.
- Falsos positivos de `dotfiles-doctor` con directorios *folded* y al parsear
  rutas de `pass`.
- `GNUPGHOME` en `.profile` rompía la firma GPG.
- Timeout de starship en macOS: se pre-calienta `python3`, y el WARN de
  `node --version` en frío se corta con `command_timeout = 3000` +
  `STARSHIP_LOG=error`.
- Opción mal escrita de Ghostty (`font-thickening` → `font-thicken`).
- El sourcing de cargo no era portable; el doctor acepta skips por máquina.
- Iconos vacíos en toda la barra de sketchybar (glifos Nerd Font perdidos).

---

## 2026-07

### ✨ Agregado
- **Soporte macOS/Homebrew en `install.sh`**, con `detect_os` y ramas por SO.
- **`dotfiles-doctor`**: diagnóstico read-only de stow, herramientas, secretos y
  docs (ciclo Spec Kit completo: spec → plan → implementación).
- **Spec Kit (SDD)** integrado con Claude, más la constitución del repo.
- **Subagentes custom**: `dotfiles-planner`, `dotfiles-explorer` y
  `shell-style-reviewer`, con modelo asignado por tarea.
- **Colorscheme Arthas/Icecrown** para nvim y Ghostty.
- **`claude-speak`**: hook TTS que lee las respuestas de Claude Code.
- Paquete **`claude-code`** (`~/.claude/settings.json`) vía Stow, con
  notificaciones push y plugins (figma, llm-wiki).
- Paquete **`herdr`** con su config base.
- **`brew-autoupdate`** como LaunchAgent, en vez de un `brew upgrade` en `.zshrc`.
- Paquete **`ghostty`**.

### 🔧 Cambiado
- `.gitconfig` portable: helper de `gh` vía PATH y firma dentro de los dotfiles.
- Cuenta de git correcta por carpeta, automática vía SSH `insteadOf`.

### 🐛 Arreglado
- `ControlPath` de SSH roto para el CLI de Railway.

---

## 2026-06

### ✨ Agregado
- **`CLAUDE.md`** con la guía de arquitectura del repo.
- tmux: paleta Taligent en la barra de estado y título de proyecto/tema en el
  borde de cada panel.
- Env vars de MCP/OpenCode y `GPG_TTY`.

### 🔒 Seguridad
- `test_vps` restringido a autenticación por clave pública.

---

## 2026-04

### ✨ Agregado
- **`pass` como gestor de secretos**: `zsh/.env` puebla las variables llamando a
  `pass show`, nada sensible queda en el repo (la API key de Context7 fue la
  primera en migrar).
- Alias de clima (Zárate).
- `gcloud` y `nvm` en `.zshrc`.

### 🐛 Arreglado
- Escapado del símbolo *stashed* en `git_status` de starship.

---

## 2026-03

### ✨ Agregado
- Variables de entorno de Cargo en la config de bash.
- Agente documental de Terraform.
- Host nuevo: Dokploy en Hostinger.

---

## 2026-02

### 🔧 Cambiado
- Locale a UTF-8 para evitar warnings.

---

## 2026-01

### ✨ Agregado
- **Estructura inicial del repo y migración a GNU Stow** como modelo de gestión.
- **Entorno completo de Arch Linux** vía `install.sh`.
- **Kubernetes**: `kubectl` + `k9s` con aliases y autocompletado.
- **SSH**: configuración y hosts (incluido el VPS `kobo_vps`).
- **starship**: prompt con módulos de AWS, Kubernetes y Docker.
- **tmux**: barra de estado arriba, tema Catppuccin y colores propios.
- **atuin**: historial con rutas de datos propias y sistema de dotfiles/aliases.
- **zoxide** reemplazando a `cd`.
- **`alias-manager`**: gestión de aliases desde la terminal.
- **OpenCode**: agentes especializados, skills y herramientas de configuración
  (ver `opencode/CHANGELOG.md`).
- Configs de nvim, k9s y zsh.

### 🐛 Arreglado
- Conflictos de stow y warnings de locale.
- Enlaces simbólicos: se pasan a rutas absolutas.
- Entrada duplicada de `~/.local/bin` en el PATH.
- Deserialización de la config de atuin; aliases de `lsd` en zsh.
