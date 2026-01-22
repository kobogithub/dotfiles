# Changelog - OpenCode Configuration Tools

## [1.2.0] - 2026-01-20

### ✨ Added

#### Testing MCPs
- **5 new MCP servers for testing and automation:**
  - `playwright` - E2E testing with Playwright in Docker container
  - `puppeteer` - Browser automation and testing
  - `memory` - Persistent memory across sessions
  - `fetch` - HTTP requests and API testing
  - `sqlite` - Lightweight database for testing

#### New Example Configurations
- **astro-testing-config.json** - Astro project with E2E testing setup
  - Playwright for E2E tests
  - Puppeteer for browser automation
  - Fetch for API testing
  - Memory for persistent test configs
  
- **full-stack-testing-config.json** - Complete testing configuration
  - Backend testing with PostgreSQL
  - Frontend testing with Playwright
  - API testing with Fetch
  - SQLite for integration tests

#### Documentation Updates
- Added "MCPs para Testing" section in TOOLS.md
- Detailed setup guides for Playwright Docker
- Testing examples and use cases
- Updated examples/README.md with new configurations

### 🔧 Enhanced

#### Setup Script
- Added 5 new MCPs to COMMON_MCPS list
- Total MCPs available: 10 (previously 5)
- Better testing support out of the box

#### Documentation
- Comprehensive testing MCP documentation
- Docker setup instructions for Playwright
- Testing strategies and best practices
- Example configurations for different testing scenarios

### 📦 MCP Details

**Playwright MCP (Docker):**
```json
{
  "playwright": {
    "type": "stdio",
    "command": ["docker", "run", "-i", "--rm", "mcp/playwright"]
  }
}
```
- Requires Docker
- Isolated testing environment
- No local Playwright installation needed

**Other Testing MCPs:**
- Puppeteer: Node.js browser automation
- Memory: Remember test configs
- Fetch: API endpoint testing
- SQLite: Lightweight test database

## [1.1.0] - 2026-01-20

### 🔄 Changed

#### Model Update
- **Updated all agents to use `github-copilot/claude-sonnet-4.5`**
  - Global configuration (opencode.json)
  - All 7 agent markdown files
  - All 4 example configurations
  - Setup script default model
  - Documentation references

**Files Updated:**
- `opencode/.config/opencode/opencode.json` - All 7 agents
- `opencode/.config/opencode/agents/*.md` - All agent definitions
- `opencode/examples/*.json` - All example configurations
- `scripts/.local/bin/opencode-config-setup` - Default model
- `opencode/TOOLS.md` - Documentation examples

**Benefits:**
- Uses GitHub Copilot's Claude Sonnet 4.5 model
- Consistent model across all agents
- Better integration with GitHub Copilot ecosystem

## [1.0.0] - 2026-01-20

### ✨ Added

#### Scripts
- **opencode-help** - Sistema de ayuda rápida con referencia de comandos, agents, skills y ejemplos
- **opencode-config-setup** - Configurador interactivo con:
  - Selección múltiple de agents
  - Selección de skills
  - Configuración de MCPs pre-configurados (filesystem, postgres, git, github, brave-search)
  - Soporte para MCPs personalizados (stdio y sse)
  - Configuración de variables de entorno
  - Desactivación selectiva de MCPs
  - Interfaz colorida e intuitiva
- **opencode-config-list** - Listador recursivo de configuraciones con:
  - Búsqueda en directorios
  - Vista de agents, MCPs y skills
  - Estado de MCPs (habilitados/deshabilitados)
- **opencode-config-validate** - Validador de configuraciones con:
  - Validación de sintaxis JSON
  - Validación de esquema
  - Validación de agents, MCPs, tools y permissions
  - Reporte detallado de errores

#### Configuration
- **opencode.json** - Configuración global actualizada con todos los agents:
  - astro-dev
  - docker-expert
  - docs-writer
  - fastapi-dev
  - postgres-admin
  - qa-engineer
  - supabase-dev

#### Examples
- **full-stack-config.json** - Configuración completa para proyectos FastAPI + Astro + Docker
- **fastapi-backend-config.json** - Configuración para APIs con FastAPI
- **astro-frontend-config.json** - Configuración para proyectos frontend con Astro
- **docker-devops-config.json** - Configuración para DevOps con Docker

#### Documentation
- **TOOLS.md** - Guía completa de herramientas de configuración
- **examples/README.md** - Guía detallada de ejemplos con casos de uso
- **README.md** actualizado con sección de Configuration Tools

### 🎯 Features

- Selección interactiva de agents disponibles
- Configuración de MCPs con variables de entorno
- Soporte para tipos stdio y sse
- Validación completa de configuraciones
- Ejemplos listos para usar
- Sistema de ayuda integrado
- Búsqueda recursiva de configuraciones
- Interfaz colorida y amigable

### 📚 Agents

Total: 7 agents especializados
- Astro framework expert
- Docker containerization expert
- Technical documentation expert
- FastAPI development expert
- PostgreSQL optimization expert
- QA and testing expert
- Supabase backend expert

### 🛠️ Skills

Total: 6 skills
- astro-performance
- docker-compose-patterns
- documentation-guide
- fastapi-best-practices
- postgres-optimization
- testing-strategies

### 🔌 MCPs Pre-configurados

Total: 5 MCPs
- filesystem - Operaciones de archivos mejoradas
- postgres - Operaciones de base de datos PostgreSQL
- git - Operaciones avanzadas de git
- github - Integración con GitHub API
- brave-search - Búsquedas web

### 🚀 Usage Examples

```bash
# Ver ayuda
opencode-help

# Crear nueva configuración
cd my-project && opencode-config-setup

# Validar configuración
opencode-config-validate .opencode/config.json

# Listar configuraciones
opencode-config-list ~/projects

# Usar ejemplo
cp ~/.dotfiles/opencode/examples/fastapi-backend-config.json .opencode/config.json
```

### 📝 Documentation

- Documentación completa en TOOLS.md
- Guía de ejemplos en examples/README.md
- Ayuda rápida con `opencode-help`
- README principal actualizado

### 🔧 Technical Details

- Python 3 para scripts interactivos
- Bash para scripts de utilidad
- Carga automática de configuración desde archivos .md
- Validación JSON con verificación de esquema
- Búsqueda recursiva con filtros
- Interfaz con colores ANSI

### 🎨 User Experience

- Interfaz colorida e intuitiva
- Validación de entrada
- Mensajes de error claros
- Feedback visual constante
- Confirmaciones antes de sobrescribir
- Resúmenes de configuración

---

**Autor**: Kevin Barroso  
**Fecha**: 20 de Enero, 2026  
**Versión**: 1.0.0
