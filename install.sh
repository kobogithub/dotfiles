#!/bin/bash

# Script de instalación para dotfiles usando GNU Stow
# Automatiza la instalación de paquetes del sistema y configuraciones

set -e
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paquetes del sistema que siempre se instalan
SYSTEM_PACKAGES=(
    "openssh"
    "neovim"
    "tmux" 
    "github-cli"
    "zsh"
    "lsd"
    "starship"
    "atuin"
    "stow"
    "kubectl"
    "k9s"
    
    # Herramientas de desarrollo (docker se verifica por separado)
    "docker-compose"
    "python"
    "python-pip"
    "python-virtualenv"
    "nodejs"
    "npm"
    "yarn"
    "code"  # VS Code
    
    # Herramientas de desarrollo adicionales
    "base-devel"  # Herramientas de compilación
    "git"
    "curl"
    "wget"
    "jq"
    "fzf"  # usado por claude-sessions (ccs)
    "tree"
    "htop"
    "unzip"
    "zip"
)

# Paquetes de dotfiles disponibles
DOTFILE_PACKAGES=(
    "git"
    "bash" 
    "vim"
    "nvim"
    "tmux"
    "zsh"
    "starship"
    "atuin"
    "scripts"
    "system"
    "ssh"
    "kubectl"
    "k9s"
    
    # Nuevos paquetes de desarrollo
    "docker"
    "python"
    "nodejs"
    "vscode"
    "opencode"
    "ghostty"
    "herdr"
    "claude-code"
)

# Paquetes de Homebrew para macOS (equivalen a SYSTEM_PACKAGES en Arch).
# Omitidos por venir con el sistema o el propio node/python:
# openssh, base-devel, python-pip, python-virtualenv, npm, zip, unzip.
BREW_PACKAGES=(
    "neovim"
    "tmux"
    "gh"          # github-cli
    "zsh"
    "lsd"
    "starship"
    "atuin"
    "stow"
    "kubectl"
    "k9s"
    "docker-compose"
    "python"
    "node"        # nodejs (incluye npm)
    "yarn"
    "git"
    "curl"
    "wget"
    "jq"
    "fzf"         # usado por claude-sessions (ccs)
    "tree"
    "htop"
)

# Aplicaciones GUI de macOS (Homebrew casks)
BREW_CASKS=(
    "visual-studio-code"  # 'code' en Arch
    "docker"              # Docker Desktop
)

echo "🏠 Instalando dotfiles de Kevin Barroso"
echo "📂 Desde: $DOTFILES_DIR"

# Detectar el sistema operativo: "macos", "arch" u "other"
detect_os() {
    if [[ "$OSTYPE" == darwin* ]] || [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "other"
    fi
}

# Verificar que Homebrew esté disponible (no lo instala, solo guía)
ensure_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    fi
    echo "❌ Homebrew no está instalado y es necesario en macOS"
    echo "💡 Instálalo con:"
    echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    return 1
}

# Instalar paquetes del sistema en macOS con Homebrew
install_system_packages_macos() {
    echo "🍺 Instalando paquetes del sistema con Homebrew..."
    ensure_homebrew || return 1

    echo "⬆️  Actualizando Homebrew..."
    brew update

    for pkg in "${BREW_PACKAGES[@]}"; do
        if brew list --formula "$pkg" &>/dev/null; then
            echo "✅ $pkg ya está instalado"
        else
            echo "📦 Instalando $pkg..."
            brew install "$pkg"
        fi
    done

    for cask in "${BREW_CASKS[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            echo "✅ $cask ya está instalado"
        else
            echo "📦 Instalando $cask (cask)..."
            brew install --cask "$cask"
        fi
    done
}

# Función para instalar paquetes del sistema
install_system_packages() {
    echo "🔧 Instalando paquetes del sistema..."
    
    # Verificar Docker por separado debido a posibles conflictos
    if ! command -v docker >/dev/null 2>&1; then
        echo "📦 Instalando Docker..."
        sudo pacman -S --noconfirm docker
    else
        echo "✅ Docker ya está instalado ($(docker --version | cut -d' ' -f3 | tr -d ','))"
        
        # Verificar si es la versión de pacman
        if ! pacman -Qi docker >/dev/null 2>&1; then
            echo "⚠️  Docker está instalado pero no es gestionado por pacman"
            echo "💡 Esto puede causar conflictos. ¿Continuar? (y/N)"
            read -p ": " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🔧 Saltando instalación de docker via pacman"
            else
                echo "❌ Instalación cancelada"
                exit 1
            fi
        fi
    fi
    
    echo "📦 Instalando el resto de paquetes del sistema..."
    
    # Actualizar sistema
    echo "⬆️  Actualizando sistema..."
    sudo pacman -Syu --noconfirm
    
    # Instalar paquetes
    for package in "${SYSTEM_PACKAGES[@]}"; do
        echo "📦 Instalando $package..."
        if pacman -Qi "$package" &> /dev/null; then
            echo "✅ $package ya está instalado"
        else
            sudo pacman -S "$package" --noconfirm
            echo "✅ $package instalado"
        fi
    done
}

# Función para hacer backup de archivos conflictivos
backup_conflicting_files() {
    local package="$1"
    local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
    
    echo "🔍 Verificando conflictos para el paquete: $package..."
    
    # Verificar si hay conflictos usando stow dry-run con rutas absolutas
    if ! stow -n --dir="$DOTFILES_DIR" --target="$HOME" --no-folding "$package" 2>/dev/null; then
        echo "⚠️  Detectados archivos conflictivos para $package"
        mkdir -p "$backup_dir"
        
        # Encontrar archivos conflictivos y hacer backup
        while IFS= read -r line; do
            if [[ "$line" =~ "existing target" ]]; then
                # Extraer el nombre del archivo del mensaje de error
                file=$(echo "$line" | sed -n 's/.*existing target \(.*\) since.*/\1/p')
                if [[ -n "$file" && -e "$HOME/$file" ]]; then
                    echo "📁 Haciendo backup de: ~/$file"
                    mkdir -p "$backup_dir/$(dirname "$file")" 2>/dev/null || true
                    cp "$HOME/$file" "$backup_dir/$file" 2>/dev/null || true
                    rm "$HOME/$file"
                fi
            fi
        done < <(stow -n --dir="$DOTFILES_DIR" --target="$HOME" --no-folding "$package" 2>&1)
        
        echo "✅ Backup guardado en: $backup_dir"
    fi
}

# Función para instalar paquetes con stow
install_dotfile_package() {
    local package="$1"
    local action="${2:-stow}"
    
    if [ ! -d "$package" ]; then
        echo "⚠️  Directorio $package no existe, saltando..."
        return
    fi
    
    echo "📦 ${action^}ing dotfiles: $package..."
    
    if [ "$action" = "stow" ]; then
        # Hacer backup de archivos conflictivos antes de instalar
        backup_conflicting_files "$package"
        
        # Intentar instalar con stow usando ruta absoluta
        if stow --dir="$DOTFILES_DIR" --target="$HOME" --no-folding "$package" -v; then
            echo "✅ $package instalado correctamente"
        else
            echo "❌ Error instalando $package"
            return 1
        fi
    else
        stow --dir="$DOTFILES_DIR" --target="$HOME" --no-folding -D "$package" -v
        echo "✅ $package desinstalado correctamente"
    fi
}

# Función para configurar zsh como shell por defecto
setup_zsh() {
    echo "🐚 Configurando zsh como shell por defecto..."
    
    # Encontrar la ruta correcta de zsh
    local zsh_path=""
    for path in "/opt/homebrew/bin/zsh" "/usr/local/bin/zsh" "/bin/zsh" "/usr/bin/zsh" "/usr/sbin/zsh"; do
        if [[ -x "$path" ]]; then
            zsh_path="$path"
            break
        fi
    done
    
    if [[ -z "$zsh_path" ]]; then
        echo "❌ No se encontró zsh instalado"
        return 1
    fi
    
    echo "📍 zsh encontrado en: $zsh_path"
    
    # Verificar si zsh está en /etc/shells
    if ! grep -Fxq "$zsh_path" /etc/shells; then
        echo "⚠️  $zsh_path no está en /etc/shells"
        echo "🔧 Agregando $zsh_path a /etc/shells..."
        
        if sudo -n true 2>/dev/null; then
            echo "$zsh_path" | sudo tee -a /etc/shells
            echo "✅ $zsh_path agregado a /etc/shells"
        else
            echo "❌ Se requiere sudo para agregar $zsh_path a /etc/shells"
            echo "💡 Ejecuta manualmente: echo '$zsh_path' | sudo tee -a /etc/shells"
            echo "💡 Luego ejecuta: chsh -s $zsh_path"
            return 1
        fi
    else
        echo "✅ $zsh_path ya está en /etc/shells"
    fi
    
    # Cambiar shell si no es ya zsh
    if [[ "$SHELL" != "$zsh_path" ]]; then
        echo "🔄 Cambiando shell por defecto a zsh..."
        if chsh -s "$zsh_path"; then
            echo "✅ Zsh configurado como shell por defecto"
            echo "💡 Cierra la sesión y vuelve a entrar para aplicar cambios"
        else
            echo "❌ Error al cambiar shell. Intenta manualmente:"
            echo "   chsh -s $zsh_path"
        fi
    else
        echo "✅ Zsh ya es el shell por defecto"
    fi
}

# Función para programar la actualización periódica de Homebrew (solo macOS)
setup_brew_autoupdate() {
    if [[ "$(detect_os)" != "macos" ]]; then
        return
    fi

    echo "🍺 Programando actualización periódica de Homebrew..."

    install_dotfile_package "macos" "stow"

    local plist="$HOME/Library/LaunchAgents/com.kobo.brew-autoupdate.plist"
    launchctl unload "$plist" >/dev/null 2>&1 || true
    if launchctl load "$plist" 2>/dev/null; then
        echo "✅ com.kobo.brew-autoupdate cargado en launchd (corre cada 24h)"
    else
        echo "⚠️  No se pudo cargar el LaunchAgent, revisa $plist"
    fi
}

# Función para configurar locales
setup_locale() {
    echo "🌍 Configurando locales del sistema..."

    # En macOS el locale lo gestiona el sistema (no hay /etc/locale.conf)
    if [[ "$(detect_os)" == "macos" ]]; then
        echo "✅ macOS gestiona el locale; nada que configurar"
        return 0
    fi

    # Configurar variables de entorno para evitar warnings de Perl
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
    export LC_CTYPE=C.UTF-8
    
    # Verificar si C.UTF-8 está disponible (más universal que en_US.UTF-8)
    if locale -a 2>/dev/null | grep -q "C.utf8\|C.UTF-8"; then
        echo "✅ Locale C.UTF-8 ya está disponible"
    else
        echo "⚠️  C.UTF-8 no está disponible, usando configuración manual"
    fi
    
    # Crear archivo de configuración de locale si no existe
    if [[ ! -f /etc/locale.conf ]] || ! grep -q "LANG=C.UTF-8" /etc/locale.conf 2>/dev/null; then
        if [[ -w /etc/locale.conf ]] || sudo -n true 2>/dev/null; then
            echo "LANG=C.UTF-8" | sudo tee /etc/locale.conf >/dev/null 2>&1
            echo "✅ Configurado /etc/locale.conf"
        else
            echo "💡 No se pudo configurar /etc/locale.conf (sin permisos sudo)"
            echo "💡 Las variables de entorno se configurarán en ~/.profile"
        fi
    else
        echo "✅ /etc/locale.conf ya está configurado"
    fi
}

# Función para configurar herramientas de desarrollo
setup_development_tools() {
    echo "🛠️  Configurando herramientas de desarrollo..."
    
    # Instalar NVM (Node Version Manager)
    if [[ ! -d "$HOME/.nvm" ]]; then
        echo "📦 Instalando NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash >/dev/null 2>&1
        export NVM_DIR="$HOME/.nvm"
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            source "$NVM_DIR/nvm.sh"
            echo "✅ NVM instalado correctamente"
        fi
    else
        echo "✅ NVM ya está instalado"
    fi
    
    # Instalar pyenv (Python Version Manager)
    if [[ ! -d "$HOME/.pyenv" ]]; then
        echo "📦 Instalando pyenv..."
        curl https://pyenv.run | bash >/dev/null 2>&1
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        if command -v pyenv >/dev/null 2>&1; then
            echo "✅ pyenv instalado correctamente"
        fi
    else
        echo "✅ pyenv ya está instalado"
    fi
    
    # Configurar Docker para usuario actual (grupo docker + systemd son solo Linux;
    # en macOS Docker Desktop se gestiona solo)
    if [[ "$(detect_os)" != "macos" ]] && command -v docker >/dev/null 2>&1; then
        if ! groups | grep -q docker; then
            echo "🐳 Agregando usuario al grupo docker..."
            sudo usermod -aG docker $USER >/dev/null 2>&1
            echo "✅ Usuario agregado al grupo docker"
            echo "💡 Cierra sesión y vuelve a entrar para aplicar cambios"
        else
            echo "✅ Usuario ya está en el grupo docker"
        fi
        
        # Habilitar servicio de docker
        if systemctl is-enabled docker.service >/dev/null 2>&1; then
            echo "✅ Servicio docker ya está habilitado"
        else
            echo "🐳 Habilitando servicio docker..."
            sudo systemctl enable docker.service >/dev/null 2>&1
            sudo systemctl start docker.service >/dev/null 2>&1
            echo "✅ Servicio docker habilitado y iniciado"
        fi
    fi
    
    echo "✅ Herramientas de desarrollo configuradas"
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIONES] [PAQUETES...]"
    echo ""
    echo "OPCIONES:"
    echo "  -h, --help        Mostrar esta ayuda"
    echo "  -u, --uninstall   Desinstalar paquetes dotfiles (unstow)"
    echo "  -d, --dotfiles    Instalar solo dotfiles (sin paquetes del sistema)"
    echo "  -s, --system      Instalar solo paquetes del sistema"
    echo "  -a, --all         Instalación completa (sistema + dotfiles) [DEFAULT]"
    echo ""
    echo "PAQUETES de dotfiles disponibles:"
    for package in "${DOTFILE_PACKAGES[@]}"; do
        echo "  $package"
    done
    echo ""
    if [[ "$(detect_os)" == "macos" ]]; then
        echo "PAQUETES del sistema (Homebrew) que se instalan:"
        for package in "${BREW_PACKAGES[@]}" "${BREW_CASKS[@]}"; do
            echo "  $package"
        done
    else
        echo "PAQUETES del sistema (pacman) que se instalan:"
        for package in "${SYSTEM_PACKAGES[@]}"; do
            echo "  $package"
        done
    fi
    echo ""
    echo "Ejemplos:"
    echo "  $0                       # Instalación completa"
    echo "  $0 -d git zsh nvim      # Solo dotfiles específicos"
    echo "  $0 -s                   # Solo paquetes del sistema"
    echo "  $0 -u git              # Desinstalar dotfiles de git"
}

# Procesar argumentos
ACTION="stow"
PACKAGES=()
INSTALL_SYSTEM=true
INSTALL_DOTFILES=true
SPECIFIC_PACKAGES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--uninstall)
            ACTION="unstow"
            INSTALL_SYSTEM=false
            shift
            ;;
        -d|--dotfiles)
            INSTALL_SYSTEM=false
            SPECIFIC_PACKAGES=true
            shift
            ;;
        -s|--system)
            INSTALL_DOTFILES=false
            shift
            ;;
        -a|--all)
            INSTALL_SYSTEM=true
            INSTALL_DOTFILES=true
            shift
            ;;
        *)
            PACKAGES+=("$1")
            SPECIFIC_PACKAGES=true
            shift
            ;;
    esac
done

cd "$DOTFILES_DIR"

OS_TYPE="$(detect_os)"

# Verificar si stow está disponible para dotfiles
if [[ "$INSTALL_DOTFILES" == true ]] && ! command -v stow &> /dev/null; then
    echo "❌ GNU Stow no está instalado y es necesario para los dotfiles"
    case "$OS_TYPE" in
        arch)
            echo "📦 Instalando stow..."
            sudo pacman -S stow --noconfirm
            ;;
        macos)
            ensure_homebrew && brew install stow || exit 1
            ;;
        *)
            echo "💡 Instala GNU Stow manualmente y vuelve a ejecutar"
            exit 1
            ;;
    esac
fi

# Instalar paquetes del sistema
if [[ "$INSTALL_SYSTEM" == true ]]; then
    case "$OS_TYPE" in
        arch)  install_system_packages ;;
        macos) install_system_packages_macos ;;
        *)
            echo "⚠️  SO no reconocido; saltando instalación de paquetes del sistema"
            echo "💡 Instala manualmente y usa '$0 -d' para solo los dotfiles"
            ;;
    esac
fi

# Instalar dotfiles
if [[ "$INSTALL_DOTFILES" == true ]]; then
    echo "🔧 Configurando dotfiles..."
    
    if [[ "$SPECIFIC_PACKAGES" == true ]]; then
        # Instalar paquetes específicos
        if [[ ${#PACKAGES[@]} -eq 0 ]]; then
            echo "❌ No se especificaron paquetes de dotfiles"
            echo "💡 Usa -h para ver paquetes disponibles"
            exit 1
        fi
        
        for package in "${PACKAGES[@]}"; do
            install_dotfile_package "$package" "$ACTION"
        done
    else
        # Instalar todos los paquetes de dotfiles
        echo "📦 Instalando todos los paquetes de dotfiles..."
        for package in "${DOTFILE_PACKAGES[@]}"; do
            install_dotfile_package "$package" "$ACTION"
        done
    fi
fi

# Configuraciones adicionales
if [[ "$INSTALL_SYSTEM" == true && "$ACTION" == "stow" ]]; then
    echo ""
    echo "⚙️  Realizando configuraciones adicionales..."
    
    # Configurar locales del sistema
    setup_locale
    
    # Configurar herramientas de desarrollo
    setup_development_tools
    
    # Configurar zsh como shell por defecto
    setup_zsh

    # Programar actualización periódica de Homebrew (macOS)
    setup_brew_autoupdate

    # Inicializar atuin si es la primera vez
    if ! [[ -f "$HOME/.local/share/atuin/history.db" ]]; then
        echo "🔍 Inicializando base de datos de atuin..."
        atuin import auto
    fi
fi

echo ""
echo "🎉 ¡Instalación completada!"
echo ""
if [[ "$ACTION" == "stow" ]]; then
    echo "✅ Dotfiles instalados correctamente"
    if [[ "$INSTALL_SYSTEM" == true ]]; then
        echo "✅ Paquetes del sistema instalados"
        echo "✅ Herramientas de desarrollo configuradas"
        echo ""
        echo "🛠️  Herramientas disponibles:"
        echo "   • Docker + Docker Compose"
        echo "   • Python + pip + pyenv"
        echo "   • Node.js + npm + yarn + nvm"
        echo "   • VS Code + extensiones"
        echo "   • Git con aliases optimizados"
        echo "   • Kubernetes (kubectl + k9s)"
        echo ""
        echo "📜 Comandos útiles:"
        echo "   dev-status  - Verificar estado del entorno"
        echo "   dev-init    - Crear nuevos proyectos"
        echo "   dev-clean   - Limpiar archivos temporales"
        echo "   code-ext    - Instalar extensiones de VS Code"
        echo ""
        echo "🐚 Para aplicar completamente la configuración:"
        echo "   1. Cierra la terminal actual"
        echo "   2. Abre una nueva terminal (zsh será el shell por defecto)"
        echo "   3. Disfruta de tu nuevo entorno! 🚀"
    else
        echo "💡 Reinicia tu shell para aplicar los cambios de dotfiles"
    fi
    echo ""
    echo "🔧 Para desinstalar usa: $0 -u [paquetes]"
else
    echo "🗑️  Dotfiles desinstalados correctamente"
fi