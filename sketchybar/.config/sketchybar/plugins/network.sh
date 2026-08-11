#!/usr/bin/env bash
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# Interfaz por la que sale la ruta por defecto: la que realmente se usa.
iface="$(route get default 2>/dev/null | awk '/interface:/{print $2}')"

if [ -z "$iface" ]; then
    sketchybar --set "$NAME" icon="" icon.color="$RED" label="offline"
    exit 0
fi

wifi_dev="$(networksetup -listallhardwareports 2>/dev/null \
            | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')"

if [ "$iface" = "$wifi_dev" ]; then
    # macOS restringe el SSID sin permiso de localización; si no lo da,
    # nos quedamos con el nombre de la interfaz.
    ssid="$(networksetup -getairportnetwork "$iface" 2>/dev/null \
            | sed -n 's/^Current Wi-Fi Network: //p')"
    sketchybar --set "$NAME" icon="" icon.color="$ACCENT" \
                             label="${ssid:-wifi}"
else
    sketchybar --set "$NAME" icon="" icon.color="$GREEN" label="eth"
fi
