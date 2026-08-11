#!/usr/bin/env bash
# Volumen. Se refresca solo con el evento volume_change, sin timer.
# El plugin maneja los eventos de ratón, por eso no hay click_script:
# definirlo se comería el evento mouse.clicked.
#
#   click izquierdo -> abre / cierra el popup con el slider
#   click derecho   -> silencia sin abrir el popup
#   rueda           -> sube o baja el nivel

sketchybar --add item volume right \
           --set volume \
                 script="$PLUGIN_DIR/volume.sh" \
                 popup.background.color="$POPUP_BG" \
                 popup.background.border_color="$BAR_BORDER" \
                 popup.background.border_width=2 \
                 popup.background.corner_radius=8 \
                 popup.background.shadow.drawing=on \
                 popup.align=right \
                 popup.y_offset=6 \
           --subscribe volume volume_change mouse.clicked mouse.scrolled \
                              mouse.exited.global

# Slider del popup. updates=on es obligatorio: un item de popup nace oculto y
# con el `when_shown` que hereda de --default no se refrescaría nunca, así que
# se quedaría clavado en el nivel que hubiera al arrancar.
sketchybar --add slider volume_slider popup.volume 140 \
           --set volume_slider \
                 updates=on \
                 script="$PLUGIN_DIR/volume_slider.sh" \
                 icon.drawing=off \
                 label.drawing=off \
                 slider.background.height=6 \
                 slider.background.corner_radius=3 \
                 slider.background.color="$FG_DIM" \
                 slider.highlight_color="$ACCENT" \
                 slider.knob="●" \
                 slider.knob.drawing=on \
           --subscribe volume_slider mouse.clicked

# Fila de silencio dentro del popup.
sketchybar --add item volume.mute popup.volume \
           --set volume.mute \
                 icon="" \
                 icon.color="$LIGHT" \
                 label="Silenciar" \
                 label.color="$LIGHT" \
                 click_script="$PLUGIN_DIR/volume.sh toggle_mute"
