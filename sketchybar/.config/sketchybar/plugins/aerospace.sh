#!/usr/bin/env bash
# Repinta todos los indicadores de workspace en una sola llamada a sketchybar.
# Lo invoca el item oculto `spaces_listener` (ver items/spaces.sh).

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

focused="$(aerospace list-workspaces --focused 2>/dev/null)"
occupied="$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)"
all="$(aerospace list-workspaces --all 2>/dev/null)"

# AeroSpace no responde (aún arrancando, o parado): no tocamos nada.
[ -n "$all" ] || exit 0

args=()
for sid in $all; do
    if [ "$sid" = "$focused" ]; then
        # Enfocado: pastilla azul, texto en el color del fondo para contraste.
        args+=(--set "space.$sid" drawing=on background.drawing=on \
                     background.color="$BLUE" label.color="$BAR_BG")
    elif printf '%s\n' "$occupied" | grep -qx -- "$sid"; then
        # Ocupado pero no enfocado: solo el número, sin pastilla.
        args+=(--set "space.$sid" drawing=on background.drawing=off \
                     label.color="$LIGHT")
    else
        args+=(--set "space.$sid" drawing=off)
    fi
done

[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
