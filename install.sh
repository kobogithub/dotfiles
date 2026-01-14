#!/bin/bash

# Script de instalación para dotfiles usando GNU Stow
# Automatiza la instalación de paquetes del sistema y configuraciones

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paquetes del sistema que siempre se instalan
SYSTEM_PACKAGES=(
    "neovim"
    "tmux" 
    "github-cli"
    "zsh"
    "lsd"
    "starship"
    "atuin"
    "stow"
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
)

echo "🏠 Instalando dotfiles de Kevin Barroso"
echo "📂 Desde: $DOTFILES_DIR"

# Función para verificar si estamos en Arch Linux
check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        echo "❌ Este script está optimizado para Arch Linux"
        echo "💡 Instala manualmente los paquetes necesarios y ejecuta solo la configuración de dotfiles"
        read -p "¿Continuar solo con dotfiles? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        return 1
    fi
    return 0
}

# Función para instalar paquetes del sistema
install_system_packages() {
    echo "🔧 Instalando paquetes del sistema..."
    
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
    
    # Verificar si hay conflictos usando stow dry-run
    if ! stow -n -d "$DOTFILES_DIR" -t "$HOME" "$package" 2>/dev/null; then
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
        done < <(stow -n -d "$DOTFILES_DIR" -t "$HOME" "$package" 2>&1)
        
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
        
        # Intentar instalar con stow
        if stow -d "$DOTFILES_DIR" -t "$HOME" "$package" -v; then
            echo "✅ $package instalado correctamente"
        else
            echo "❌ Error instalando $package"
            return 1
        fi
    else
        stow -d "$DOTFILES_DIR" -t "$HOME" -D "$package" -v
        echo "✅ $package desinstalado correctamente"
    fi
}

# Función para configurar zsh como shell por defecto
setup_zsh() {
    if [[ "$SHELL" != */zsh ]]; then
        echo "🐚 Configurando zsh como shell por defecto..."
        chsh -s $(which zsh)
        echo "✅ Zsh configurado como shell por defecto"
        echo "💡 Cierra la sesión y vuelve a entrar para aplicar cambios"
    else
        echo "✅ Zsh ya es el shell por defecto"
    fi
}

# Función para configurar locales
setup_locale() {
    echo "🌍 Configurando locales del sistema..."
    
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
    echo "PAQUETES del sistema que se instalan:"
    for package in "${SYSTEM_PACKAGES[@]}"; do
        echo "  $package"
    done
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

# Verificar si stow está disponible para dotfiles
if [[ "$INSTALL_DOTFILES" == true ]] && ! command -v stow &> /dev/null; then
    echo "❌ GNU Stow no está instalado y es necesario para los dotfiles"
    if check_arch; then
        echo "📦 Instalando stow..."
        sudo pacman -S stow --noconfirm
    else
        echo "💡 Instala stow manualmente: sudo pacman -S stow"
        exit 1
    fi
fi

# Instalar paquetes del sistema
if [[ "$INSTALL_SYSTEM" == true ]]; then
    if check_arch; then
        install_system_packages
    else
        echo "⚠️  Saltando instalación de paquetes del sistema (no es Arch Linux)"
    fi
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
    
    # Configurar zsh como shell por defecto
    setup_zsh
    
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