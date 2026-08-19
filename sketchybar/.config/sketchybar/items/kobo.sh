#!/usr/bin/env bash
# kobo — lo que requiere atención hoy, siempre a la vista.
#
# El aviso de kobo salía por notificación de macOS y no llegaba: `osascript`
# las publica como "Script Editor", un bundle que no está registrado en el
# Centro de Notificaciones, así que el AppleScript devolvía rc=0 y no se
# mostraba nada. Un item en la barra es persistente por naturaleza y no por
# configuración del sistema: se queda hasta que la causa se resuelve.
#
# En una máquina sin kobo el item no se agrega — estos dotfiles se estiran a
# máquinas donde el repo privado no está clonado.
#
# OJO con el PATH, misma trampa que docker.sh: sketchybar arranca desde launchd
# con /opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin, y `kobo` vive en
# ~/.local/bin, que ahí no está. Por eso la ruta absoluta.
[ -x "$HOME/.local/bin/kobo" ] || return 0

# Nace oculto: con la agenda en orden no se dibuja nada, que es la mitad del
# valor. `updates=on` es obligatorio — el `when_shown` que hereda de --default
# congelaría el item mientras está apagado y no volvería a encenderse nunca.
sketchybar --add item kobo right \
           --set kobo \
                 drawing=off \
                 updates=on \
                 icon="󰀪" \
                 update_freq=120 \
                 script="$PLUGIN_DIR/kobo.sh" \
                 click_script="$PLUGIN_DIR/kobo.sh popup" \
           --subscribe kobo system_woke
