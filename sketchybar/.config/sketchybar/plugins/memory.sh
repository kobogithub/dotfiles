#!/usr/bin/env bash
# Memoria en uso.
#
# vm_stat cuenta páginas. La "memoria usada" que enseña Monitor de Actividad
# es active + wired + comprimida; la inactiva NO cuenta, es caché que el
# sistema recupera en cuanto hace falta. vm_stat es instantáneo (~5ms).

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

total="$(sysctl -n hw.memsize 2>/dev/null)"
[ -n "$total" ] || exit 0

used="$(vm_stat 2>/dev/null | awk -v total="$total" '
    /page size of/                 { ps = $8; gsub(/[^0-9]/, "", ps) }
    /Pages active/                 { gsub(/\./, ""); active = $3 }
    /Pages wired down/             { gsub(/\./, ""); wired = $4 }
    /Pages occupied by compressor/ { gsub(/\./, ""); comp = $5 }
    END {
        if (ps == 0 || total == 0) exit 1
        printf "%.0f", (active + wired + comp) * ps * 100 / total
    }
')"

[ -n "$used" ] || exit 0

if [ "$used" -ge 90 ]; then
    color="$RED"
elif [ "$used" -ge 75 ]; then
    color="$YELLOW"
else
    color="$ACCENT"
fi

sketchybar --set "$NAME" icon.color="$color" label="${used}%"
