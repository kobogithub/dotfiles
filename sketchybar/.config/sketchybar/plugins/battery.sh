#!/usr/bin/env bash
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

batt="$(pmset -g batt)"
pct="$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | tr -d '%')"
charging="$(printf '%s' "$batt" | grep -c 'AC Power')"

# Un Mac de escritorio no tiene porcentaje: escondemos el item.
if [ -z "$pct" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

if [ "$charging" -ne 0 ]; then
    icon=""
    color="$GREEN"
elif [ "$pct" -ge 80 ]; then
    icon=""
    color="$GREEN"
elif [ "$pct" -ge 60 ]; then
    icon=""
    color="$GREEN"
elif [ "$pct" -ge 40 ]; then
    icon=""
    color="$LIGHT"
elif [ "$pct" -ge 20 ]; then
    icon=""
    color="$LIGHT"
else
    icon=""
    color="$RED"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$color" label="${pct}%"
