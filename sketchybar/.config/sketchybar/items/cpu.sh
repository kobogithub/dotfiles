#!/usr/bin/env bash
# CPU. El plugin tarda 1s en muestrear, así que no conviene bajar update_freq
# mucho más: dejaría el muestreo casi encadenado.

sketchybar --add item cpu right \
           --set cpu \
                 icon="" \
                 update_freq=10 \
                 script="$PLUGIN_DIR/cpu.sh"
