#!/usr/bin/env bash
# Aplicación en foco, a la derecha de los workspaces.

sketchybar --add item front_app left \
           --set front_app \
                 icon="" \
                 icon.color="$PURPLE" \
                 icon.padding_left=14 \
                 label.color="$PURPLE" \
                 label.font="$FONT:Bold:13.0" \
                 script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
