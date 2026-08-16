#!/usr/bin/env bash
# Docker: si el daemon responde y cuántos contenedores hay corriendo.
#
# Se le pregunta a la API por el socket con curl en vez de llamar a `docker ps`:
# con el daemon caído el CLI se queda esperando el timeout de conexión, y acá el
# refresco tiene que costar siempre lo mismo. `--max-time 2` es la cota.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# Click: abre Docker Desktop (lo arranca si estaba apagado, lo trae al frente si
# ya corría). No se apaga desde acá a propósito: se llevaría puestos los
# contenedores en marcha sin preguntar.
if [ "$1" = "open" ]; then
    open -a Docker
    exit 0
fi

# El socket de Docker Desktop vive en el home; /var/run/docker.sock suele ser un
# symlink a él, pero no está en toda instalación.
sock=""
for candidate in "${DOCKER_HOST#unix://}" "$HOME/.docker/run/docker.sock" \
                 /var/run/docker.sock; do
    if [ -S "$candidate" ]; then
        sock="$candidate"
        break
    fi
done

# Sin daemon el item no dice nada útil, así que se saca de la barra en vez de
# dejar una ballena apagada ocupando lugar. Vuelve solo: el item se declara con
# updates=on, así que el timer sigue corriendo aunque no se dibuje.
offline() {
    sketchybar --set "$NAME" drawing=off
    exit 0
}

[ -n "$sock" ] || offline

# /containers/json sin filtros ya devuelve solo los que están corriendo.
containers="$(curl -s --unix-socket "$sock" --max-time 2 \
              http://localhost/containers/json 2>/dev/null)"
[ -n "$containers" ] || offline

if command -v jq >/dev/null 2>&1; then
    # Si el daemon contesta un error, el cuerpo es un objeto y no un array:
    # el `empty` deja count vacío y lo tratamos como apagado.
    count="$(printf '%s' "$containers" \
             | jq -r 'if type == "array" then length else empty end' 2>/dev/null)"
else
    # -o y no -c: la respuesta viene en una sola línea, contar líneas daría 1.
    count="$(printf '%s' "$containers" | grep -o '"Id":' | wc -l | tr -d ' ')"
fi

[ -n "$count" ] || offline

# Cyan = daemon arriba sin nada corriendo; verde = hay contenedores vivos.
if [ "$count" -gt 0 ]; then
    color="$GREEN"
else
    color="$ACCENT"
fi

sketchybar --set "$NAME" drawing=on icon.color="$color" label="$count"
