---
name: nuevo-paquete
description: "Checklist completo para agregar un paquete de Stow nuevo a estos dotfiles (o una herramienta CLI nueva). Usala cuando se agregue una herramienta al repo — yazi, sketchybar, ghostty y similares — porque el alta toca 7+ archivos repartidos y las guias del README y AGENTS.md solo cubren la mitad. Tambien aplica al agregar un script a scripts/.local/bin."
user-invocable: true
disable-model-invocation: false
---

# Agregar un paquete nuevo

Dar de alta una herramienta acá no es solo crear el directorio y stowearlo.
Toca **install.sh (dos ramas de SO), el doctor, el README (3 lugares) y el
CHANGELOG**. El README y `AGENTS.md` documentan una versión corta de 6 pasos que
se queda a mitad de camino: seguí esta.

Nada de esto lo detecta el CI. El único desfasaje que `dotfiles-doctor` atrapa es
el del árbol del README; el resto se olvida en silencio.

## Checklist

| # | Archivo | Qué va |
|---|---|---|
| 1 | `<pkg>/...` | El paquete, con el layout que replica su destino bajo `~` |
| 2 | `Brewfile` | La fórmula (y casks) para **macOS** — más las deps opcionales |
| 3 | `install.sh` → `SYSTEM_PACKAGES` | El equivalente para **Arch/pacman** |
| 4 | `install.sh` → `DOTFILE_PACKAGES` | El nombre del paquete, si tiene config que stowear |
| 5 | `scripts/.local/bin/dotfiles-doctor` → `OPTIONAL_TOOLS` | El binario, para que el doctor lo chequee |
| 6 | `README.md` | Árbol + lista de CLI por SO + sección de la feature + uso diario |
| 7 | `CHANGELOG.md` | Entrada en el mes en curso |
| 8 | `<pkg>/README.md` | Solo si la config es densa (ver `yazi/README.md`) |

## Paso a paso

### 1. El paquete

La ruta dentro del paquete **es** la ruta destino bajo `~`:

```bash
mkdir -p nueva-app/.config/nueva-app
cp ~/.config/nueva-app/config nueva-app/.config/nueva-app/
stow -n -v -d . -t "$HOME" nueva-app   # dry-run: revisar conflictos ANTES
```

Si el dry-run muestra `UNLINK` + `LINK ... (reverts previous action)`, ya está
enlazado y no hay nada que hacer. Si muestra conflictos con archivos reales,
`install.sh` los respalda en `~/.dotfiles-backup/TIMESTAMP/`, pero un `stow`
manual no: movelos vos primero.

### 2 y 3. Instalación en los dos SO

Son **dos listas separadas y los nombres no siempre coinciden** (`sevenzip` en
Homebrew es `7zip` en pacman). Hay que tocar las dos:

- **macOS** → `Brewfile` en la raíz. Es la única fuente de verdad; `install.sh`
  corre `brew bundle`. **No existe** ningún array `BREW_PACKAGES` en `install.sh`
  — si algún doc o agente dice lo contrario, está desactualizado.
- **Arch** → array `SYSTEM_PACKAGES` en `install.sh` (~línea 12).

Declará también las **deps opcionales**. Son las que hacen que la herramienta
funcione a medias sin avisar: yazi sin `poppler` no falla, simplemente muestra
el preview de PDF en blanco.

### 4. DOTFILE_PACKAGES

Si el paquete tiene config que stowear, agregalo al array `DOTFILE_PACKAGES` de
`install.sh` (~línea 69) o no entra en las instalaciones completas. Un paquete
que es solo un binario (sin config) no va acá.

### 5. El doctor

Agregá el **nombre del binario** a `OPTIONAL_TOOLS` en
`scripts/.local/bin/dotfiles-doctor`. `CRITICAL_TOOLS` es solo para lo que rompe
el entorno si falta (stow, git, zsh, nvim…): un FAIL ahí frena el exit code.

### 6. README

Cuatro lugares, y el primero es obligatorio:

1. **El árbol de estructura** — `dotfiles-doctor` parsea el **primer bloque de
   código** del README y compara las líneas `├── pkg/` contra `DOTFILE_PACKAGES`.
   Si falta, la categoría Docs tira WARN.
2. **La lista de CLI del SO** (secciones `🍎 macOS` y `🐧 Arch Linux`) — las dos.
3. **Una sección propia** en "Características principales", si la herramienta
   tiene UX que recordar (atajos, teclas, comandos).
4. **"Uso diario"**, si agrega un comando que vas a tipear seguido.

### 7. CHANGELOG

Entrada en el mes en curso de `CHANGELOG.md`, bajo `### ✨ Agregado`. Es a nivel
de feature, no de commit — el *por qué* va en el mensaje del commit, no acá. Si
el mes todavía no existe, creá el bloque arriba de todo.

## Casos adicionales

**Si agrega un script a `scripts/.local/bin/`:**
- `chmod +x` (verificalo con `ls -l`, no con `test -x`: `test` puede estar
  pisado por un alias de npm en zsh)
- Fila en la tabla de scripts del README raíz
- Sección propia en `scripts/README.md`
- `stow -R -d . -t "$HOME" scripts` para que aparezca el symlink en `~/.local/bin/`

**Si agrega un alias o función a `zsh/.aliases_general`:**
- Chequeá que la letra esté libre antes de elegirla: `y` ya es yarn, definido en
  `nodejs/.nodejs_config`, y por eso yazi quedó como `yz`. Ojo que `.zshrc`
  sourcea varios archivos de aliases (`zsh/.aliases_general`,
  `docker/.docker_aliases`, `kubectl/.aliases_k8s`, `python/.python_config`,
  `nodejs/.nodejs_config`): la colisión puede estar en cualquiera. `als` los
  busca a todos.
- Los archivos de aliases se sourcean por ruta absoluta desde `~/.dotfiles/`, así
  que **no hace falta re-stowear** — pero sí abrir una shell nueva.
- Si la función depende de un binario, guardala:
  `command -v tool >/dev/null 2>&1 || { echo "❌ tool no está instalado"; return 1; }`

## Validar antes de commitear

```bash
bash -n install.sh                      # y cualquier script tocado
zsh -n zsh/.aliases_general             # los archivos de aliases son zsh, no bash
shellcheck scripts/.local/bin/<script>  # si está instalado
stow -n -v -d . -t "$HOME" <pkg>        # dry-run
dotfiles-doctor                         # debe cerrar en Overall ✅ OK, exit 0
```

Para cambios de shell, probá en una terminal nueva antes de commitear: un
`.zshrc` malformado puede romper el login.

Si tocaste un script, pasale el diff al subagente **`shell-style-reviewer`**
antes del commit — chequea las convenciones de `AGENTS.md` y bugs reales.

## Commit

Rama por defecto `dev`, mensaje en **imperativo y en español**, con cuerpo que
explique el *por qué* y las trampas encontradas — no el qué, que ya está en el
diff. Ver `AGENTS.md` y los commits recientes como referencia.
