# alias-manager

Herramienta para gestionar aliases en tus dotfiles de forma sencilla.

## Instalación

El script ya está incluido en tu dotfiles. Solo necesitas:

```bash
cd ~/.dotfiles  # o ~/github/dotfiles
./install.sh -d scripts
```

O si ya tienes stow configurado:
```bash
stow scripts
```

## Uso

### Comandos principales

```bash
# Ver ayuda
alias-manager help

# Agregar un nuevo alias
alias-manager add <nombre> <comando>
alias-manager add gst 'git status'
alias-manager add ll 'ls -la --color=auto'

# Eliminar un alias
alias-manager remove <nombre>
alias-manager remove gst

# Listar todos los aliases
alias-manager list              # Todos
alias-manager list general      # Solo generales
alias-manager list k8s          # Solo Kubernetes
alias-manager list docker       # Solo Docker

# Buscar aliases
alias-manager search git        # Busca "git" en nombre o comando
alias-manager search docker

# Editar archivos de aliases
alias-manager edit              # Edita aliases generales
alias-manager edit k8s          # Edita aliases de Kubernetes
alias-manager edit docker       # Edita aliases de Docker

# Recargar configuración
alias-manager reload
```

### Aliases cortos

Para mayor comodidad, se incluyen estos aliases:

```bash
alm                 # alias-manager
alias-add           # alias-manager add
alias-rm            # alias-manager remove
alias-list          # alias-manager list
alias-search        # alias-manager search
```

### Ejemplos

```bash
# Agregar un alias personalizado para git
alm add gp 'git push'
alm add gc 'git commit -m'

# Ver todos tus aliases
alm list

# Buscar aliases relacionados con docker
alm search docker

# Editar aliases manualmente
alm edit

# Recargar después de editar
alm reload
```

## Archivos de aliases

El gestor trabaja con estos archivos:

- **General**: `zsh/.aliases_general` - Aliases generales y de sistema
- **Kubernetes**: `kubectl/.aliases_k8s` - Aliases de kubectl y k9s
- **Docker**: `docker/.docker_aliases` - Aliases de Docker

## Características

- ✅ Agregar aliases de forma interactiva
- ✅ Validación de aliases duplicados
- ✅ Búsqueda en todos los archivos de aliases
- ✅ Edición directa con tu editor preferido
- ✅ Colores para mejor legibilidad
- ✅ Recarga automática de configuración
- ✅ Soporte para múltiples tipos de aliases (general, k8s, docker)

## Nota

Después de agregar o eliminar aliases, recuerda recargar tu shell:

```bash
alias-manager reload
# o
source ~/.zshrc
```
