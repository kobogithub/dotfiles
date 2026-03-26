# ~/.profile - Configuraciones del sistema

# Configuración de locale para evitar warnings de Perl
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export LC_CTYPE=C.UTF-8

# Configuración del PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Variables de entorno
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox
export TERMINAL=alacritty

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# History configuration
export HISTFILE="$XDG_DATA_HOME/bash/history"
export HISTSIZE=10000
export HISTFILESIZE=20000

# Configuración para menos warnings y mejor compatibilidad
export LESSHISTFILE=-
export LESSCHARSET=utf-8

# Configuración para aplicaciones
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
. "/home/kobo/.local/share/cargo/env"
