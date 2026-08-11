#!/usr/bin/env bash
# Memoria. Consultar vm_stat es instantáneo, se puede refrescar a menudo.

sketchybar --add item memory right \
           --set memory \
                 icon="󰍛" \
                 update_freq=5 \
                 script="$PLUGIN_DIR/memory.sh"
