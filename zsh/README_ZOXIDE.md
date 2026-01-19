# Zoxide - Navegación Inteligente

Zoxide es un reemplazo más inteligente de `cd` que aprende de tus patrones de navegación.

## ¿Cómo funciona?

Zoxide trackea los directorios que visitas y les asigna un "score" basado en:
- **Frecuencia**: Cuántas veces visitas el directorio
- **Recencia**: Qué tan recientemente lo visitaste

Cuando usas `cd` con un fragmento del path, zoxide encuentra el directorio con mayor score que coincida.

## Configuración

Zoxide está configurado para sobrescribir el comando `cd`:

```bash
# En .zshrc
eval "$(zoxide init zsh --cmd cd)"
```

## Uso

### Navegación básica

```bash
# Primera vez, usa el path completo
cd ~/github/dotfiles
cd ~/.config/nvim
cd ~/projects/mi-proyecto

# Después, solo usa fragmentos
cd dot          # Salta a ~/github/dotfiles
cd nvim         # Salta a ~/.config/nvim
cd proy mi      # Salta a ~/projects/mi-proyecto

# Múltiples palabras para mayor precisión
cd github dot   # Busca directorios que contengan "github" y "dot"

# Navegación tradicional sigue funcionando
cd ..           # Directorio padre
cd -            # Directorio anterior
cd /usr/local   # Path absoluto
cd ./relative   # Path relativo
```

### Modo interactivo

Si tienes `fzf` instalado:

```bash
cdi             # Selecciona directorio interactivamente
```

### Gestión de base de datos

```bash
# Ver a dónde saltaría sin cambiar directorio
zoxide query dot
zoxide query nvim

# Listar todos los directorios trackeados
zoxide query -l
zoxide query --list

# Listar con scores (frecuencia)
zoxide query -l -s
zoxide query --list --score

# Remover directorio del historial
zoxide remove ~/old/project
zoxide remove /tmp/test

# Ver estadísticas
zoxide query -l -s | head -20  # Top 20 directorios
```

## Aliases incluidos

```bash
cdi             # cd interactivo
zq              # zoxide query
zql             # zoxide query -l (listar)
zqs             # zoxide query -l -s (listar con scores)
zr              # zoxide remove
```

## Variables de entorno (opcional)

Puedes personalizar zoxide agregando estas variables en tu `.zshrc`:

```bash
# Mostrar directorio al cambiar
export _ZO_ECHO=1

# Excluir ciertos directorios
export _ZO_EXCLUDE_DIRS="/tmp:/mnt:/media"

# Opciones de fzf para modo interactivo
export _ZO_FZF_OPTS="--height 40% --layout=reverse --border"

# Resolver symlinks automáticamente
export _ZO_RESOLVE_SYMLINKS=1

# Directorio de datos personalizado
export _ZO_DATA_DIR="$HOME/.local/share/zoxide"
```

## Ejemplos prácticos

```bash
# Flujo de trabajo típico
cd ~/github/dotfiles
cd ~/.config/nvim
cd ~/projects/web/frontend
cd ~/projects/backend/api

# Después de un rato...
cd dot          # -> ~/github/dotfiles
cd nvim         # -> ~/.config/nvim
cd front        # -> ~/projects/web/frontend
cd api          # -> ~/projects/backend/api
cd back         # -> ~/projects/backend/api

# Si tienes múltiples coincidencias
cd proj         # Zoxide elige la más frecuente/reciente
cd proj web     # Más específico -> frontend
cd proj back    # Más específico -> backend
```

## Tips

1. **Visita directorios primero**: Zoxide solo salta a directorios que has visitado antes
2. **Sé específico**: Si hay múltiples coincidencias, agrega más palabras clave
3. **Usa el tab**: El autocompletado funciona normalmente con paths completos
4. **Limpia la base de datos**: Usa `zoxide remove` para directorios que ya no existen
5. **Ve los scores**: `zoxide query -l -s` te muestra qué directorios visitas más

## Ubicación de datos

La base de datos de zoxide se guarda en:
- **Linux/macOS**: `~/.local/share/zoxide/data.db`
- Puedes cambiarla con `_ZO_DATA_DIR`

## Comandos útiles

```bash
# Ver top 20 directorios más visitados
zoxide query -l -s | head -20

# Buscar directorios con cierto patrón
zoxide query -l | grep github

# Limpiar directorios que ya no existen
# (zoxide limpia automáticamente, pero puedes hacerlo manual)
zoxide query -l | while read dir; do
    [ ! -d "$dir" ] && zoxide remove "$dir"
done
```

## Desinstalar/Deshabilitar

Para deshabilitar temporalmente:
```bash
# Comenta en .zshrc
# eval "$(zoxide init zsh --cmd cd)"
```

Para usar comandos originales cuando zoxide esté activo:
```bash
command cd /path/to/dir  # Usa cd original sin zoxide
```

## Más información

- GitHub: https://github.com/ajeetdsouza/zoxide
- Documentación: `man zoxide`
- Ayuda: `zoxide --help`
