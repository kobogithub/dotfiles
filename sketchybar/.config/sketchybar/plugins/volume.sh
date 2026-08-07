#!/usr/bin/env bash
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# volume_change trae el nivel en $INFO. Al arrancar no hay evento, así que
# preguntamos al sistema.
vol="$INFO"
if [ -z "$vol" ]; then
    vol="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi
muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

[ -n "$vol" ] || exit 0

if [ "$muted" = "true" ] || [ "$vol" -eq 0 ]; then
    icon=""
    color="$FG_DIM"
elif [ "$vol" -ge 50 ]; then
    icon=""
    color="$ACCENT"
else
    icon=""
    color="$ACCENT"
fi

sketchybar --set "$NAME" icon="$icon" icon.color="$color" label="${vol}%"
