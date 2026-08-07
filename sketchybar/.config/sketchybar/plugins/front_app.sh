#!/usr/bin/env bash
# sketchybar entrega el nombre de la app en $INFO al disparar front_app_switched.

if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set "$NAME" label="$INFO"
fi
