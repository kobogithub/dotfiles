# 🏠 Dotfiles de Kevin Barroso

Repositorio centralizado para configuraciones personales optimizado para **Arch Linux** usando GNU Stow. Incluye instalación automática de herramientas esenciales y sus configuraciones.

## 📁 Estructura

```
dotfiles/
├── git/                    # Configuración de Git (~/.gitconfig)
├── bash/                   # Configuración de Bash (~/.bashrc)
├── zsh/                    # Configuración de Zsh (~/.zshrc) 
├── vim/                    # Configuración de Vim (~/.vimrc, ~/.vim/)
├── nvim/                   # Configuración de Neovim (~/.config/nvim/)
├── tmux/                   # Configuración de tmux (~/.tmux.conf)
├── starship/               # Configuración de Starship (~/.config/starship.toml)
├── atuin/                  # Configuración de Atuin (~/.config/atuin/)
├── ssh/                    # Configuración de SSH (~/.ssh/config)
├── kubectl/                # Configuración de kubectl (~/.kube/)
├── k9s/                    # Configuración de k9s (~/.config/k9s/)
├── scripts/                # Scripts útiles (~/.local/bin/)
├── docker/                 # Configuración de Docker y aliases
├── python/                 # Entorno Python + pyenv + virtual envs
├── nodejs/                 # Entorno Node.js + nvm + npm/yarn
├── vscode/                 # Configuración de VS Code + extensiones
├── opencode/               # OpenCode agents & skills (~/.config/opencode/)
├── ghostty/                # Configuración de Ghostty (~/.config/ghostty/)
├── herdr/                  # Configuración de herdr (~/.config/herdr/)
├── claude-code/            # Config global de Claude Code (~/.claude/settings.json)
├── system/                 # Configuraciones del sistema
├── install.sh              # Script de instalación completa
└── README.md               # Este archivo
```

## 🚀 Instalación rápida

```bash
# Clonar el repositorio
git clone https://github.com/kobogithub/dotfiles.git ~/.dotfiles

# Instalación completa (recomendado)
cd ~/.dotfiles
./install.sh

# Reiniciar terminal para aplicar cambios
```

## 📦 Herramientas instaladas automáticamente

El script instala estos paquetes en **Arch Linux**:

### 🔧 Herramientas del sistema
- **openssh** - Cliente SSH para conexiones seguras
- **neovim** - Editor moderno basado en Vim
- **tmux** - Multiplexor de terminal  
- **github-cli** - CLI oficial de GitHub
- **zsh** - Shell avanzado (configurado como default)
- **lsd** - Reemplazo moderno de `ls`
- **starship** - Prompt personalizable
- **atuin** - Historial de comandos inteligente
- **stow** - Gestor de enlaces simbólicos
- **kubectl** - CLI oficial de Kubernetes
- **k9s** - Dashboard terminal para Kubernetes

### 🛠️ Herramientas de desarrollo
- **docker** + **docker-compose** - Containerización
- **python** + **python-pip** + **python-virtualenv** - Python development
- **nodejs** + **npm** + **yarn** - JavaScript/TypeScript development
- **code** - Visual Studio Code
- **base-devel** - Herramientas de compilación
- **git**, **curl**, **wget**, **jq** - Utilidades
- **tree**, **htop**, **unzip**, **zip** - Herramientas del sistema

### 🚀 Gestores de versiones (instalados automáticamente)
- **nvm** - Node Version Manager
- **pyenv** - Python Version Manager

## 🔧 Opciones del script de instalación

```bash
# Instalación completa (sistema + dotfiles)
./install.sh                    # o ./install.sh -a

# Solo paquetes del sistema
./install.sh -s

# Solo dotfiles específicos
./install.sh -d git zsh nvim tmux

# Solo dotfiles (sin paquetes del sistema)
./install.sh -d

# Desinstalar dotfiles
./install.sh -u git zsh

# Ver ayuda
./install.sh -h
```

## 🛠️ Funciones de desarrollo

### 🐳 Docker
- **Aliases completos** - `d`, `dc`, `dcu`, `dcd`, `dlogs`, etc.
- **Funciones útiles** - `drun`, `denter`, `dcleanup`, `dusage`
- **Docker Compose shortcuts** - para dev, prod, test
- **Auto-configuración** - Usuario agregado al grupo docker
- **Dockerfiles** - Plantillas para Node.js y Python

### 🐍 Python
- **pyenv integration** - Manejo de versiones Python
- **Virtual environments** - Creación y manejo automático
- **Development tools** - black, flake8, mypy, pytest
- **Aliases útiles** - `py`, `pip`, `venv`, `venvact`, etc.
- **Functions** - `pymkenv`, `pyquick`, `pyformat`, `pylint`
- **Poetry support** - Si usas Poetry para dependencias
- **Django/Flask shortcuts** - Comandos rápidos

### 🟢 Node.js
- **nvm integration** - Manejo de versiones Node.js
- **Multiple package managers** - npm, yarn, pnpm
- **Auto-detection** - Detecta qué package manager usar
- **Project templates** - React, Next.js, Express, Vue
- **Development tools** - ESLint, Prettier, Jest
- **Unified commands** - `install`, `start`, `build` automáticos

### 💻 VS Code
- **Settings optimizados** - Para desarrollo full-stack
- **Extensions installer** - Script automático
- **Configuración completa** - Keybindings, themes, linting
- **Language support** - Python, JS/TS, Docker, K8s
- **Project templates** - .vscode settings incluidos

# Ver ayuda
./install.sh -h
```

## ✨ Características principales

### 🐚 Shell (Zsh)
- **Starship prompt** - Prompt hermoso y funcional
- **Atuin** - Historial inteligente y búsqueda fuzzy
- **lsd** - Listado de archivos con colores e iconos
- **Aliases útiles** - Para git, pacman y navegación
- **Configurado automáticamente** como shell por defecto

### ⚡ Editor (Neovim)
- Configuración Lua moderna
- Keybindings intuitivos
- Navegación entre ventanas con Ctrl+hjkl
- Leader key configurado como espacio

### 🖥️ Terminal (tmux)
- Prefix cambiado a `Ctrl-a`
- Navegación con vim keys (hjkl)
- División intuitiva de ventanas (`|` y `-`)
- Mouse habilitado
- **Tema Catppuccin Frappe** con personalización
- Barra de estado posicionada arriba
- Color de fondo personalizado (#303446)
- Barra de estado personalizada con información esencial
- Módulos de estado: directorio, sesión, host, fecha/hora

### 🚀 Prompt (Starship)
- Información de Git visible
- Duración de comandos
- Indicador de Python/Node.js
- Diseño minimalista pero informativo

### 🔍 Historial (Atuin)
- Búsqueda fuzzy en historial
- Filtros inteligentes
- Estadísticas de uso
- Configuración optimizada

### 🔒 SSH
- Configuración optimizada para conexiones seguras
- Control de conexiones persistentes (ControlMaster)
- Compresión automática para conexiones lentas
- Configuración preconfigurada para GitHub
- Timeouts y keep-alive configurados

### ☸️ Kubernetes
- **kubectl** configurado con aliases útiles
- **k9s** dashboard terminal con configuración optimizada
- Autocompletado inteligente para kubectl
- Aliases comunes para operaciones frecuentes
- Configuración base para múltiples clusters

## 🛠️ Herramientas de desarrollo

### 🐳 Docker
- **Aliases completos** - `d`, `dc`, `dcu`, `dcd`, `dlogs`, etc.
- **Funciones útiles** - `drun`, `denter`, `dcleanup`, `dusage`
- **Docker Compose shortcuts** - para dev, prod, test
- **Auto-configuración** - Usuario agregado al grupo docker
- **Dockerfiles** - Plantillas para Node.js y Python

### 🐍 Python
- **pyenv integration** - Manejo de versiones Python
- **Virtual environments** - Creación y manejo automático
- **Development tools** - black, flake8, mypy, pytest
- **Aliases útiles** - `py`, `pip`, `venv`, `venvact`, etc.
- **Functions** - `pymkenv`, `pyquick`, `pyformat`, `pylint`
- **Poetry support** - Si usas Poetry para dependencias
- **Django/Flask shortcuts** - Comandos rápidos

### 🟢 Node.js
- **nvm integration** - Manejo de versiones Node.js
- **Multiple package managers** - npm, yarn, pnpm
- **Auto-detection** - Detecta qué package manager usar
- **Project templates** - React, Next.js, Express, Vue
- **Development tools** - ESLint, Prettier, Jest
- **Unified commands** - `install`, `start`, `build` automáticos

### 💻 VS Code
- **Settings optimizados** - Para desarrollo full-stack
- **Extensions installer** - Script automático
- **Configuración completa** - Keybindings, themes, linting
- **Language support** - Python, JS/TS, Docker, K8s
- **Project templates** - .vscode settings incluidos

### 📜 Scripts de desarrollo
- **`dev-status`** - Verificar estado del entorno
- **`dev-init`** - Crear proyectos (Python, Node, React, etc.)
- **`dev-clean`** - Limpiar artifacts (node_modules, cache, etc.)
- **`code-ext`** - Instalar extensiones VS Code

### 🤖 OpenCode AI Agents & Skills
- **7 Custom Agents** - Expertos en FastAPI, PostgreSQL, Supabase, Docker, Astro, Documentation, QA
- **6 Skills** - Guías completas de best practices, patterns, testing, y documentation
- **7,000+ líneas** - De expertise técnico en código y configuraciones
- **Project-ready** - Configuraciones reutilizables para tus proyectos
- **Invoke with @** - `@fastapi-dev`, `@postgres-admin`, `@docker-expert`, `@docs-writer`, `@qa-engineer`
- **[Ver documentación completa](opencode/README.md)**

## 📋 Uso diario

### Comandos esenciales
```bash
# Git (aliases incluidos)
gs          # git status
ga .        # git add .
gc "msg"    # git commit -m "msg"
gp          # git push

# Sistema (Arch Linux)
update      # sudo pacman -Syu
install pkg # sudo pacman -S pkg
search pkg  # pacman -Ss pkg
cleanup     # limpiar paquetes huérfanos

# Navegación
ll          # lsd -alF (listado detallado)
tree        # lsd --tree (vista de árbol)
..          # cd ..
...         # cd ../..

# Kubernetes (aliases incluidos)
k           # kubectl
kgp         # kubectl get pods
kgs         # kubectl get services
kgd         # kubectl get deployments
kl          # kubectl logs
klf         # kubectl logs -f
ke          # kubectl exec -it
k9s         # abrir dashboard de k9s

# Desarrollo
dev-status  # verificar entorno
dev-init python my-api     # crear proyecto Python
dev-init react my-app      # crear proyecto React  
dev-clean node            # limpiar artifacts Node.js
code-ext essential        # instalar extensiones VS Code

# Docker
d ps        # docker ps
dc up       # docker compose up
dc logs     # docker compose logs
dcleanup    # limpiar sistema Docker

# Python
py --version           # python version
pymkenv myproject      # crear virtual env
pyquick                # crear env con tools
pyformat .             # formatear código

# Node.js
nodeversions           # ver versiones disponibles
nodeinit express api   # crear proyecto Express
nodedev                # ejecutar en development
nodeclean              # limpiar node_modules
```

### Tmux workflow
```bash
# Crear sesión
tmux new -s trabajo

# Dividir ventanas
Ctrl-a |    # División vertical
Ctrl-a -    # División horizontal

# Navegación
Ctrl-a h/j/k/l    # Cambiar paneles
Ctrl-a c          # Nueva ventana

# Utilidades
Ctrl-a r          # Recargar configuración
Ctrl-a S          # Sincronizar paneles
Ctrl-a a          # Alternar último panel
```

### Neovim basics
```bash
# Abrir neovim
nvim archivo.txt

# Comandos básicos (modo normal)
Space w     # Guardar
Space q     # Cerrar
Space h     # Limpiar búsqueda
Ctrl-hjkl   # Navegar ventanas
```

## 🔄 Gestión de dotfiles

### Agregar nueva configuración

```bash
# Crear nuevo paquete
mkdir nueva-app
mkdir -p nueva-app/.config/nueva-app

# Copiar configuración
cp ~/.config/nueva-app/config nueva-app/.config/nueva-app/

# Instalar con stow
stow nueva-app

# Commit
git add nueva-app/
git commit -m "Add nueva-app configuration"
git push origin dev
```

### Actualizar configuraciones

```bash
cd ~/.dotfiles

# Actualizar desde repositorio
git pull origin dev

# Reinstalar si hay cambios
./install.sh -d
```

### Backup antes de cambios

```bash
# Usar script incluido
~/.local/bin/backup-files

# O backup manual
cp ~/.zshrc ~/.zshrc.backup
cp ~/.tmux.conf ~/.tmux.conf.backup
```

## 🖥️ Instalación en nueva máquina

### Setup completo
```bash
# En Arch Linux
git clone https://github.com/kobogithub/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
# Reiniciar terminal
```

### Setup mínimo (solo dotfiles)
```bash
# Si ya tienes las herramientas instaladas
git clone https://github.com/kobogithub/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh -d git zsh nvim tmux
```

## 🛠️ Personalización

### Modificar prompt (Starship)
```bash
nvim ~/.config/starship.toml
# Reiniciar terminal para aplicar
```

### Agregar aliases (Zsh)
```bash
nvim ~/.dotfiles/zsh/.zshrc
# Agregar alias, luego:
stow zsh
source ~/.zshrc
```

### Configurar tmux
```bash
nvim ~/.dotfiles/tmux/.tmux.conf
# Recargar: Ctrl-a r
```

## 🐧 Compatibilidad

- **Optimizado para**: Arch Linux
- **Compatible con**: Otras distribuciones Linux (requiere instalación manual de paquetes)
- **Shell principal**: Zsh
- **Editor principal**: Neovim
- **Terminal**: Compatible con cualquier terminal moderno

## 🤝 Contribuir

1. Fork del repositorio
2. Crear branch: `git checkout -b feature/mejora`
3. Seguir estructura de stow para nuevos paquetes
4. Commit: `git commit -m 'Add mejora'`
5. Push: `git push origin feature/mejora`
6. Pull Request

## 📄 Licencia

Repositorio personal de Kevin Barroso. Libre uso de configuraciones.

---

⭐ **¡Dale una estrella si te ayuda!** 🚀