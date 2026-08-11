#!/usr/bin/env bash
# Volumen: lo pinta y también lo controla.
#   - click izquierdo  -> abre / cierra el popup
#   - click derecho    -> silencia / restaura
#   - rueda del ratón  -> sube o baja en pasos de VOLUME_STEP
#   - argumento toggle_mute -> lo usa la fila de silencio del popup
# El resto de SENDER (volume_change, arranque) solo repintan.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

VOLUME_STEP=5
ITEM="${NAME:-volume}"

# Pregunta al sistema en vez de fiarse de $INFO: tras un click o un scroll el
# valor de $INFO es el de antes del cambio, o directamente no existe.
current_volume() {
    osascript -e 'output volume of (get volume settings)' 2>/dev/null
}

toggle_mute() {
    osascript -e 'set volume output muted not (output muted of (get volume settings))' 2>/dev/null
}

# El popup se cierra solo al sacar el ratón; aquí no hay nada que repintar.
if [ "$SENDER" = "mouse.exited.global" ]; then
    sketchybar --set "$ITEM" popup.drawing=off
    exit 0
fi

interacted=0

if [ "$1" = "toggle_mute" ]; then
    toggle_mute
    sketchybar --set "$ITEM" popup.drawing=off
    interacted=1
fi

case "$SENDER" in
    mouse.clicked)
        interacted=1
        if [ "$BUTTON" = "right" ]; then
            toggle_mute
        else
            sketchybar --set "$ITEM" popup.drawing=toggle
        fi
        ;;
    mouse.scrolled)
        interacted=1
        vol="$(current_volume)"
        [ -n "$vol" ] || exit 0
        vol=$((vol + (SCROLL_DELTA > 0 ? VOLUME_STEP : -VOLUME_STEP)))
        [ "$vol" -gt 100 ] && vol=100
        [ "$vol" -lt 0 ] && vol=0
        # Subir el volumen con la rueda implica querer oírlo: quita el mute.
        osascript -e "set volume output volume $vol output muted false" 2>/dev/null
        ;;
esac

# Tras interactuar, $INFO ya no vale: trae el nivel anterior al cambio.
vol="$INFO"
[ "$interacted" -eq 1 ] && vol=""
[ -n "$vol" ] || vol="$(current_volume)"
muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

[ -n "$vol" ] || exit 0

if [ "$muted" = "true" ] || [ "$vol" -eq 0 ]; then
    icon=""
    color="$FG_DIM"
    mute_label="Activar sonido"
elif [ "$vol" -ge 50 ]; then
    icon=""
    color="$ACCENT"
    mute_label="Silenciar"
else
    icon=""
    color="$ACCENT"
    mute_label="Silenciar"
fi

sketchybar --set "$ITEM" icon="$icon" icon.color="$color" label="${vol}%" \
           --set volume_slider slider.percentage="$vol" \
           --set volume.mute icon="$icon" label="$mute_label"
