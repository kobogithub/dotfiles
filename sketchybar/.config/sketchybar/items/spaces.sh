#!/usr/bin/env bash
# Indicadores de workspace de AeroSpace.
#
# Se crea un item por cada workspace persistente, pero todos nacen ocultos:
# el plugin decide cuáles se dibujan (ocupados + el enfocado). Con 30
# workspaces declarados en .aerospace.toml, pintarlos todos sería inusable.
#
# Solo `spaces_listener` se suscribe al evento. Repinta los 30 de una sola
# pasada, así un cambio de workspace cuesta 2 llamadas a aerospace + 1 a
# sketchybar, en vez de una pareja por cada workspace.

sketchybar --add event aerospace_workspace_change

for sid in $(aerospace list-workspaces --all 2>/dev/null); do
    sketchybar --add item "space.$sid" left \
               --set "space.$sid" \
                     drawing=off \
                     icon.drawing=off \
                     label="$sid" \
                     label.font="$FONT:Bold:13.0" \
                     label.padding_left=9 \
                     label.padding_right=9 \
                     background.corner_radius=6 \
                     background.height=22 \
                     click_script="aerospace workspace $sid"
done

# updates=on es obligatorio aquí: el default de la barra es `when_shown`, y
# este item va oculto (drawing=off). Un item oculto con `when_shown` no
# ejecuta su script nunca, ni por timer ni por evento, y los workspaces se
# quedarían congelados en el estado del arranque.
sketchybar --add item spaces_listener left \
           --set spaces_listener \
                 drawing=off \
                 updates=on \
                 update_freq=5 \
                 script="$PLUGIN_DIR/aerospace.sh" \
           --subscribe spaces_listener aerospace_workspace_change front_app_switched
