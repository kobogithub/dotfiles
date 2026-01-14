#!/bin/bash

# Script de instalación para dotfiles usando GNU Stow
# Automatiza la instalación de paquetes de configuración

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📂 Instalando dotfiles desde $DOTFILES_DIR usando GNU Stow"

# Verificar si stow está instalado
if ! command -v stow &> /dev/null; then
    echo "❌ GNU Stow no está instalado."
    echo "📦 Instálalo con:"
    echo "   Ubuntu/Debian: sudo apt install stow"
    echo "   macOS: brew install stow"
    echo "   Arch: sudo pacman -S stow"
    exit 1
fi

# Función para instalar un paquete con stow
install_package() {
    local package="$1"
    local action="${2:-stow}"
    
    if [ ! -d "$package" ]; then
        echo "⚠️  Directorio $package no existe, saltando..."
        return
    fi
    
    echo "📦 ${action^}ing $package..."
    if [ "$action" = "stow" ]; then
        stow -d "$DOTFILES_DIR" -t "$HOME" "$package" -v
    else
        stow -d "$DOTFILES_DIR" -t "$HOME" -D "$package" -v
    fi
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIONES] [PAQUETES...]"
    echo ""
    echo "OPCIONES:"
    echo "  -h, --help        Mostrar esta ayuda"
    echo "  -u, --uninstall   Desinstalar paquetes (unstow)"
    echo "  -a, --all         Instalar todos los paquetes disponibles"
    echo ""
    echo "PAQUETES disponibles:"
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != ".git/" ]; then
            echo "  ${dir%/}"
        fi
    done
    echo ""
    echo "Ejemplos:"
    echo "  $0 git bash vim          # Instalar paquetes específicos"
    echo "  $0 -a                    # Instalar todos los paquetes"
    echo "  $0 -u git               # Desinstalar el paquete git"
}

# Procesar argumentos
ACTION="stow"
PACKAGES=()
INSTALL_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--uninstall)
            ACTION="unstow"
            shift
            ;;
        -a|--all)
            INSTALL_ALL=true
            shift
            ;;
        *)
            PACKAGES+=("$1")
            shift
            ;;
    esac
done

cd "$DOTFILES_DIR"

# Determinar qué paquetes instalar
if [ "$INSTALL_ALL" = true ]; then
    echo "🔧 Instalando todos los paquetes disponibles..."
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != ".git/" ]; then
            install_package "${dir%/}" "$ACTION"
        fi
    done
elif [ ${#PACKAGES[@]} -eq 0 ]; then
    # Si no se especificaron paquetes, mostrar opciones
    echo "📋 Selecciona los paquetes a instalar:"
    echo ""
    show_help
    exit 0
else
    # Instalar paquetes específicos
    for package in "${PACKAGES[@]}"; do
        install_package "$package" "$ACTION"
    done
fi

echo ""
echo "✅ Operación completada!"
if [ "$ACTION" = "stow" ]; then
    echo "💡 Reinicia tu shell para aplicar los cambios"
    echo "🔧 Para desinstalar usa: $0 -u [paquetes]"
else
    echo "🗑️  Paquetes desinstalados correctamente"
fi