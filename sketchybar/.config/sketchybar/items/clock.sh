#!/usr/bin/env bash
# Reloj. Va el primero por la derecha, así que queda en el extremo.

sketchybar --add item clock right \
           --set clock \
                 icon="" \
                 icon.color="$ACCENT" \
                 label.color="$FG" \
                 update_freq=10 \
                 script="$PLUGIN_DIR/clock.sh"
