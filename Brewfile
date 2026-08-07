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
brew "kubectl"
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

# --- Fonts (casks) ---
cask "font-iosevka-nerd-font"   # usada por ghostty (Iosevka Nerd Font Mono)

# --- GUI (casks) ---
cask "docker"               # Docker Desktop
cask "aerospace"            # tiling window manager (config: ~/.aerospace.toml)

# --- Barra de estado (macOS) ---
brew "FelixKratz/formulae/sketchybar"   # barra custom, acompaña a aerospace
