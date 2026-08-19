#!/usr/bin/env bash
# Dibuja el estado de kobo en la barra. Ver items/kobo.sh para el porqué.
#
# En la barra van solo el símbolo y la cantidad. El nombre del cliente queda
# para el popup, que se abre con un clic: el repo de kobo es privado porque las
# fichas llevan nombres de clientes y contrapartes, y una barra de estado está
# visible en cualquier screen share o captura. Lo mismo vale para este archivo,
# que vive en unos dotfiles públicos: acá no hay ni un dato, solo la llamada.
#
# `kobo alarma --json` es lectura pura: no notifica ni marca nada como avisado.
# Si marcara, este script —que corre cada 2 minutos— dejaría mudos a la alarma
# diaria y al hook del SessionStart en el primer refresco.

KOBO="$HOME/.local/bin/kobo"
[ -x "$KOBO" ] || exit 0

source "$CONFIG_DIR/colors.sh"

DATOS=$("$KOBO" alarma --json 2>/dev/null) || DATOS=""

if [ -z "$DATOS" ]; then
    sketchybar --set "$NAME" drawing=off popup.drawing=off
    exit 0
fi

leer() { printf '%s' "$DATOS" | /usr/bin/python3 -c "
import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
print(d.get('$1') or 0)
"; }

CANTIDAD=$(leer cantidad)
PESO=$(leer peso_max)

if [ "${CANTIDAD:-0}" -eq 0 ]; then
    # Nada que avisar: silencio. Es la señal de que está todo en orden.
    sketchybar --set "$NAME" drawing=off popup.drawing=off
    exit 0
fi

# El color sale del mismo peso que ordena la lista, sin inventar otra escala:
# 5 y 6 son compromiso vencido o sin margen —hoy o ya tarde—, 4 es la ventana
# de renegociación, y de ahí para abajo es contexto.
if [ "${PESO:-0}" -ge 5 ]; then
    COLOR="$RED"
elif [ "${PESO:-0}" -ge 4 ]; then
    COLOR="$YELLOW"
else
    COLOR="$LIGHT"
fi

sketchybar --set "$NAME" \
           drawing=on \
           label="$CANTIDAD" \
           icon.color="$COLOR" \
           label.color="$COLOR"

# `$BUTTON` lo pone sketchybar recién al hacer clic, así que la decisión va acá
# y no en el click_script del item: ahí se evaluaría al registrar el item, con
# la variable todavía vacía, y quedaría fija para siempre.
if [ "$1" = "click" ]; then
    [ "${BUTTON:-left}" = "right" ] && set -- ventana || set -- popup
fi

# --- la ventana, con el detalle completo -------------------------------------
# Ghostty en macOS no se lanza desde el CLI —`+new-window` responde "not
# supported on this platform"— así que hay que ir por `open -na`.
#
# Va con `--command=` y NO con `-e`: medido el 2026-08-19, `-e` abre DOS
# ventanas, la inicial de Ghostty más la del comando. Con `--initial-window=false`
# para tapar eso no abre ninguna, porque la del comando ES la inicial.
# `--command=` hace que la ventana inicial corra el script: una sola.
#
# El título fijo es lo que le da a AeroSpace con qué reconocerla para flotarla:
# el app-id solo matchearía todas las terminales.
if [ "$1" = "ventana" ]; then
    # Esquina superior derecha, justo debajo de la barra flotante (8 de margen
    # + 32 de alto + 8 = 48). Fija y no donde la deje macOS: una ventana de
    # consulta que aparece cada vez en otro lado obliga a buscarla.
    # 104 columnas porque kobo renderiza a 100 fijas — ver lib/ui.py.
    open -na Ghostty.app --args \
        --title=kobo-alarma \
        --window-width=104 \
        --window-height=32 \
        --window-position-x=1640 \
        --window-position-y=56 \
        --command="$PLUGIN_DIR/kobo-ventana.sh"
    exit 0
fi

# --- el popup, solo al hacer clic -------------------------------------------
if [ "$1" = "popup" ]; then
    ESTADO=$(sketchybar --query "$NAME" | /usr/bin/python3 -c "
import json,sys
try: print(json.load(sys.stdin)['popup']['drawing'])
except Exception: print('off')
")
    if [ "$ESTADO" = "on" ]; then
        sketchybar --set "$NAME" popup.drawing=off
        exit 0
    fi

    # Se rearma entero cada vez: los items viejos se borran antes de agregar.
    for viejo in $(sketchybar --query bar | /usr/bin/python3 -c "
import json,sys
print(' '.join(x for x in json.load(sys.stdin)['items'] if x.startswith('kobo.linea')))
"); do
        sketchybar --remove "$viejo"
    done

    printf '%s' "$DATOS" | /usr/bin/python3 -c "
import json,sys
d=json.load(sys.stdin)
for i,x in enumerate(d.get('items') or []):
    # El detalle trae el motivo y la acción separados por una flecha; en el
    # popup entra el motivo, que es lo que dice qué pasa.
    motivo=str(x.get('detalle') or '').split(' → ')[0]
    print('%d\t%s\t%s' % (i, x.get('tema') or '', motivo[:64]))
" | while IFS=$'\t' read -r i tema motivo; do
        sketchybar --add item "kobo.linea.$i" popup."$NAME" \
                   --set "kobo.linea.$i" \
                         icon="$tema" \
                         icon.color="$ACCENT" \
                         label="$motivo" \
                         label.color="$FG" \
                         background.color="$POPUP_BG" \
                         click_script="sketchybar --set $NAME popup.drawing=off"
    done
    sketchybar --set "$NAME" popup.drawing=on
fi
