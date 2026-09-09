#!/usr/bin/env bash
# Red. Detecta sola si la conexión activa es Wi-Fi o Ethernet, en vez de
# asumir en0: en esta máquina en0 es Ethernet y el Wi-Fi es en1.

sketchybar --add item network right \
           --set network \
                 update_freq=30 \
                 script="$PLUGIN_DIR/network.sh" \
           --subscribe network wifi_change system_woke
