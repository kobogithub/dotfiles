# OpenCode Configuration

This package contains custom OpenCode agents and skills for full-stack development with FastAPI, PostgreSQL, Supabase, Docker, Astro, and comprehensive documentation and testing practices.

## 📂 Structure

```
opencode/
└── .config/
    └── opencode/
        ├── agents/              # Custom agents
        │   ├── fastapi-dev.md
        │   ├── postgres-admin.md
        │   ├── supabase-dev.md
        │   ├── docker-expert.md
        │   ├── astro-dev.md
        │   ├── docs-writer.md
        │   └── qa-engineer.md
        ├── skills/              # Reusable skills
        │   ├── fastapi-best-practices/
        │   │   └── SKILL.md
        │   ├── postgres-optimization/
        │   │   └── SKILL.md
        │   ├── docker-compose-patterns/
        │   │   └── SKILL.md
        │   ├── astro-performance/
        │   │   └── SKILL.md
        │   ├── documentation-guide/
        │   │   └── SKILL.md
        │   └── testing-strategies/
        │       └── SKILL.md
        └── opencode.json        # Global configuration
```

## 🤖 Available Agents

### FastAPI Development Agent
**Invoke with:** `@fastapi-dev`

Expert in building production-ready REST APIs with FastAPI. Specializes in:
- Project structure and architecture
- Pydantic v2 models and validation
- Dependency injection patterns
- Authentication and authorization
- Database integration (PostgreSQL, SQLAlchemy)
- Testing with pytest
- API documentation

### PostgreSQL Admin Agent
**Invoke with:** `@postgres-admin`

Database expert for optimization and administration. Specializes in:
- Query optimization with EXPLAIN ANALYZE
- Index design and strategy
- Performance monitoring
- Schema design and normalization
- Migrations and data integrity
- Backup and recovery

### Supabase Development Agent
**Invoke with:** `@supabase-dev`

Supabase expert for backend-as-a-service development. Specializes in:
- Row Level Security (RLS) policies
- Authentication setup
- Real-time subscriptions
- Database functions and triggers
- Storage bucket configuration
- Edge Functions (Deno)

### Docker Expert Agent
**Invoke with:** `@docker-expert`

Containerization expert for development and production. Specializes in:
- Multi-stage Dockerfile optimization
- Docker Compose configurations
- Health checks and dependencies
- Security best practices
- Network and volume management
- Production deployment patterns

### Astro Development Agent
**Invoke with:** `@astro-dev`

Astro framework expert for modern web applications. Specializes in:
- Island architecture patterns
- Content Collections
- SSR and hybrid rendering
- Image optimization
- View Transitions
- Performance optimization
- API routes

### Documentation Writer Agent
**Invoke with:** `@docs-writer`

Technical documentation expert for comprehensive project docs. Specializes in:
- API documentation (OpenAPI/Swagger)
- README and project documentation
- Architecture documentation
- Code comments and docstrings
- User guides and tutorials
- Changelog and release notes
- Contributing guidelines

### QA Engineer Agent
**Invoke with:** `@qa-engineer`

Quality assurance and testing expert. Specializes in:
- Test strategy and planning
- Unit, integration, and E2E tests
- Test automation frameworks
- Mocking and fixtures
- CI/CD testing pipelines
- Performance and load testing
- Test coverage optimization

## 📚 Available Skills

Skills are loaded on-demand by agents using the `skill` tool.

### FastAPI Best Practices
**Skill name:** `fastapi-best-practices`

Complete guide for structuring FastAPI projects including:
- Recommended project structure
- Repository pattern implementation
- Service layer patterns
- Dependency injection examples
- Authentication patterns
- Testing setup with pytest

### PostgreSQL Optimization
**Skill name:** `postgres-optimization`

Comprehensive PostgreSQL performance guide:
- Query optimization workflow
- Index strategies (B-tree, GIN, GiST, BRIN)
- EXPLAIN ANALYZE interpretation
- Performance monitoring queries
- Configuration tuning
- Common anti-patterns

### Docker Compose Patterns
**Skill name:** `docker-compose-patterns`

Battle-tested Docker Compose configurations:
- Multi-service development environments
- Database initialization scripts
- Health checks and dependencies
- Environment variable management
- Production deployment patterns
- Common stack combinations

### Astro Performance
**Skill name:** `astro-performance`

Complete Astro performance optimization guide:
- Core Web Vitals optimization
- Image optimization strategies
- Component hydration patterns
- Build optimization
- Caching strategies
- Font optimization

### Documentation Guide
**Skill name:** `documentation-guide`

Comprehensive technical documentation guide:
- Documentation types and templates
- API documentation standards
- Code comment conventions (Python, JavaScript)
- Architecture documentation patterns
- Changelog format (Keep a Changelog)
- Contributing guide template
- Writing best practices

### Testing Strategies
**Skill name:** `testing-strategies`

Complete testing strategy guide:
- Testing pyramid (unit, integration, E2E)
- pytest and Jest/Vitest patterns
- Fixtures and mocking strategies
- Parameterized testing
- CI/CD integration
- Performance testing with Locust
- Coverage goals and best practices

## 🛠️ Configuration Tools

### Quick Setup Script

Use the interactive configuration tool to set up OpenCode for any repository:

```bash
# Configure current repository
opencode-config-setup

# List all OpenCode configurations
opencode-config-list

# Search in a specific directory
opencode-config-list ~/projects
```

The `opencode-config-setup` tool provides an interactive way to:
- ✅ Select agents for your project needs
- ✅ Choose relevant skills
- ✅ Configure MCP servers (Model Context Protocol)
- ✅ Set up custom MCPs with environment variables
- ✅ Create `.opencode/config.json` with best practices

**Example session:**
```
🔧 OpenCode Configuration Setup

Repository path: /home/user/my-project

Select Agents:
  1. Astro Developer - Astro framework expert
  2. Docker Expert - Container expert
  3. FastAPI Developer - FastAPI REST API expert
  ...

Your selection: 3 5 7

✅ Selected 3 agent(s)

Select Skills:
  1. Astro Performance
  2. FastAPI Best Practices
  ...

✅ Configuration saved to: /home/user/my-project/.opencode/config.json
```

### Available MCPs

The setup tool includes common MCP servers:

| MCP | Description | Use Case |
|-----|-------------|----------|
| **filesystem** | Enhanced file operations | Complex file manipulations |
| **postgres** | Database operations | PostgreSQL queries and admin |
| **git** | Advanced git operations | Repository management |
| **github** | GitHub API integration | Issues, PRs, workflows |
| **brave-search** | Web search | Research and documentation lookup |
| **playwright** | E2E testing (Docker) | Browser testing for Astro apps |
| **puppeteer** | Browser automation | Testing and scraping |
| **memory** | Persistent memory | Remember configs across sessions |
| **fetch** | HTTP requests | API testing and web scraping |
| **sqlite** | SQLite database | Lightweight testing database |

You can also add custom MCPs:
```json
{
  "mcp": {
    "my-custom-mcp": {
      "type": "stdio",
      "command": ["bun", "x", "my-mcp-server"],
      "env": {
        "API_KEY": "your-key"
      }
    }
  }
}
```

**Testing with Playwright:**
```bash
# Pull Playwright Docker image
docker pull mcp/playwright

# Use the Astro testing example
cp ~/.dotfiles/opencode/examples/astro-testing-config.json .opencode/config.json
```

For detailed information, see: [Configuration Tools Guide](./TOOLS.md)

## 🚀 Usage

### Using Agents

Agents can be invoked in two ways:

1. **Switch between primary agents** (Tab key):
   - `build` - Full development (default)
   - `plan` - Analysis without changes

2. **Invoke subagents with @mention**:
   ```
   @fastapi-dev help me create a new API endpoint
   @postgres-admin optimize this query
   @supabase-dev set up RLS policies
   @docker-expert create a docker-compose file
   @astro-dev optimize images on this page
   @docs-writer create API documentation for this endpoint
   @qa-engineer help me write tests for this function
   ```

### Using Skills

Agents can load skills automatically when needed, or you can reference them:

```
Load the fastapi-best-practices skill and help me structure my project
```

Skills contain detailed patterns, code examples, and best practices that agents use to provide better assistance.

## ⚙️ Configuration

### Global Config (`opencode.json`)

```json
{
  "agent": {
    "build": {
      "mode": "primary",
      "temperature": 0.3
    },
    "plan": {
      "mode": "primary",
      "temperature": 0.1,
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "ask",
          "git status": "allow"
        }
      }
    }
  },
  "permission": {
    "skill": {
      "*": "allow"
    }
  }
}
```

### Per-Project Override

Create `.opencode/` in your project to override or extend:

```
my-project/
├── .opencode/
│   ├── agents/
│   │   └── project-specific.md
│   └── skills/
│       └── custom-workflow/
│           └── SKILL.md
└── src/
```

## 📦 Installation

This package is installed automatically with the dotfiles:

```bash
# Full installation
./install.sh

# Or install only opencode package
./install.sh -d opencode
```

This creates symlinks:
```
~/.config/opencode/agents/ -> ~/github/dotfiles/opencode/.config/opencode/agents/
~/.config/opencode/skills/ -> ~/github/dotfiles/opencode/.config/opencode/skills/
~/.config/opencode/opencode.json -> ~/github/dotfiles/opencode/.config/opencode/opencode.json
```

## 🛠️ Tech Stack Support

These agents and skills are optimized for:

- **Backend:** FastAPI, Python, SQLAlchemy, Pydantic
- **Database:** PostgreSQL, Supabase
- **Frontend:** Astro, TypeScript, React/Vue/Svelte
- **Infrastructure:** Docker, Docker Compose
- **Tools:** pytest, Alembic, Celery, Redis

## 📝 Adding New Agents

Create a new agent in `opencode/.config/opencode/agents/`:

```markdown
---
description: Brief description of what this agent does
mode: subagent
temperature: 0.2
tools:
  write: true
  edit: true
---

You are an expert in...

## Core Responsibilities
- Task 1
- Task 2

## Best Practices
- Practice 1
- Practice 2
```

## 📝 Adding New Skills

Create a new skill directory:

```bash
mkdir -p opencode/.config/opencode/skills/my-skill
```

Create `SKILL.md`:

```markdown
---
name: my-skill
description: Brief description for agents to know when to load this
license: MIT
compatibility: opencode
---

## What I do
Detailed explanation of what this skill provides

## When to use me
- Situation 1
- Situation 2

## Content
Your patterns, examples, and best practices here
```

## 🔗 Links

- [OpenCode Documentation](https://opencode.ai/docs)
- [OpenCode Agents Guide](https://opencode.ai/docs/agents)
- [OpenCode Skills Guide](https://opencode.ai/docs/agent-skills)

## 📄 License

MIT - See main repository LICENSE
