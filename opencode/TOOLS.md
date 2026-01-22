# OpenCode Configuration Tools

Herramientas para configurar y gestionar configuraciones de OpenCode en repositorios.

## Scripts Disponibles

### 🔧 `opencode-config-setup`

Script interactivo para crear configuraciones de OpenCode personalizadas para tus repositorios.

**Características:**
- ✅ Selección interactiva de agents disponibles
- ✅ Selección de skills
- ✅ Configuración de servidores MCP (pre-configurados o personalizados)
- ✅ Soporte para MCPs personalizados (stdio y sse)
- ✅ Variables de entorno para MCPs
- ✅ Desactivación selectiva de MCPs
- ✅ Interfaz colorida y fácil de usar

**Uso:**
```bash
# Configurar el repositorio actual
opencode-config-setup

# Configurar un repositorio específico (te preguntará la ruta)
opencode-config-setup
```

**Ejemplo de flujo:**
```
1. Selecciona la ruta del repositorio
2. Selecciona agents (ej: 1 3 5 o 'all')
3. Selecciona skills (ej: 2 4 o 'all')
4. Configura MCPs (opcional)
   - Selecciona MCPs pre-configurados
   - Agrega MCPs personalizados
   - Configura variables de entorno
5. Revisa y confirma la configuración
```

### 📋 `opencode-config-list`

Lista todas las configuraciones de OpenCode en tus repositorios.

**Características:**
- 🔍 Búsqueda recursiva de configuraciones
- 📊 Muestra agents, MCPs y skills configurados
- 🎨 Interfaz colorida y organizada
- ✅ Estado de MCPs (habilitados/deshabilitados)

**Uso:**
```bash
# Buscar en ~/github (por defecto)
opencode-config-list

# Buscar en un directorio específico
opencode-config-list /path/to/search
```

## Agents Disponibles

| ID | Nombre | Descripción |
|----|--------|-------------|
| `astro-dev` | Astro Developer | Experto en Astro framework |
| `docker-expert` | Docker Expert | Experto en containerización |
| `docs-writer` | Documentation Writer | Experto en documentación técnica |
| `fastapi-dev` | FastAPI Developer | Experto en APIs con FastAPI |
| `postgres-admin` | PostgreSQL Admin | Experto en optimización de bases de datos |
| `qa-engineer` | QA Engineer | Experto en testing y QA |
| `supabase-dev` | Supabase Developer | Experto en Supabase backend |

## Skills Disponibles

| ID | Nombre | Descripción |
|----|--------|-------------|
| `astro-performance` | Astro Performance | Optimización de aplicaciones Astro |
| `docker-compose-patterns` | Docker Compose Patterns | Patrones comunes de Docker Compose |
| `documentation-guide` | Documentation Guide | Mejores prácticas de documentación |
| `fastapi-best-practices` | FastAPI Best Practices | Estructura de proyectos FastAPI |
| `postgres-optimization` | PostgreSQL Optimization | Optimización de consultas y rendimiento |
| `testing-strategies` | Testing Strategies | Estrategias de testing comprehensivas |

## MCPs Pre-configurados

| ID | Nombre | Descripción | Comando |
|----|--------|-------------|---------|
| `filesystem` | Filesystem MCP | Operaciones de archivos mejoradas | `npx -y @modelcontextprotocol/server-filesystem` |
| `postgres` | PostgreSQL MCP | Operaciones de base de datos | `npx -y @modelcontextprotocol/server-postgres` |
| `git` | Git MCP | Operaciones avanzadas de git | `npx -y @modelcontextprotocol/server-git` |
| `github` | GitHub MCP | Integración con GitHub API | `npx -y @modelcontextprotocol/server-github` |
| `brave-search` | Brave Search MCP | Búsquedas web | `npx -y @modelcontextprotocol/server-brave-search` |
| `playwright` | Playwright MCP | Testing E2E con Playwright (Docker) | `docker run -i --rm mcp/playwright` |
| `puppeteer` | Puppeteer MCP | Automatización de navegador | `npx -y @modelcontextprotocol/server-puppeteer` |
| `memory` | Memory MCP | Memoria persistente entre sesiones | `npx -y @modelcontextprotocol/server-memory` |
| `fetch` | Fetch MCP | Peticiones HTTP y web scraping | `npx -y @modelcontextprotocol/server-fetch` |
| `sqlite` | SQLite MCP | Operaciones con SQLite | `npx -y @modelcontextprotocol/server-sqlite` |

## Estructura de Configuración

El archivo `.opencode/config.json` generado tiene la siguiente estructura:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "fastapi-dev": {
      "mode": "subagent",
      "description": "FastAPI development expert",
      "model": "github-copilot/claude-sonnet-4.5",
      "temperature": 0.2
    }
  },
  "mcp": {
    "postgres": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-postgres", "postgresql://localhost/mydb"]
    },
    "custom-mcp": {
      "type": "stdio",
      "command": ["bun", "x", "my-custom-mcp"],
      "env": {
        "API_KEY": "your-key"
      }
    }
  },
  "tools": {
    "custom-mcp": false
  },
  "permission": {
    "skill": {
      "fastapi-best-practices": "allow",
      "testing-strategies": "allow"
    }
  }
}
```

## Ejemplos de Uso

### Configurar un proyecto FastAPI con PostgreSQL

```bash
opencode-config-setup

# Seleccionar:
# - Agents: fastapi-dev, postgres-admin, qa-engineer
# - Skills: fastapi-best-practices, postgres-optimization, testing-strategies
# - MCPs: postgres, git
```

### Configurar un proyecto Astro

```bash
opencode-config-setup

# Seleccionar:
# - Agents: astro-dev, docs-writer
# - Skills: astro-performance, documentation-guide
# - MCPs: git, github
```

### Configurar un proyecto full-stack con Docker

```bash
opencode-config-setup

# Seleccionar:
# - Agents: astro-dev, fastapi-dev, docker-expert, postgres-admin
# - Skills: all
# - MCPs: postgres, git, filesystem
```

### Configurar testing E2E para Astro

```bash
opencode-config-setup

# Seleccionar:
# - Agents: astro-dev, qa-engineer
# - Skills: astro-performance, testing-strategies
# - MCPs: playwright, git, fetch
```

**O usa el ejemplo:**
```bash
cp ~/.dotfiles/opencode/examples/astro-testing-config.json .opencode/config.json
```

### Configurar full-stack con testing completo

```bash
# Usa el ejemplo completo con testing
cp ~/.dotfiles/opencode/examples/full-stack-testing-config.json .opencode/config.json
```

## Personalización de MCPs

### MCP tipo stdio (Standard I/O)

```json
{
  "mcp": {
    "my-custom-mcp": {
      "type": "stdio",
      "command": ["bun", "x", "my-mcp-command"],
      "env": {
        "API_KEY": "your-key",
        "API_URL": "https://api.example.com"
      }
    }
  }
}
```

### MCP tipo sse (Server-Sent Events)

```json
{
  "mcp": {
    "my-sse-mcp": {
      "type": "sse",
      "url": "https://mcp-server.example.com/sse"
    }
  }
}
```

### Deshabilitar MCPs por defecto

Puedes deshabilitar MCPs específicos para que solo se activen cuando sea necesario:

```json
{
  "tools": {
    "brave-search": false,
    "my-custom-mcp": false
  }
}
```

### MCPs para Testing

#### Playwright (E2E Testing con Docker)

```json
{
  "mcp": {
    "playwright": {
      "type": "stdio",
      "command": ["docker", "run", "-i", "--rm", "mcp/playwright"]
    }
  }
}
```

**Uso:** Testing end-to-end de aplicaciones web Astro
- Ejecuta tests de navegador en contenedor aislado
- No requiere instalación local de Playwright
- Ideal para CI/CD

**Preparación:**
```bash
# Descargar imagen de Docker
docker pull mcp/playwright
```

#### Puppeteer (Automatización de Navegador)

```json
{
  "mcp": {
    "puppeteer": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

**Uso:** Automatización de navegador y testing
- Screenshots y PDFs
- Scraping de contenido dinámico
- Tests de interacción de usuario

#### Memory (Persistencia de Tests)

```json
{
  "mcp": {
    "memory": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

**Uso:** Recordar configuraciones y resultados de tests
- Guarda preferencias de testing
- Histórico de resultados
- Configuraciones de entorno

#### Fetch (Testing de APIs)

```json
{
  "mcp": {
    "fetch": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
```

**Uso:** Testing de endpoints y servicios externos
- Pruebas de APIs REST
- Validación de respuestas
- Simulación de llamadas HTTP

#### SQLite (Testing con Base de Datos)

```json
{
  "mcp": {
    "sqlite": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sqlite", "./test.db"]
    }
  }
}
```

**Uso:** Tests de integración con base de datos ligera
- Base de datos en memoria para tests
- Rápido y sin dependencias externas
- Ideal para tests unitarios de queries

### Ejemplo Completo: Astro con Testing E2E

```json
{
  "agent": {
    "astro-dev": { /* ... */ },
    "qa-engineer": { /* ... */ }
  },
  "mcp": {
    "playwright": {
      "type": "stdio",
      "command": ["docker", "run", "-i", "--rm", "mcp/playwright"]
    },
    "fetch": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-fetch"]
    },
    "memory": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-memory"]
    }
  },
  "tools": {
    "memory": false  // Habilitar solo cuando se necesite
  }
}
```

## Tips y Mejores Prácticas

### 🎯 Selección de Agents

- **Proyectos pequeños**: Selecciona solo los agents necesarios (2-3)
- **Proyectos grandes**: Puedes usar 'all' para tener todos disponibles
- **Considera el contexto**: ¿Backend? ¿Frontend? ¿Full-stack?

### 🛠️ Skills

- Los skills son automáticos cuando seleccionas un agent relacionado
- Selecciona skills adicionales si necesitas guías específicas
- `testing-strategies` es útil para casi cualquier proyecto

### 🔌 MCPs

- **Git/GitHub**: Útil para operaciones de repositorio avanzadas
- **PostgreSQL**: Solo si tu proyecto usa PostgreSQL
- **Filesystem**: Para operaciones de archivos complejas
- **Brave Search**: Para proyectos que necesitan buscar información en web

### ⚡ Performance

- Deshabilita MCPs que no uses frecuentemente
- Los MCPs se pueden habilitar on-demand cuando se necesiten
- Menos MCPs = menor latencia de inicio

## Troubleshooting

### El script no encuentra los agents/skills

Asegúrate de que los archivos existen en:
- `~/.dotfiles/opencode/.config/opencode/agents/`
- `~/.dotfiles/opencode/.config/opencode/skills/`

### Error al crear la configuración

- Verifica que tienes permisos de escritura en el directorio
- Confirma que la ruta del repositorio existe

### MCP no funciona

- Verifica que el comando del MCP está instalado (ej: `npx`, `bun`)
- Revisa que las variables de entorno están configuradas correctamente
- Asegúrate de que el MCP no está deshabilitado en `tools`

## Configuración Avanzada

### Permisos de Agents

Puedes controlar qué comandos puede ejecutar cada agent:

```json
{
  "agent": {
    "fastapi-dev": {
      "permission": {
        "bash": {
          "*": "ask",
          "pytest*": "allow",
          "uvicorn*": "allow"
        }
      }
    }
  }
}
```

### Temperatura de Agents

Ajusta la creatividad vs. consistencia:

```json
{
  "agent": {
    "docs-writer": {
      "temperature": 0.3  // Más creativo para documentación
    },
    "fastapi-dev": {
      "temperature": 0.1  // Más consistente para código
    }
  }
}
```

### Modelos Personalizados

Usa diferentes modelos de IA:

```json
{
  "agent": {
    "my-agent": {
      "model": "github-copilot/claude-sonnet-4.5",  // Modelo recomendado
      "temperature": 0.2
    }
  }
}
```

## Integración con Proyectos

### Estructura Recomendada

```
my-project/
├── .opencode/
│   └── config.json          # Configuración del proyecto
├── .env                     # Variables de entorno (no commitear)
├── .gitignore              # Incluir .env
└── src/
```

### Ejemplo: Proyecto FastAPI completo

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "fastapi-dev": {
      "mode": "subagent",
      "description": "FastAPI development expert",
      "temperature": 0.2,
      "permission": {
        "bash": {
          "*": "ask",
          "pytest*": "allow",
          "uvicorn*": "allow",
          "alembic*": "allow"
        }
      }
    },
    "postgres-admin": {
      "mode": "subagent",
      "description": "PostgreSQL optimization expert",
      "temperature": 0.2
    },
    "docker-expert": {
      "mode": "subagent",
      "description": "Docker containerization expert",
      "temperature": 0.2
    },
    "qa-engineer": {
      "mode": "subagent",
      "description": "Testing and QA expert",
      "temperature": 0.2
    }
  },
  "mcp": {
    "postgres": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    },
    "git": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-git"]
    }
  },
  "permission": {
    "skill": {
      "fastapi-best-practices": "allow",
      "postgres-optimization": "allow",
      "docker-compose-patterns": "allow",
      "testing-strategies": "allow"
    }
  }
}
```

## Contribuir

Para agregar nuevos agents o skills:

1. **Agent**: Crea `~/.dotfiles/opencode/.config/opencode/agents/nuevo-agent.md`
2. **Skill**: Crea `~/.dotfiles/opencode/.config/opencode/skills/nuevo-skill/SKILL.md`
3. Actualiza las listas en `opencode-config-setup`
4. Documenta en este README

## Referencias

- [OpenCode Documentation](https://opencode.ai/docs)
- [MCP Protocol](https://modelcontextprotocol.io)
- [Model Context Protocol Servers](https://github.com/modelcontextprotocol/servers)
- [Dotfiles Repository](https://github.com/yourusername/dotfiles)

---

**Autor**: Kevin Barroso  
**Última actualización**: Enero 2026
