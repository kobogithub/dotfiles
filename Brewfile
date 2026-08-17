# Brewfile — paquetes de Homebrew para macOS (fuente de verdad).
# Lo consume `brew bundle` desde install.sh. Instalacion/actualizacion manual:
#   brew bundle --file="$HOME/.dotfiles/Brewfile"
# Equivale a SYSTEM_PACKAGES en Arch. Se omiten los que vienen con el sistema
# o con node/python: openssh, base-devel, python-pip, python-virtualenv, npm,
# zip, unzip.

# --- Taps de terceros ---
# Homebrew pide confirmar los taps que no son oficiales. En una maquina nueva,
# antes del `brew bundle`, correr:
#   brew trust --formula FelixKratz/formulae/sketchybar
tap "FelixKratz/formulae"

# --- CLI (formulae) ---
brew "neovim"
brew "tmux"
brew "gh"             # github-cli
brew "zsh"
brew "lsd"
brew "starship"
brew "atuin"
brew "stow"
# kubectl queda opcional: hoy no hay cluster en uso y Docker Desktop ya deja uno
# en ~/.docker/bin. Descomentar cuando vuelva a hacer falta uno propio.
# brew "kubectl"
brew "k9s"
brew "docker-compose"
brew "python"
brew "node"           # nodejs (incluye npm)
brew "yarn"
brew "git"
brew "curl"
brew "wget"
brew "jq"
brew "fzf"            # usado por claude-sessions (ccs)
brew "tree"
brew "htop"

# --- Secretos ---
# zsh/.env llama a `pass show` en CADA arranque de shell para poblar las API
# keys de los MCP. Sin esto, una maquina nueva abre cada terminal con errores y
# las variables vacias. pinentry-mac es lo que hace que gpg pida el passphrase
# en una ventana de macOS en vez de fallar sin TTY.
brew "pass"
brew "pinentry-mac"

# --- CLI modernas (mejoras de experiencia) ---
brew "ripgrep"       # rg: grep rapidísimo
brew "zoxide"        # cd inteligente (init en .zshrc)
brew "lazygit"       # TUI de git
brew "fd"            # find moderno; potencia fzf/rg
brew "bat"           # cat con syntax highlight
brew "git-delta"     # diffs de git hermosos (pager en .gitconfig)
brew "yq"            # jq para YAML (k8s/dbt/compose)
brew "lazydocker"    # TUI de docker (en Arch: AUR, no en SYSTEM_PACKAGES)
brew "btop"          # monitor de sistema (mejor que htop)
brew "tealdeer"      # tldr: ejemplos de comandos
brew "dust"          # du visual
brew "duf"           # df visual

# --- Nubes y redes ---
brew "awscli"
brew "azure-cli"
brew "cloudflared"
brew "wireguard-tools"
brew "rclone"

# --- Dev y agentes ---
brew "uv"                  # instalador/resolver de Python, reemplazo de pip-tools
brew "supabase"            # CLI de Supabase (arrastra node)
brew "railway"             # CLI de Railway
brew "playwright-mcp"      # servidor MCP de Playwright (arrastra node)
# Arrastra el pyenv de Homebrew como dependencia: en macOS ese es EL pyenv, y
# ~/.pyenv queda solo como PYENV_ROOT (shims + versions). Por eso el
# post-install de install.sh chequea el comando `pyenv` y no ese directorio —
# si no, se instalaria un segundo pyenv por pyenv.run que ademas ganaria el
# PATH. En Arch no hay pyenv por pacman y el que vale es el de pyenv.run.
brew "pyenv-virtualenv"

# --- Terminal y multiplexor de agentes ---
# Los dos tienen paquete stow en DOTFILE_PACKAGES (ghostty/, herdr/): si no se
# declaran aca, una maquina nueva termina con la config de un programa que no
# esta instalado.
brew "herdr"               # workspace de terminal para agentes; config en herdr/

# --- Gestor de archivos en terminal (reemplazo de Finder) ---
brew "yazi"                # TUI de archivos; config en el paquete stow yazi/
brew "poppler"             # yazi: preview de PDF
brew "ffmpegthumbnailer"   # yazi: miniaturas de video
brew "sevenzip"            # yazi: preview/extraccion de comprimidos
brew "imagemagick"         # yazi: preview de HEIC/AVIF/SVG

# --- Fonts (casks) ---
cask "font-iosevka-nerd-font"   # usada por ghostty (Iosevka Nerd Font Mono)

# --- GUI (casks) ---
# El cask se llamaba "docker"; Homebrew lo renombro a "docker-desktop" y el
# nombre viejo hoy sigue andando solo como alias.
cask "docker-desktop"       # Docker Desktop
cask "ghostty"              # terminal; config en el paquete stow ghostty/
cask "gcloud-cli"           # ex google-cloud-sdk; hoy es cask, no formula
cask "aerospace"            # tiling window manager (config: ~/.aerospace.toml)

# --- Barra de estado (macOS) ---
brew "FelixKratz/formulae/sketchybar"   # barra custom, acompaña a aerospace
