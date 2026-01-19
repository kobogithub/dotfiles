# Atuin Data Directory

Este directorio contiene los datos personales de Atuin que **NO** deben ser versionados en Git.

## Archivos almacenados aquí:

- **history.db** - Base de datos SQLite con tu historial de comandos
- **history.db-shm** - Archivo de memoria compartida de SQLite
- **history.db-wal** - Write-Ahead Log de SQLite
- **key** - Clave de encriptación para sincronización
- **session** - Token de sesión de autenticación
- **records.db** - Base de datos de registros
- **scripts.db** - Base de datos de scripts

## Importante:

✅ Estos archivos están excluidos de Git mediante `.gitignore`
✅ Contienen datos personales y claves de encriptación
✅ No deben ser compartidos públicamente

## Backup:

Si quieres hacer backup de tu historial:

```bash
# Copiar base de datos
cp ~/.dotfiles/atuin/data/history.db ~/backups/

# Restaurar
cp ~/backups/history.db ~/.dotfiles/atuin/data/
```

## Migrar desde la ubicación por defecto:

Si tienes datos en `~/.local/share/atuin/`, puedes migrarlos:

```bash
cp ~/.local/share/atuin/history.db ~/.dotfiles/atuin/data/
cp ~/.local/share/atuin/key ~/.dotfiles/atuin/data/
cp ~/.local/share/atuin/session ~/.dotfiles/atuin/data/
```
