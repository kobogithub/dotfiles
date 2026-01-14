# 🏠 Dotfiles

Repositorio centralizado para mis configuraciones personales usando GNU Stow para una gestión limpia y modular de dotfiles.

## 📁 Estructura

```
dotfiles/
├── git/             # Configuración de Git (~/.gitconfig)
├── bash/            # Configuración de Bash (~/.bashrc)
├── vim/             # Configuración de Vim (~/.vimrc, ~/.vim/)
├── nvim/            # Configuración de Neovim (~/.config/nvim/)
├── tmux/            # Configuración de tmux (~/.tmux.conf)
├── scripts/         # Scripts útiles (~/.local/bin/)
├── install.sh       # Script de instalación automática
└── README.md        # Este archivo
```

## 🚀 Instalación

### Prerrequisitos

Instalar GNU Stow:

```bash
# Ubuntu/Debian
sudo apt install stow

# macOS
brew install stow

# Arch Linux
sudo pacman -S stow

# CentOS/RHEL
sudo yum install stow
```

### Instalación automática

```bash
# Clonar el repositorio
git clone https://github.com/kobogithub/dotfiles.git ~/.dotfiles

# Ir al directorio
cd ~/.dotfiles

# Instalar todos los paquetes
./install.sh -a

# O instalar paquetes específicos
./install.sh git bash vim
```

### Instalación manual con stow

```bash
cd ~/.dotfiles

# Instalar paquetes específicos
stow git     # Instala ~/.gitconfig
stow bash    # Instala ~/.bashrc
stow vim     # Instala ~/.vimrc y ~/.vim/

# Desinstalar un paquete
stow -D git  # Remueve enlaces de git
```

## 📦 Paquetes disponibles

### 🔧 git
- `.gitconfig` - Configuración global de Git con aliases útiles
- Incluye configuración de usuario y preferencias

### 🐚 bash
- `.bashrc` - Configuración de Bash con aliases y prompt personalizado
- Variables de entorno y configuración de historial

### ✏️ vim
- `.vimrc` - Configuración básica de Vim
- `.vim/` - Directorio para plugins y temas

### 🚀 scripts
- `.local/bin/backup-files` - Script para backup rápido de configuraciones
- Otros scripts útiles para automatización

## 🔧 Uso del script de instalación

```bash
# Mostrar ayuda
./install.sh -h

# Instalar todos los paquetes
./install.sh -a

# Instalar paquetes específicos
./install.sh git bash vim

# Desinstalar paquetes
./install.sh -u git bash

# Ver paquetes disponibles
./install.sh
```

## ✨ Características de Stow

- **Enlaces simbólicos**: Mantiene archivos organizados en el repo
- **Modular**: Instala/desinstala paquetes independientemente
- **Sin conflictos**: Detecta y previene sobreescribir archivos existentes
- **Reversible**: Fácil desinstalación con `stow -D`

## 📋 Flujo de trabajo

### Agregar nueva configuración

1. **Crear nuevo paquete**:
   ```bash
   mkdir nueva-herramienta
   mkdir -p nueva-herramienta/.config/nueva-herramienta
   ```

2. **Agregar archivos de configuración**:
   ```bash
   # Copiar configuración existente
   cp ~/.config/nueva-herramienta/config nueva-herramienta/.config/nueva-herramienta/
   ```

3. **Instalar con stow**:
   ```bash
   stow nueva-herramienta
   ```

4. **Commit y push**:
   ```bash
   git add nueva-herramienta/
   git commit -m "Add nueva-herramienta configuration"
   git push origin dev
   ```

### Actualizar configuraciones

```bash
cd ~/.dotfiles

# Actualizar desde el repositorio
git pull origin dev

# Re-instalar paquetes si es necesario
./install.sh git bash vim
```

### Backup antes de instalar

```bash
# Usar el script de backup incluido
~/.local/bin/backup-files

# O hacer backup manual
cp ~/.bashrc ~/.bashrc.backup
cp ~/.gitconfig ~/.gitconfig.backup
```

## 🎯 Ejemplos prácticos

### Configuración nueva en otra máquina

```bash
# Clonar dotfiles
git clone https://github.com/kobogithub/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Ver qué paquetes están disponibles
./install.sh

# Instalar solo lo básico
./install.sh git bash scripts

# Instalar desarrollo
./install.sh vim nvim tmux
```

### Probar configuración temporalmente

```bash
# Instalar temporalmente
stow vim

# Probar la configuración...

# Desinstalar si no gusta
stow -D vim
```

## 🛠️ Estructura de paquetes

Cada paquete debe replicar la estructura del home directory:

```
paquete/
├── .archivo-config          # Va a ~/.archivo-config
├── .config/
│   └── herramienta/
│       └── config.conf      # Va a ~/.config/herramienta/config.conf
└── .local/
    └── bin/
        └── script           # Va a ~/.local/bin/script
```

## 🤝 Contribuir

1. Fork del repositorio
2. Crear branch: `git checkout -b feature/nuevo-paquete`
3. Agregar/modificar paquetes siguiendo la estructura de stow
4. Commit: `git commit -m 'Add nuevo paquete'`
5. Push: `git push origin feature/nuevo-paquete`
6. Pull Request

## 📄 Licencia

Este repositorio es personal, pero siéntete libre de usar cualquier configuración que te sea útil.

---

⭐ Si este repositorio te ayuda, ¡dale una estrella!