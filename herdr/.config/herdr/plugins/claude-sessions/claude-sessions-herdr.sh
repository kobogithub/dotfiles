#!/bin/bash

# claude-sessions-herdr - Plugin de herdr sobre el script claude-sessions
#
# El buscador de sesiones es el mismo `claude-sessions` (ccs) del paquete
# scripts/: aca solo se traduce lo elegido a comandos de herdr. La logica de
# listar y previsualizar sesiones NO se duplica — si se reescribiera, las dos
# copias se desincronizarian la primera vez que cambie el formato del .jsonl.
#
# Lo que agrega sobre `ccs` a secas: el script termina en `cd` + `exec claude`,
# o sea que se come el pane donde estabas. Aca la sesion se abre en su propio
# workspace (o pestaña) y el pane de trabajo queda intacto.
#
# Modos:
#   open   Pide a herdr que abra el popup del buscador. Es lo que corre la
#          accion bindeada a una tecla, que no tiene terminal propia.
#   pick   Corre dentro del popup: elige la sesion y la abre donde corresponda.

set -euo pipefail

PLUGIN_ID="dotfiles.claude-sessions"
HERDR="${HERDR_BIN_PATH:-herdr}"

# Cuanto esperar a que la shell del pane nuevo termine de arrancar.
START_TRIES=80
START_WAIT=0.25

# Arranca claude en un pane recien creado.
#
# Dos cosas que hay que manejar si o si, las dos descubiertas probando:
#
#   agent_pane_busy   `workspace create` devuelve el pane al toque, pero
#                     adentro recien esta arrancando zsh con starship, atuin y
#                     nvm. Hasta que no termina, `agent start` rebota. Se
#                     reintenta; en esta maquina tarda ~3s.
#
#   agent_name_taken  Los nombres de agente son unicos. Abrir una segunda
#                     sesion del mismo proyecto choca con la primera, porque
#                     las dos se querrian llamar igual. Se cae al nombre con
#                     el prefijo del sessionId, que si es unico.
#
# Cualquier otro error corta de una.
start_agent() {
    local label="$1" pane="$2" sid="$3"
    local name="$label" out attempt=0 warned=false renamed=false

    while [ "$attempt" -lt "$START_TRIES" ]; do
        if out="$("$HERDR" agent start "$name" --kind claude --pane "$pane" \
                           -- --resume "$sid" 2>&1)"; then
            return 0
        fi
        case "$out" in
            *agent_pane_busy*)
                if [ "$warned" = false ]; then
                    echo "⏳ esperando a que arranque la shell del pane..." >&2
                    warned=true
                fi
                sleep "$START_WAIT"
                attempt=$((attempt + 1))
                ;;
            *agent_name_taken*)
                if [ "$renamed" = true ]; then
                    echo "❌ herdr agent start fallo: $out" >&2
                    return 1
                fi
                name="$label-${sid:0:8}"
                renamed=true
                ;;
            *)
                echo "❌ herdr agent start fallo: $out" >&2
                return 1
                ;;
        esac
    done

    echo "❌ el pane $pane nunca quedo disponible" >&2
    return 1
}

# ---------------------------------------------------------------------------
# Modo open: solo abre el popup
# ---------------------------------------------------------------------------
if [ "${1:-}" = "open" ]; then
    exec "$HERDR" plugin pane open --plugin "$PLUGIN_ID" --entrypoint picker
fi

# ---------------------------------------------------------------------------
# Modo pick
# ---------------------------------------------------------------------------

# No asumir que ~/.local/bin esta en el PATH: herdr hereda el entorno del shell
# que lo lanzo, que no siempre es un login shell.
if command -v claude-sessions >/dev/null 2>&1; then
    CCS="$(command -v claude-sessions)"
elif [ -x "$HOME/.local/bin/claude-sessions" ]; then
    CCS="$HOME/.local/bin/claude-sessions"
else
    echo "❌ no encuentro claude-sessions (¿stow del paquete scripts?)" >&2
    read -r -p "Enter para cerrar..." _
    exit 1
fi

# --print devuelve "<sessionId>TAB<cwd>" en vez de reanudar en este pane.
selected="$("$CCS" --print "${2:-}")" || exit 0
[ -n "$selected" ] || exit 0

sid="$(printf '%s' "$selected" | cut -f1)"
cwd="$(printf '%s' "$selected" | cut -f2)"
label="$(basename "${cwd%/}")"

# Busca un pane que ya tenga abierta ESTA sesion, o alguno parado en el mismo
# proyecto. Devuelve "<motivo> <id>": la sesion misma gana, porque reanudarla
# dos veces en paralelo deja dos claude peleando por el mismo transcript.
found="$(
    "$HERDR" pane list 2>/dev/null | python3 -c '
import json, sys

sid, cwd = sys.argv[1], sys.argv[2].rstrip("/")
try:
    panes = json.load(sys.stdin)["result"]["panes"]
except Exception:
    sys.exit(0)

same_project = None
for p in panes:
    session = (p.get("agent_session") or {}).get("value")
    if session == sid:
        print("session", p["pane_id"])
        sys.exit(0)
    if same_project is None and (p.get("cwd") or "").rstrip("/") == cwd:
        same_project = p.get("workspace_id")

if same_project:
    print("project", same_project)
' "$sid" "$cwd" || true
)"

reason="${found%% *}"
target="${found#* }"

# 1) La sesion ya esta abierta: enfocarla y listo.
if [ "$reason" = "session" ]; then
    "$HERDR" agent focus "$target" >/dev/null
    exit 0
fi

# 2) El proyecto ya esta abierto: pestaña nueva ahi, en vez de un workspace
#    duplicado con la misma etiqueta.
# 3) No esta abierto: workspace nuevo.
if [ "$reason" = "project" ]; then
    created="$("$HERDR" tab create --workspace "$target" --cwd "$cwd" --focus)"
    created_kind="tab"
else
    created="$("$HERDR" workspace create --cwd "$cwd" --label "$label" --focus)"
    created_kind="workspace"
fi

# Las dos respuestas traen el mismo root_pane, con los tres ids que hacen falta.
read -r pane_id tab_id workspace_id <<EOF
$(printf '%s' "$created" | python3 -c '
import json, sys
p = json.load(sys.stdin)["result"]["root_pane"]
print(p["pane_id"], p["tab_id"], p["workspace_id"])
')
EOF

# `agent start` acepta argumentos para el agente despues de `--`, asi que la
# sesion se reanuda directo. El pane queda registrado como agente claude, con
# lo cual el estado working/done de la barra lateral funciona solo.
if ! start_agent "$label" "$pane_id" "$sid"; then
    # Si no arranco, no dejar el pane vacio que se acaba de abrir.
    if [ "$created_kind" = "tab" ]; then
        "$HERDR" tab close "$tab_id" >/dev/null 2>&1 || true
    else
        "$HERDR" workspace close "$workspace_id" >/dev/null 2>&1 || true
    fi
    read -r -p "Enter para cerrar..." _
    exit 1
fi
