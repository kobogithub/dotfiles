#!/usr/bin/env bash
# Volumen. Se refresca solo con el evento volume_change, sin timer.

sketchybar --add item volume right \
           --set volume \
                 script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change
