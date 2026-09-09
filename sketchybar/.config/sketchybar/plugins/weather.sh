#!/usr/bin/env bash
# Clima vía wttr.in.
#
# La ubicación sale de la IP pública; para fijarla a mano, exporta
# WEATHER_LOCATION en el sketchybarrc (p. ej. "Madrid" o "Bogota").
# Se pide el formato corto "condición|temperatura" en inglés a propósito: el
# texto solo se usa para elegir el icono, y traducido no casaría con el case.
# El parámetro `m` fuerza grados Celsius; sin él wttr.in decide por la IP y
# devuelve Fahrenheit desde EE. UU. (cámbialo por `u` si quieres Fahrenheit).
# Si no hay red, el item se queda apagado en vez de desaparecer.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

data="$(curl -sf --max-time 8 "https://wttr.in/${WEATHER_LOCATION:-}?format=%C|%t&m" 2>/dev/null)"

if [ -z "$data" ] || [ "${data#*|}" = "$data" ]; then
    sketchybar --set "$NAME" icon="" icon.color="$FG_DIM" \
                             label="--" label.color="$FG_DIM"
    exit 0
fi

condition="$(echo "${data%%|*}" | tr '[:upper:]' '[:lower:]')"
# %t viene como "+22°C": sobra el signo y los espacios que mete wttr.in.
temp="$(echo "${data#*|}" | tr -d ' +')"

hour="$(date +%-H)"
if [ "$hour" -ge 20 ] || [ "$hour" -lt 6 ]; then
    clear_icon=""   # luna
else
    clear_icon=""   # sol
fi

case "$condition" in
    *thunder*)                     icon="" ; color="$YELLOW" ;;
    *snow* | *sleet* | *blizzard* | *ice*)
                                   icon="" ; color="$LIGHT" ;;
    *rain* | *drizzle* | *shower*) icon="" ; color="$BLUE" ;;
    *mist* | *fog* | *haze*)       icon="" ; color="$FG_DIM" ;;
    *partly*)                      icon="" ; color="$LIGHT" ;;
    *cloud* | *overcast*)          icon="" ; color="$LIGHT" ;;
    *sunny* | *clear*)             icon="$clear_icon" ; color="$ACCENT" ;;
    *)                             icon="" ; color="$LIGHT" ;;
esac

sketchybar --set "$NAME" icon="$icon" icon.color="$color" \
                         label="$temp" label.color="$FG"
