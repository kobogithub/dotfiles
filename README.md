# 🏠 Dotfiles

Repositorio centralizado para mis configuraciones personales y archivos de configuración del sistema.

## 📁 Estructura

```
dotfiles/
├── config/          # Configuraciones para ~/.config/
├── home/           # Archivos para el directorio home (~)
├── scripts/        # Scripts útiles y herramientas
├── bin/           # Binarios ejecutables
├── install.sh     # Script de instalación automática
└── README.md      # Este archivo
```

## 🚀 Instalación

### Instalación automática

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/dotfiles.git ~/.dotfiles

# Ejecutar el script de instalación
cd ~/.dotfiles
./install.sh
```

### Instalación manual

```bash
# Enlazar configuraciones específicas
ln -s ~/.dotfiles/config/nvim ~/.config/nvim
ln -s ~/.dotfiles/home/.bashrc ~/.bashrc
ln -s ~/.dotfiles/home/.gitconfig ~/.gitconfig
```

## 📦 Contenido

### Configuraciones incluidas

- **Shell**: Configuraciones de bash/zsh
- **Editor**: Neovim, VS Code
- **Terminal**: Configuraciones de terminal
- **Git**: Configuración global de Git
- **Scripts**: Herramientas y scripts útiles

### Directorios

- `config/`: Archivos que van en `~/.config/`
- `home/`: Archivos que van directamente en `~`
- `scripts/`: Scripts y herramientas útiles
- `bin/`: Ejecutables personalizados

## 🔧 Uso

### Agregar nueva configuración

1. Copiar el archivo/directorio a la carpeta correspondiente
2. Ejecutar el script de instalación o crear enlace manual
3. Commit y push de los cambios

### Backup automático

El script de instalación crea automáticamente backups de archivos existentes con el formato:
`archivo.backup.YYYYMMDD_HHMMSS`

### Actualizar configuraciones

```bash
cd ~/.dotfiles
git pull origin dev
./install.sh  # Re-enlazar si es necesario
```

## 📋 TODO

- [ ] Configuración de Neovim
- [ ] Configuración de Zsh con Oh My Zsh
- [ ] Scripts de setup para diferentes sistemas
- [ ] Configuración de tmux
- [ ] Temas personalizados

## 🤝 Contribuir

Si encuentras mejoras o tienes sugerencias:

1. Fork del repositorio
2. Crear branch: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -m 'Agregar nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Pull Request

## 📄 Licencia

Este repositorio es personal, pero siéntete libre de usar cualquier configuración que te sea útil.

---

⭐ Si este repositorio te ayuda, ¡dale una estrella!