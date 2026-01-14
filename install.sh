#!/bin/bash

# Script de instalación para dotfiles
# Este script crea enlaces simbólicos de los archivos de configuración

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo "📂 Instalando dotfiles desde $DOTFILES_DIR"

# Función para crear enlace simbólico
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        echo "🔗 $target ya es un enlace simbólico"
        return
    fi
    
    if [ -f "$target" ] || [ -d "$target" ]; then
        echo "📁 Creando backup de $target"
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    echo "🔗 Creando enlace: $target -> $source"
    ln -s "$source" "$target"
}

# Crear directorio .config si no existe
mkdir -p "$HOME_DIR/.config"

# Enlazar archivos de configuración
echo "🔧 Enlazando archivos de configuración..."

# Enlazar archivos del directorio home
if [ -d "$DOTFILES_DIR/home" ]; then
    for file in "$DOTFILES_DIR/home"/.* "$DOTFILES_DIR/home"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            create_symlink "$file" "$HOME_DIR/$filename"
        fi
    done
fi

# Enlazar directorios de configuración
if [ -d "$DOTFILES_DIR/config" ]; then
    for dir in "$DOTFILES_DIR/config"/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            create_symlink "$dir" "$HOME_DIR/.config/$dirname"
        fi
    done
fi

# Hacer ejecutables los scripts
if [ -d "$DOTFILES_DIR/bin" ]; then
    chmod +x "$DOTFILES_DIR/bin"/*
fi

echo "✅ Instalación completada!"
echo "💡 Reinicia tu shell o ejecuta 'source ~/.bashrc' (o ~/.zshrc) para aplicar los cambios"