# 🏠 Dotfiles de Kevin Barroso

[![CI](https://github.com/kobogithub/dotfiles/actions/workflows/ci.yml/badge.svg?branch=dev)](https://github.com/kobogithub/dotfiles/actions/workflows/ci.yml)

![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)
![GNU Stow](https://img.shields.io/badge/GNU_Stow-EE6600?style=flat&logo=gnu&logoColor=white)
![Homebrew](https://img.shields.io/badge/Homebrew-FBB040?style=flat&logo=homebrew&logoColor=white)
![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=flat&logo=zsh&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=flat&logo=neovim&logoColor=white)
![tmux](https://img.shields.io/badge/tmux-1BB91F?style=flat&logo=tmux&logoColor=white)
![Starship](https://img.shields.io/badge/Starship-DD0B78?style=flat&logo=starship&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=node.js&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)

Repositorio centralizado de configuraciones personales, gestionado con **GNU Stow**. La instalación es **multiplataforma**: detecta el sistema operativo y usa **Homebrew** en macOS o **pacman** en Arch Linux, instalando las herramientas y enlazando todos los dotfiles.

## 🧩 El modelo Stow

Cada directorio de primer nivel es un **paquete Stow**. Stow enlaza el contenido del paquete dentro de `$HOME` replicando la estructura interna, así que **la ruta de un archivo dentro del paquete equivale a su destino bajo `~`**:

| Archivo en el repo | Destino |
|---|---|
| `git/.gitconfig` | `~/.gitconfig` |
| `zsh/.zshrc` | `~/.zshrc` |
| `nvim/.config/nvim/` | `~/.config/nvim/` |
| `scripts/.local/bin/<x>` | `~/.local/bin/<x>` |

> ⚠️ **Editá siempre los archivos en el repo, nunca las copias enlazadas en `~`.** Como son symlinks, editar en `~` modifica el repo igual, pero conviene trabajar desde el repo para no perder el norte. Al agregar un archivo nuevo a un paquete existente, corré `stow -R <paquete>` para tomar los archivos nuevos.

## 📁 Estructura

```
dotfiles/
├── git/                    # Git (~/.gitconfig)
├── bash/                   # Bash (~/.bashrc)
├── zsh/                    # Zsh (~/.zshrc + aliases/config sourceados por ruta)
├── vim/                    # Vim (~/.vimrc, ~/.vim/)
├── nvim/                   # Neovim (~/.config/nvim/)
├── tmux/                   # tmux (~/.tmux.conf)
├── starship/               # Starship (~/.config/starship.toml)
├── atuin/                  # Atuin (~/.config/atuin/)
├── ghostty/                # Ghostty (~/.config/ghostty/)
├── ssh/                    # SSH (~/.ssh/config)
├── kubectl/                # kubectl (~/.kube/) + aliases k8s
├── k9s/                    # k9s (~/.config/k9s/)
├── docker/                 # Docker + aliases y funciones
├── python/                 # Entorno Python (pyenv, aliases)
├── nodejs/                 # Entorno Node.js (nvm, aliases)
├── scripts/                # Scripts propios (~/.local/bin/)
├── opencode/               # OpenCode agents & skills (~/.config/opencode/)
├── herdr/                  # Config de herdr (~/.config/herdr/)
├── claude-code/            # Config global de Claude Code (~/.claude/settings.json)
├── aerospace/              # Solo macOS: AeroSpace WM (~/.aerospace.toml)
├── sketchybar/             # Solo macOS: barra Frostmourne (~/.config/sketchybar/)
├── macos/                  # Solo macOS: LaunchAgents (~/Library/LaunchAgents/)
├── system/                 # Configuraciones del sistema
├── Brewfile                # Paquetes de Homebrew (macOS) — fuente de verdad
├── install.sh              # Instalador multiplataforma (macOS / Arch)
└── README.md               # Este archivo
```

## 🚀 Instalación rápida

```bash
# Clonar el repositorio
git clone https://github.com/kobogithub/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Instalación completa (detecta macOS o Arch automáticamente)
./install.sh

# Reiniciar la terminal para aplicar los cambios
```

El instalador respalda cualquier archivo en conflicto en `~/.dotfiles-backup/TIMESTAMP/` antes de enlazar (vía `stow -n` dry-run), así que es seguro correrlo sobre una máquina con configs previas.

## 📦 Herramientas instaladas automáticamente

El paso de paquetes de sistema es **OS-aware** (`detect_os` → `macos` / `arch` / `other`). En *other* se omiten los paquetes de sistema y solo se enlazan los dotfiles.

### 🍎 macOS — Homebrew

Si **Homebrew** no está instalado, `install.sh` lo instala automáticamente (script oficial, no interactivo) y lo agrega al PATH. Los paquetes viven en el [`Brewfile`](Brewfile) (fuente de verdad) y se instalan con `brew bundle` (idempotente). Instalación/actualización manual: `brew bundle --file="$HOME/.dotfiles/Brewfile"`.

**Fórmulas base:** `neovim` · `tmux` · `gh` · `zsh` · `lsd` · `starship` · `atuin` · `stow` · `kubectl` · `k9s` · `docker-compose` · `python` · `node` · `yarn` · `git` · `curl` · `wget` · `jq` · `fzf` · `tree` · `htop`

**CLI modernas:** `ripgrep` · `zoxide` · `lazygit` · `fd` · `bat` · `git-delta` · `yq` · `lazydocker` · `btop` · `tealdeer` · `dust` · `duf`

**Casks (GUI):** `docker` · `aerospace` · `font-iosevka-nerd-font`

### 🐧 Arch Linux — pacman

**Base:** `openssh` · `neovim` · `tmux` · `github-cli` · `zsh` · `lsd` · `starship` · `atuin` · `stow` · `kubectl` · `k9s` · `docker-compose` · `python` (+ `pip`, `virtualenv`) · `nodejs` (+ `npm`, `yarn`) · `base-devel` · `git` · `curl` · `wget` · `jq` · `fzf` · `tree` · `htop` · `unzip` · `zip`

**CLI modernas:** `ripgrep` · `zoxide` · `lazygit` · `fd` · `bat` · `git-delta` · `go-yq` · `btop` · `tealdeer` · `dust` · `duf`  *(lazydocker solo en AUR)*

> Docker en Arch se maneja aparte para evitar conflictos; en macOS es el cask de Docker Desktop.

### 🔧 Post-install (solo instalación completa)

- **nvm** (Node Version Manager) + **pyenv** (Python Version Manager)
- Locale `C.UTF-8` (se omite en macOS), `zsh` como shell por defecto, init de `atuin`
- Grupo `docker` + `systemctl` (solo Linux)

## 🔧 Opciones del instalador

```bash
./install.sh                 # completa: paquetes de sistema + dotfiles + setup
./install.sh -s              # solo paquetes de sistema
./install.sh -d git zsh nvim # enlazar solo estos paquetes (sin paquetes de sistema)
./install.sh -u git zsh      # desinstalar (unstow) estos paquetes
./install.sh -h              # ayuda; lista todos los paquetes disponibles

# Operaciones Stow manuales (desde la raíz del repo):
stow -n -d . -t $HOME <pkg>  # dry-run, chequear conflictos
stow    -d . -t $HOME <pkg>  # instalar
stow -R -d . -t $HOME <pkg>  # re-stow (tras agregar/quitar archivos en un paquete)
stow -D -d . -t $HOME <pkg>  # desinstalar
```

## 📜 Scripts propios (`~/.local/bin/`)

Viven en el paquete `scripts/` y se enlazan a `~/.local/bin/`. Ver [`scripts/README.md`](scripts/README.md) para el detalle.

| Script | Alias | Qué hace |
|---|---|---|
| **`dotfiles-doctor`** | — | Health-check **solo lectura**: verifica que cada paquete esté bien enlazado, que las herramientas del SO estén instaladas y que los secretos de `pass` resuelvan. Reporta OK/WARN/FAIL. |
| **`alias-manager`** | `alm` | Gestiona aliases (agregar, quitar, listar, buscar, editar) en los archivos de aliases del repo. |
| **`claude-sessions`** | `ccs` | Buscador **global** de sesiones de Claude Code con `fzf` (todos los repos); al elegir, hace `cd` al proyecto y reanuda la sesión. |
| **`claude-usage`** | `ccu` | Análisis de **tokens y costos** de Claude Code por modelo/proyecto, con cache hit ratio; `--html` genera un dashboard. |
| **`claude-speak`** | `cmu` / `cun` (mute / unmute) | Hook TTS que lee en voz alta (macOS `say`) la última respuesta de Claude Code. |
| **`macos-defaults`** | — | Aplica un baseline de preferencias de macOS (`defaults write`): teclado, Finder, Dock, screenshots, trackpad. Idempotente, solo-macOS; lo corre `install.sh` en la instalación completa. |
| **`brew-autoupdate`** | — | Actualiza Homebrew en segundo plano (macOS; lo dispara el LaunchAgent del paquete `macos/`). |

## 🐚 Carga de la shell (Zsh)

`~/.zshrc` es el hub. Sourcea `~/.profile` primero y, cerca del final, sourcea configs específicas **directamente desde `~/.dotfiles/`** (no desde las rutas enlazadas): `zsh/.aliases_general`, `docker/.docker_aliases`, `kubectl/.aliases_k8s`, `python/.python_config`, `nodejs/.nodejs_config`. Finalmente sourcea `~/.env`.

> Por eso los cambios a esos archivos de aliases/config toman efecto en una shell nueva **sin re-stow** (se sourcean por ruta absoluta); pero `.zshrc` en sí solo se actualiza en `~` si el paquete `zsh` está stoweado.

## 🔒 Secretos

Los secretos **no se guardan en el repo**. `zsh/.env` (→ `~/.env`) puebla variables de entorno al iniciar la shell llamando a `pass show <ruta>` (el gestor `pass`) — por ejemplo API keys de servidores MCP o credenciales OAuth. Para agregar un secreto: guardalo en `pass` y añadí una línea `export VAR="$(pass show <ruta>)"` en `zsh/.env`. `.gitignore` excluye `*.key`, `*.pem`, `secrets/`, `*.db` y el kube config.

## ✨ Características principales

### 🐚 Shell (Zsh)
- **Starship** — prompt informativo con Git, duración de comandos e indicadores de Python/Node
- **Atuin** — historial inteligente con búsqueda fuzzy
- **lsd** — listados con colores e iconos (`ll`, `tree`)
- Aliases OS-aware: `update` / `install` / `search` / `cleanup` mapean a **pacman** en Arch o **brew** en macOS

### ⚡ Editor (Neovim)
- Configuración Lua moderna, leader key en espacio, navegación de ventanas con `Ctrl-hjkl`

### 🖥️ Terminal (tmux)
- Prefix `Ctrl-a`, navegación vim (`hjkl`), splits `|` y `-`, mouse habilitado
- Tema **Catppuccin Frappe**, barra de estado arriba con directorio/sesión/host/fecha

### 🔒 SSH
- ControlMaster (conexiones persistentes), compresión, timeouts/keep-alive, hosts de GitHub preconfigurados

### ☸️ Kubernetes
- `kubectl` + `k9s` con aliases (`k`, `kgp`, `kgs`, `kl`, `klf`, `ke`…) y autocompletado

## 🛠️ Herramientas de desarrollo

### 🐳 Docker
Aliases (`d`, `dc`, `dcu`, `dcd`, `dlogs`) y funciones (`drun`, `denter`, `dcleanup`, `dusage`); plantillas de Dockerfile para Node y Python.

### 🐍 Python
Integración con **pyenv**, virtual envs, tools (`black`, `flake8`, `mypy`, `pytest`), aliases (`py`, `venv`, `venvact`) y funciones (`pymkenv`, `pyquick`, `pyformat`).

### 🟢 Node.js
Integración con **nvm**, múltiples package managers (npm/yarn/pnpm) con auto-detección, plantillas (React, Next.js, Express, Vue) y tools (ESLint, Prettier, Jest).

### 🤖 OpenCode AI Agents & Skills
Agents y skills expertos (FastAPI, PostgreSQL, Supabase, Docker, Astro, docs, QA) enlazados a `~/.config/opencode/`. Ver [`opencode/README.md`](opencode/README.md).

## 📋 Uso diario

```bash
# Git (aliases en zsh/.zshrc)
gs          # git status
ga .        # git add .
gc "msg"    # git commit -m "msg"
gp          # git push

# Sistema (OS-aware: pacman en Arch, brew en macOS)
update      # actualizar el sistema/paquetes
install pkg # instalar paquete
search pkg  # buscar paquete
cleanup     # limpiar

# Navegación
ll          # lsd -alF
tree        # lsd --tree
..          # cd ..
...         # cd ../..

# Kubernetes
k           # kubectl
kgp         # kubectl get pods
klf         # kubectl logs -f
k9s         # dashboard de k9s

# Claude Code
ccs         # buscar y reanudar sesiones de cualquier repo (fzf)
ccu         # análisis de tokens/costos (ccu --html ~/uso.html para dashboard)
cmu / cun   # mutear / desmutear la lectura en voz alta (claude-speak)

# Dotfiles
cdot            # cd ~/.dotfiles
dotfiles-doctor # health-check de la instalación
alm             # alias-manager (alm search <t> busca en todos, incl. .zshrc)
als [patrón]    # buscador interactivo (fzf) de TODOS los aliases activos

# CLI modernas
rg patrón       # ripgrep: buscar en archivos (rapidísimo)
fd nombre       # find moderno
cat archivo     # = bat (syntax highlight); git diff usa delta
lzg / lzd       # TUI de git / docker (lazygit / lazydocker)
yq . f.yaml     # jq para YAML   ·   btop (monitor)   ·   dust/duf (disco)
tldr comando    # ejemplos de uso de un comando
```

## 🔄 Gestión de dotfiles

### Agregar una nueva configuración a un paquete existente

```bash
# Colocar el archivo en la ruta que replica su destino bajo ~
cp ~/.config/app/config app/.config/app/config
stow -R -d . -t $HOME app     # re-stow para tomar el archivo nuevo
git add app/ && git commit -m "Agregar config de app" && git push origin dev
```

### Agregar un paquete nuevo

```bash
mkdir -p nueva-app/.config/nueva-app
cp ~/.config/nueva-app/config nueva-app/.config/nueva-app/
# Agregarlo al array DOTFILE_PACKAGES en install.sh para incluirlo en instalaciones completas
stow -d . -t $HOME nueva-app
git add nueva-app/ install.sh && git commit -m "Agregar paquete nueva-app" && git push origin dev
```

### Actualizar desde el repositorio

```bash
cd ~/.dotfiles
git pull origin dev
./install.sh -d          # re-enlazar dotfiles si hubo cambios
```

## ✅ Validación antes de commitear

```bash
bash -n install.sh       # chequeo de sintaxis de un script
shellcheck <script>      # lint (si está instalado)
dotfiles-doctor          # health-check: links, herramientas, secretos
source ~/.zshrc          # probar cambios de shell en la sesión actual
```

> Probá la config de shell en una subshell/terminal nueva antes de commitear — un `.zshrc` malformado puede romper el login. La rama por defecto es `dev`; los mensajes de commit usan modo imperativo (ver `AGENTS.md`).

## 🖥️ Instalación en una nueva máquina

```bash
git clone https://github.com/kobogithub/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

./install.sh                       # completa (macOS o Arch)
# — o, si ya tenés las herramientas —
./install.sh -d git zsh nvim tmux  # solo dotfiles
```

## 🐧 Compatibilidad

- **macOS** — vía Homebrew (formulae + casks)
- **Arch Linux** — vía pacman
- **Otras distros** — se enlazan los dotfiles; los paquetes de sistema se instalan a mano
- **Shell:** Zsh · **Editor:** Neovim · **Terminal:** cualquiera moderna

## 📄 Licencia

Repositorio personal de Kevin Barroso. Libre uso de las configuraciones.

---

⭐ **¡Dale una estrella si te ayuda!** 🚀
