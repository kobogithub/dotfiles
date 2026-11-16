#!/usr/bin/env bash
# spawn-worker.sh - Lanza un agente worker en Herdr.app para la skill director.
#
# Crea el lugar (split, workspace o worktree), arranca el agente con hc como
# hijo del director y con su tarea, y si no arranca cierra lo que creo.
# Imprime una linea JSON con name, terminal, space, tab, cwd y where.
#
# Uso:
#   spawn-worker.sh <name> --results <dir> --task "<tarea>"
#                   [--where split|workspace|worktree] [--kind claude]
#                   [--model haiku] [--cwd DIR] [--branch NAME] [--base REF]
#                   [--add-dir DIR]...   (carpetas extra que el worker puede tocar)
#
# Los worktrees van en ~/.worktrees/<repo>/<rama>.

set -euo pipefail

usage() {
    sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
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
base=""
task=""
results=""
extra_dirs=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --where)      where="$2"; shift 2 ;;
        --kind)       kind="$2"; shift 2 ;;
        --model)      model="$2"; shift 2 ;;
        --cwd)        cwd="$2"; shift 2 ;;
        --branch)     branch="$2"; shift 2 ;;
        --base)       base="$2"; shift 2 ;;
        --task)       task="$2"; shift 2 ;;
        --results)    results="$2"; shift 2 ;;
        --add-dir)    extra_dirs+=("$2"); shift 2 ;;
        -h|--help)    usage; exit 0 ;;
        *)            die "opción desconocida: $1" ;;
    esac
done

[[ -n "${HC_TERMINAL_ID:-}" ]] || die "no estoy corriendo dentro de Herdr.app (falta HC_TERMINAL_ID)"
command -v hc >/dev/null 2>&1 || die "falta hc"
command -v herdr-app >/dev/null 2>&1 || die "falta herdr-app"
command -v jq >/dev/null 2>&1 || die "falta jq"
[[ -n "$results" ]] || die "falta --results <dir>: el worker escribe ahí su resultado"
[[ -n "$task" ]] || die "falta --task: la tarea va en el arranque, un send a un agente que bootea se puede perder"
[[ "$name" =~ ^[a-z][a-z0-9_-]{0,31}$ ]] || die "nombre inválido para hc: $name"
[[ -d "$cwd" ]] || die "--cwd no existe: $cwd"
mkdir -p "$results"
for dir in ${extra_dirs[@]+"${extra_dirs[@]}"}; do
    [[ -d "$dir" ]] || die "--add-dir no existe: $dir"
done

# Abre un space nuevo para el worker. space.new siempre arranca con una shell:
# se guarda su terminal para matarla cuando el worker ya este en el tab.
new_space() {
    local created
    created=$(herdr-app "do" space.new --name "$name" --folder "$1" --tab "$name") \
        || die "herdr-app no creó el space: $created"
    space=$(jq -r '.space' <<<"$created")
    tab=$(jq -r '.tab' <<<"$created")
    seed=$(jq -r '.terminal' <<<"$created")
}

# 1. Crear el lugar donde vive el worker
space=""
tab=""
seed=""
case "$where" in
    split)
        # Mismo tab que el director: hc lo muestra como un pane al lado
        read -r space tab < <(herdr-app ls | jq -r --arg t "$HC_TERMINAL_ID" '
            .spaces[] | .id as $s | .tabs[]
            | select(any(.terminals[]; .terminal == $t)) | "\($s) \(.id)"')
        [[ -n "$tab" ]] || die "no encontré el tab del director ($HC_TERMINAL_ID) en herdr-app ls"
        ;;
    workspace)
        new_space "$cwd"
        ;;
    worktree)
        [[ -n "$branch" ]] || die "--where worktree necesita --branch"
        repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || die "--cwd no es un repo git: $cwd"
        cwd="$HOME/.worktrees/$(basename "$repo_root")/$branch"
        [[ -e "$cwd" ]] && die "ya existe el worktree: $cwd"
        mkdir -p "$(dirname "$cwd")"
        if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
            git -C "$repo_root" worktree add "$cwd" "$branch" >&2
        else
            git -C "$repo_root" worktree add -b "$branch" "$cwd" ${base:+"$base"} >&2
        fi
        new_space "$cwd"
        ;;
    *)
        die "--where tiene que ser split, workspace o worktree"
        ;;
esac

# Si el agente no arranca, no dejar el lugar vacío. Un worktree se deja: tiene
# una rama creada y borrarla es decisión de Kevin.
cleanup_place() {
    [[ -n "$seed" ]] || return 0
    herdr-app "do" space.close --id "$space" --confirmed true >/dev/null 2>&1 || true
    [[ "$where" == "worktree" ]] && echo "⚠️ quedó el worktree $cwd sin agente" >&2
    return 0
}

# 2. Argumentos del agente. Para claude: acceptEdits + --add-dir al dir de
# resultados, para que escribir el resultado no lo deje en blocked, a cada
# carpeta extra que el worker necesite además de su cwd, y `hc send` permitido
# para que el aviso al director tampoco pida aprobación.
agent_args=()
if [[ "$kind" == "claude" ]]; then
    agent_args+=(--permission-mode acceptEdits --add-dir "$results" --allowedTools "Bash(hc send:*)")
    for dir in ${extra_dirs[@]+"${extra_dirs[@]}"}; do
        agent_args+=(--add-dir "$dir")
    done
    [[ -n "$model" ]] && agent_args+=(--model "$model")
    # --add-dir y --allowedTools aceptan varios valores: sin `--` se tragan la
    # tarea como un valor más y el worker arranca vacío (idle, turn 0).
    agent_args+=(--)
fi

# 3. Arrancar. --outlive-parent: el worker sobrevive a la sesión del director.
# Las etiquetas herdr.* lo muestran en el space/tab que se eligió arriba.
if ! started=$(hc run --bg --json --name "$name" --cwd "$cwd" --outlive-parent \
        --label "herdr.space=$space" --label "herdr.tab=$tab" \
        -- "$kind" ${agent_args[@]+"${agent_args[@]}"} "$task" 2>&1); then
    cleanup_place
    grep -q -i "name" <<<"$started" && die "el nombre $name ya está en uso: $started"
    die "el agente no arrancó: $started"
fi

terminal=$(jq -r '.address' <<<"$started")

# La shell con la que nace el space ya no hace falta. Al matarla, la app
# rearma el space con IDs nuevos y el nombre de la carpeta: se releen y se
# le devuelve el nombre del worker.
if [[ -n "$seed" ]]; then
    hc kill "$seed" >/dev/null 2>&1 || true
    hc rm "$seed" >/dev/null 2>&1 || true
    sleep 1
    read -r space tab < <(herdr-app ls | jq -r --arg t "$terminal" '
        .spaces[] | .id as $s | .tabs[]
        | select(any(.terminals[]; .terminal == $t)) | "\($s) \(.id)"')
    herdr-app "do" space.rename --id "$space" --name "$name" >/dev/null 2>&1 || true
    herdr-app "do" tab.rename --id "$tab" --name "$name" >/dev/null 2>&1 || true
fi

jq -cn --arg name "$name" --arg term "$terminal" \
    --arg space "$space" --arg tab "$tab" --arg cwd "$cwd" --arg where "$where" \
    '{name: $name, terminal: $term, space: $space, tab: $tab, cwd: $cwd, where: $where}'
