# OpenCode Configuration Examples

Ejemplos de configuraciones para diferentes tipos de proyectos.

## Cómo usar estos ejemplos

```bash
# 1. Copia el ejemplo que más se ajuste a tu proyecto
cp ~/.dotfiles/opencode/examples/fastapi-backend-config.json my-project/.opencode/config.json

# 2. Edita el archivo y ajusta según tus necesidades
# - Actualiza las URLs de base de datos
# - Configura tokens de API
# - Agrega/remueve agents según necesites

# 3. Abre el proyecto con OpenCode
code my-project
```

## Ejemplos disponibles

### 🚀 Full Stack (FastAPI + Astro)
**Archivo:** `full-stack-config.json`

Configuración completa para un proyecto full-stack con:
- **Backend:** FastAPI + PostgreSQL
- **Frontend:** Astro
- **Agents:** fastapi-dev, astro-dev, postgres-admin, docker-expert, qa-engineer
- **MCPs:** postgres, git, github, brave-search, custom MCP
- **Skills:** Todos los disponibles

**Ideal para:**
- Aplicaciones web completas
- SaaS applications
- Plataformas web

**Uso:**
```bash
cp ~/.dotfiles/opencode/examples/full-stack-config.json .opencode/config.json
```

### 🔧 Backend API (FastAPI)
**Archivo:** `fastapi-backend-config.json`

Configuración enfocada en desarrollo de APIs con FastAPI:
- **Agents:** fastapi-dev, postgres-admin, qa-engineer
- **MCPs:** postgres, git
- **Skills:** fastapi-best-practices, postgres-optimization, testing-strategies

**Ideal para:**
- APIs REST
- Microservicios
- Backends de aplicaciones móviles

**Uso:**
```bash
cp ~/.dotfiles/opencode/examples/fastapi-backend-config.json .opencode/config.json
```

### 🎨 Frontend (Astro)
**Archivo:** `astro-frontend-config.json`

Configuración para proyectos frontend con Astro:
- **Agents:** astro-dev, docs-writer
- **MCPs:** git, github
- **Skills:** astro-performance, documentation-guide

**Ideal para:**
- Sitios web estáticos
- Blogs
- Landing pages
- Marketing sites

**Uso:**
```bash
cp ~/.dotfiles/opencode/examples/astro-frontend-config.json .opencode/config.json
```

### 🧪 Astro con Testing E2E
**Archivo:** `astro-testing-config.json`

Configuración para proyectos Astro con énfasis en testing:
- **Agents:** astro-dev, qa-engineer, docs-writer
- **MCPs:** playwright (Docker), puppeteer, git, github, memory, fetch
- **Skills:** astro-performance, testing-strategies, documentation-guide

**Características:**
- Testing E2E con Playwright en Docker
- Browser automation con Puppeteer
- API testing con Fetch MCP
- Memoria persistente de resultados

**Ideal para:**
- Aplicaciones Astro con tests E2E
- Proyectos que requieren validación en navegador
- Testing de componentes interactivos

**Uso:**
```bash
cp ~/.dotfiles/opencode/examples/astro-testing-config.json .opencode/config.json

# Preparar Playwright Docker
docker pull mcp/playwright
```

### 🚀 Full Stack con Testing
**Archivo:** `full-stack-testing-config.json`

Configuración completa con testing para backend y frontend:
- **Agents:** fastapi-dev, astro-dev, postgres-admin, qa-engineer, docker-expert
- **MCPs:** postgres, playwright, git, github, memory, fetch, sqlite
- **Skills:** Todos los principales

**Características:**
- Testing E2E con Playwright
- Testing de APIs con Fetch
- Base de datos de test con SQLite
- Integración completa de testing

**Ideal para:**
- Proyectos full-stack con CI/CD
- Aplicaciones que requieren testing comprehensivo
- Equipos de desarrollo con QA

**Uso:**
```bash
cp ~/.dotfiles/opencode/examples/full-stack-testing-config.json .opencode/config.json

# Preparar entorno
docker pull mcp/playwright
```

cp ~/.dotfiles/opencode/examples/astro-frontend-config.json .opencode/config.json
```

### 🐳 DevOps/Docker
**Archivo:** `docker-devops-config.json`

Configuración para proyectos con énfasis en containerización:
- **Agents:** docker-expert, postgres-admin
- **MCPs:** git
- **Skills:** docker-compose-patterns, postgres-optimization

**Ideal para:**
- Configuración de entornos de desarrollo
- Proyectos con Docker Compose
- Infraestructura como código

**Uso:**
```bash
cp ~/.dotfiles/opencode/examples/docker-devops-config.json .opencode/config.json
```

## Personalización

### Modificar agents

Agrega o remueve agents según tus necesidades:

```json
{
  "agent": {
    "fastapi-dev": { /* config */ },
    "supabase-dev": { /* añadir Supabase */ }
  }
}
```

### Configurar MCPs

#### PostgreSQL
```json
{
  "mcp": {
    "postgres": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

#### GitHub
```json
{
  "mcp": {
    "github": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

### Deshabilitar MCPs

```json
{
  "tools": {
    "brave-search": false,  // Deshabilitar por defecto
    "my-custom-mcp": false
  }
}
```

### Agregar skills

```json
{
  "permission": {
    "skill": {
      "fastapi-best-practices": "allow",
      "testing-strategies": "allow"
    }
  }
}
```

## Tips

### 🔒 Seguridad

**NUNCA** commitees tokens o credenciales en el repositorio:

```bash
# .gitignore
.opencode/config.json  # Si contiene credenciales

# O mejor, usa variables de entorno
.env
```

**Usa variables de entorno:**
```json
{
  "mcp": {
    "github": {
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"  // Lee de variable de entorno
      }
    }
  }
}
```

### ⚡ Performance

- Usa solo los agents que necesitas
- Deshabilita MCPs que no uses frecuentemente
- Los skills se cargan on-demand, no afectan performance inicial

### 🎯 Organización

**Por equipo:**
```
my-project/
├── .opencode/
│   ├── config.json              # Configuración del equipo
│   └── config.local.json        # Configuración personal (gitignored)
```

**Por ambiente:**
```
my-project/
├── .opencode/
│   ├── config.json              # Desarrollo
│   ├── config.staging.json      # Staging
│   └── config.prod.json         # Producción
```

## Creación desde cero

Si prefieres crear tu configuración desde cero de forma interactiva:

```bash
cd my-project
opencode-config-setup
```

El script te guiará paso a paso para seleccionar agents, skills y MCPs.

## Validación

Valida tu configuración antes de usarla:

```bash
# Verifica que el JSON es válido
cat .opencode/config.json | jq .

# Lista todas las configuraciones en tu sistema
opencode-config-list
```

## Migración

### Desde configuración antigua

Si tienes una configuración antigua sin MCPs:

```json
{
  "agent": {
    "fastapi-dev": { /* ... */ }
  }
}
```

Agrega la sección de MCPs:

```json
{
  "agent": {
    "fastapi-dev": { /* ... */ }
  },
  "mcp": {
    "git": {
      "type": "stdio",
      "command": ["npx", "-y", "@modelcontextprotocol/server-git"]
    }
  }
}
```

### Actualizar paths de MCPs

Si usas paths absolutos, cambia a comandos npx:

```json
// Antes
{
  "command": ["/usr/local/bin/mcp-server"]
}

// Después
{
  "command": ["npx", "-y", "@modelcontextprotocol/server-name"]
}
```

## Troubleshooting

### Error: "Agent not found"

Verifica que el agent está disponible en:
```bash
ls ~/.config/opencode/agents/
```

### Error: "MCP server failed to start"

1. Verifica que el comando existe:
   ```bash
   which npx
   npx -y @modelcontextprotocol/server-git --version
   ```

2. Revisa las variables de entorno en el config

3. Mira los logs de OpenCode

### Skills no se cargan

Verifica que están en:
```bash
ls ~/.config/opencode/skills/
```

Y que están permitidos en la configuración:
```json
{
  "permission": {
    "skill": {
      "skill-name": "allow"
    }
  }
}
```

## Referencias

- [OpenCode Documentation](https://opencode.ai/docs)
- [MCP Protocol](https://modelcontextprotocol.io)
- [Agent Configuration](../README.md)
- [Skills Guide](../README.md#skills)

---

¿Necesitas ayuda? Usa `opencode-config-setup` para una configuración interactiva.
