#!/usr/bin/env bash
# Uso de CPU.
#
# iostat con dos muestras: la primera es el promedio desde el arranque y no
# sirve de nada, la segunda es el uso real del último segundo. Espera 1s pero
# gasta ~0 de CPU, al revés que `top -l 2`, que se come medio segundo de CPU
# cada vez — caro para algo que corre en bucle en la barra.
#
# Las columnas de disco varían según cuántos discos tenga la máquina, así que
# los campos se cuentan desde el final: los tres últimos son el load average y
# justo antes van us, sy, id.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

used="$(iostat -c 2 -w 1 2>/dev/null | tail -1 | awk 'NF >= 6 { printf "%.0f", 100 - $(NF-3) }')"

[ -n "$used" ] || exit 0

if [ "$used" -ge 85 ]; then
    color="$RED"
elif [ "$used" -ge 60 ]; then
    color="$YELLOW"
else
    color="$ACCENT"
fi

sketchybar --set "$NAME" icon.color="$color" label="${used}%"
