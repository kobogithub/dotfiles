# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/kobo/.docker/bin"
# End of Docker Desktop section.

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

# GnuPG no respeta XDG: su default es ~/.gnupg en Arch y macOS. No seteamos
# GNUPGHOME — apuntarlo a $XDG_DATA_HOME/gnupg rompe la firma de commits
# porque el keyring real nunca vive ahí.

# Cargo/Rust — portable: si cargo vive en XDG (Arch) usar esa ubicación;
# si está en el default ~/.cargo (macOS/rustup) usar esa. Guardado para no
# romper en máquinas sin Rust.
if [ -f "$XDG_DATA_HOME/cargo/env" ]; then
    export CARGO_HOME="$XDG_DATA_HOME/cargo"
    export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
    . "$XDG_DATA_HOME/cargo/env"
elif [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
