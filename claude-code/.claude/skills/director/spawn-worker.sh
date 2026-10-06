#!/usr/bin/env bash
# spawn-worker.sh - Lanza un agente worker de herdr para la skill director.
#
# Crea el lugar (split, workspace o worktree), arranca el agente con reintento
# y, si no arranca, cierra lo que creo. Imprime una linea JSON con
# name, pane_id, workspace_id y where.
#
# Uso:
#   spawn-worker.sh <name> --results <dir> [--where split|workspace|worktree]
#                   [--kind claude] [--model haiku] [--cwd DIR]
#                   [--branch NAME] [--direction right|down] [--split-from PANE]
#                   [--add-dir DIR]...   (carpetas extra que el worker puede tocar)

set -euo pipefail

usage() {
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
}

# Mensajes a stderr: stdout queda solo para el JSON del resultado
die() {
    echo "❌ $*" >&2
    exit 1
}

name="${1:-}"
[[ -z "$name" || "$name" == -* ]] && { usage >&2; exit 1; }
shift

where="split"
kind="claude"
model=""
cwd="$PWD"
branch=""
direction="right"
split_from="${HERDR_PANE_ID:-}"
results=""
extra_dirs=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --where)      where="$2"; shift 2 ;;
        --kind)       kind="$2"; shift 2 ;;
        --model)      model="$2"; shift 2 ;;
        --cwd)        cwd="$2"; shift 2 ;;
        --branch)     branch="$2"; shift 2 ;;
        --direction)  direction="$2"; shift 2 ;;
        --split-from) split_from="$2"; shift 2 ;;
        --results)    results="$2"; shift 2 ;;
        --add-dir)    extra_dirs+=("$2"); shift 2 ;;
        -h|--help)    usage; exit 0 ;;
        *)            die "opción desconocida: $1" ;;
    esac
done

[[ "${HERDR_ENV:-}" == "1" ]] || die "no estoy corriendo dentro de herdr (HERDR_ENV != 1)"
[[ -n "$results" ]] || die "falta --results <dir>: el worker escribe ahí su resultado"
[[ "$name" =~ ^[a-z][a-z0-9_-]{0,31}$ ]] || die "nombre inválido para herdr: $name"
command -v jq >/dev/null 2>&1 || die "falta jq"
mkdir -p "$results"
for dir in ${extra_dirs[@]+"${extra_dirs[@]}"}; do
    [[ -d "$dir" ]] || die "--add-dir no existe: $dir"
done

# 1. Crear el lugar donde vive el worker
case "$where" in
    split)
        [[ -n "$split_from" ]] || die "no hay pane de origen para el split"
        created=$(herdr pane split --pane "$split_from" --direction "$direction" --cwd "$cwd" --no-focus)
        pane_id=$(jq -r '.result.pane.pane_id' <<<"$created")
        workspace_id=$(jq -r '.result.pane.workspace_id' <<<"$created")
        ;;
    workspace)
        created=$(herdr workspace create --cwd "$cwd" --label "$name" --no-focus)
        pane_id=$(jq -r '.result.root_pane.pane_id' <<<"$created")
        workspace_id=$(jq -r '.result.workspace.workspace_id' <<<"$created")
        ;;
    worktree)
        [[ -n "$branch" ]] || die "--where worktree necesita --branch"
        created=$(herdr worktree create --cwd "$cwd" --branch "$branch" --label "$name" --no-focus)
        pane_id=$(jq -r '.result.root_pane.pane_id' <<<"$created")
        workspace_id=$(jq -r '.result.workspace.workspace_id' <<<"$created")
        ;;
    *)
        die "--where tiene que ser split, workspace o worktree"
        ;;
esac

[[ -n "$pane_id" && "$pane_id" != "null" ]] || die "herdr no devolvió pane: $created"

# Si el agente no arranca, no dejar el lugar vacío. Un worktree se deja: tiene
# una rama creada y borrarla es decisión de Kevin.
cleanup_place() {
    case "$where" in
        split)     herdr pane close "$pane_id" >/dev/null 2>&1 || true ;;
        workspace) herdr workspace close "$workspace_id" >/dev/null 2>&1 || true ;;
        worktree)  echo "⚠️ quedó el worktree $workspace_id sin agente" >&2 ;;
    esac
}

# 2. Argumentos del agente. Para claude: acceptEdits + --add-dir al dir de
# resultados, para que escribir el resultado no lo deje en blocked, y a cada
# carpeta extra que el worker necesite además de su cwd.
agent_args=()
if [[ "$kind" == "claude" ]]; then
    agent_args+=(--permission-mode acceptEdits --add-dir "$results")
    for dir in ${extra_dirs[@]+"${extra_dirs[@]}"}; do
        agent_args+=(--add-dir "$dir")
    done
    [[ -n "$model" ]] && agent_args+=(--model "$model")
fi

# 3. Arrancar con reintento: el pane recién creado rebota con agent_pane_busy
# mientras zsh carga starship/atuin/nvm (~3s en esta Mac)
last_error=""
for _ in $(seq 1 10); do
    if last_error=$(herdr agent start "$name" --kind "$kind" --pane "$pane_id" -- ${agent_args[@]+"${agent_args[@]}"} 2>&1); then
        jq -cn --arg name "$name" --arg pane "$pane_id" --arg ws "$workspace_id" --arg where "$where" \
            '{name: $name, pane_id: $pane, workspace_id: $ws, where: $where}'
        exit 0
    fi
    grep -q "agent_name_taken" <<<"$last_error" && { cleanup_place; die "el nombre $name ya está en uso"; }
    sleep 2
done

cleanup_place
die "el agente no arrancó: $last_error"
