#!/usr/bin/env bash
# Batería. update_freq es la red de seguridad; el evento power_source_change
# es quien la refresca al enchufar o desenchufar.

sketchybar --add item battery right \
           --set battery \
                 update_freq=120 \
                 script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery power_source_change system_woke
