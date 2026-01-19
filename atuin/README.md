# Atuin Dotfiles

Configuración de Atuin con soporte para dotfiles (aliases y variables) habilitado.

## ¿Qué es Atuin Dotfiles?

Atuin no solo guarda tu historial de comandos, también puede gestionar:
- **Aliases**: Atajos de comandos que persisten entre sesiones
- **Variables**: Variables de entorno y shell que se cargan automáticamente

Los datos se almacenan en la base de datos de Atuin y pueden sincronizarse entre máquinas (si habilitas sync).

## Ubicación de datos

**Configuración personalizada:**
- **Configuración**: `~/.config/atuin/config.toml` (versionado en dotfiles)
- **Base de datos**: `~/.dotfiles/atuin/data/history.db` (excluido de Git)
- **Clave de encriptación**: `~/.dotfiles/atuin/data/key` (excluido de Git)
- **Sesión**: `~/.dotfiles/atuin/data/session` (excluido de Git)

**Nota:** Los datos personales (historial, claves, sesiones) están en `atuin/data/` y están excluidos del control de versiones mediante `.gitignore`. Solo la configuración se versiona en Git.

## Comandos principales

### Aliases

```bash
# Agregar un alias
atuin dotfiles alias set <nombre> <comando>
atuin dotfiles alias set gst "git status"
atuin dotfiles alias set ll "ls -la"

# Listar todos los aliases
atuin dotfiles alias list

# Eliminar un alias
atuin dotfiles alias delete <nombre>
atuin dotfiles alias delete gst

# Limpiar todos los aliases
atuin dotfiles alias clear
```

### Variables

```bash
# Establecer una variable
atuin dotfiles var set <nombre> <valor>
atuin dotfiles var set EDITOR nvim
atuin dotfiles var set AWS_PROFILE production

# Listar todas las variables
atuin dotfiles var list

# Eliminar una variable
atuin dotfiles var delete <nombre>
```

## Aliases cortos incluidos

Para facilitar el uso, se han agregado estos aliases:

```bash
# Atuin aliases
atuin-alias-set    # atuin dotfiles alias set
atuin-alias-list   # atuin dotfiles alias list
atuin-alias-rm     # atuin dotfiles alias delete

# Atuin variables
atuin-var-set      # atuin dotfiles var set
atuin-var-list     # atuin dotfiles var list
```

## Ejemplos de uso

```bash
# Agregar alias para comandos frecuentes
atuin-alias-set gp "git push"
atuin-alias-set gc "git commit -m"
atuin-alias-set dc "docker compose"

# Ver todos tus aliases
atuin-alias-list

# Variables de entorno
atuin-var-set EDITOR nvim
atuin-var-set AWS_REGION us-east-1

# Eliminar un alias
atuin-alias-rm gp
```

## Diferencias entre alias-manager y Atuin dotfiles

### alias-manager (archivos en dotfiles)
- ✅ Versionado con Git
- ✅ Organizado por categorías (general, k8s, docker)
- ✅ Fácil de compartir y revisar
- ✅ Edición manual con tu editor
- ❌ No se sincroniza automáticamente entre máquinas

### Atuin dotfiles (base de datos)
- ✅ Se puede sincronizar entre máquinas (con Atuin sync)
- ✅ Gestión desde la línea de comandos
- ✅ Historial de cambios automático
- ✅ Rápido de agregar/eliminar
- ❌ No versionado en Git
- ❌ Menos organizado por categorías

## Recomendaciones de uso

**Usa alias-manager para:**
- Aliases permanentes del equipo/proyecto
- Configuración que quieres versionar en Git
- Aliases que quieres documentar y compartir

**Usa Atuin dotfiles para:**
- Aliases personales/temporales
- Variables que cambias frecuentemente
- Configuraciones específicas de máquina
- Aliases que quieres sincronizar entre tus dispositivos

## Cargar aliases de Atuin automáticamente

Los aliases y variables de Atuin se cargan automáticamente cuando inicias tu shell si tienes `eval "$(atuin init zsh)"` en tu `.zshrc` (ya configurado).

## Sincronización (opcional)

Si quieres sincronizar tus aliases entre máquinas:

1. Crear cuenta en Atuin:
```bash
atuin register -u <tu-email> -p <password>
atuin login -u <tu-email> -p <password>
```

2. Habilitar sync en `~/.config/atuin/config.toml`:
```toml
auto_sync = true
sync_frequency = "1h"
```

3. Sincronizar manualmente:
```bash
atuin sync
```

## Ver más información

```bash
atuin dotfiles --help
atuin info
```
