#!/usr/bin/env bash
# Slider del popup de volumen. Al arrastrarlo, sketchybar dispara
# mouse.clicked con la posición ya calculada en $PERCENTAGE.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"

[ -n "$PERCENTAGE" ] || exit 0

osascript -e "set volume output volume $PERCENTAGE output muted false" 2>/dev/null

# El item de la barra hay que repintarlo a mano: volume_change no llega de
# forma fiable cuando el cambio lo provoca el propio slider, y el icono y el
# porcentaje se quedarían con el valor anterior. INFO evita que volume.sh
# tenga que preguntarle el nivel al sistema otra vez en pleno arrastre.
NAME=volume INFO="$PERCENTAGE" "$PLUGIN_DIR/volume.sh"
