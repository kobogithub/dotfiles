#!/usr/bin/env bash
# Clima. Media hora entre consultas: wttr.in limita las peticiones por IP y
# la temperatura tampoco cambia tan rápido. Un click fuerza el refresco.

sketchybar --add item weather right \
           --set weather \
                 update_freq=1800 \
                 script="$PLUGIN_DIR/weather.sh" \
                 click_script="$PLUGIN_DIR/weather.sh" \
           --subscribe weather system_woke wifi_change
