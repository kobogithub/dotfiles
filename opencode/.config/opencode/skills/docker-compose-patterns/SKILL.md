---
name: docker-compose-patterns
description: Common Docker Compose patterns for development and production
license: MIT
compatibility: opencode
metadata:
  stack: docker, containers, devops
  audience: developers, devops
---

## What I do

I provide battle-tested Docker Compose configurations and patterns for:

- Multi-service development environments
- Database setup with initialization
- Service dependencies and health checks
- Environment variable management
- Volume and network configuration
- Production-ready compose files
- Common stack combinations (FastAPI + Postgres, Astro + Supabase, etc.)

## When to use me

Use this skill when:

- Setting up a new project's development environment
- Configuring databases with Docker
- Managing multi-service applications
- Need health checks and dependency ordering
- Implementing secrets management
- Creating production Docker Compose setups

## Full-Stack Development Pattern

### FastAPI + PostgreSQL + Redis

```yaml
version: '3.9'

services:
  # PostgreSQL Database
  db:
    image: postgres:16-alpine
    container_name: ${PROJECT_NAME:-app}_db
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
      POSTGRES_DB: ${DB_NAME:-app_db}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
      - ./docker/postgres/postgresql.conf:/etc/postgresql/postgresql.conf:ro
    ports:
      - "${DB_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres} -d ${DB_NAME:-app_db}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    networks:
      - backend

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: ${PROJECT_NAME:-app}_redis
    restart: unless-stopped
    command: >
      redis-server
      --appendonly yes
      --requirepass ${REDIS_PASSWORD:-redis_password}
      --maxmemory 256mb
      --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    ports:
      - "${REDIS_PORT:-6379}:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 5s
    networks:
      - backend

  # FastAPI Application
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: development
      args:
        - PYTHON_VERSION=3.11
    container_name: ${PROJECT_NAME:-app}_api
    restart: unless-stopped
    environment:
      # Database
      DATABASE_URL: postgresql+asyncpg://${DB_USER:-postgres}:${DB_PASSWORD:-postgres}@db:5432/${DB_NAME:-app_db}
      DB_ECHO: ${DB_ECHO:-false}
      # Redis
      REDIS_URL: redis://:${REDIS_PASSWORD:-redis_password}@redis:6379/0
      # App
      ENVIRONMENT: ${ENVIRONMENT:-development}
      DEBUG: ${DEBUG:-true}
      SECRET_KEY: ${SECRET_KEY}
      LOG_LEVEL: ${LOG_LEVEL:-info}
      # CORS
      CORS_ORIGINS: ${CORS_ORIGINS:-http://localhost:3000,http://localhost:4321}
    volumes:
      - ./backend:/app
      - /app/.venv  # Don't overwrite virtualenv in container
      - api_logs:/app/logs
    ports:
      - "${API_PORT:-8000}:8000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - frontend
      - backend
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

  # Celery Worker (Background Tasks)
  worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: development
    container_name: ${PROJECT_NAME:-app}_worker
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql+asyncpg://${DB_USER:-postgres}:${DB_PASSWORD:-postgres}@db:5432/${DB_NAME:-app_db}
      REDIS_URL: redis://:${REDIS_PASSWORD:-redis_password}@redis:6379/0
      ENVIRONMENT: ${ENVIRONMENT:-development}
    volumes:
      - ./backend:/app
      - /app/.venv
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - backend
    command: celery -A app.worker worker --loglevel=info

  # Astro Frontend
  web:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      target: development
      args:
        - NODE_VERSION=20
    container_name: ${PROJECT_NAME:-app}_web
    restart: unless-stopped
    environment:
      PUBLIC_API_URL: ${PUBLIC_API_URL:-http://localhost:8000}
      PUBLIC_WS_URL: ${PUBLIC_WS_URL:-ws://localhost:8000}
    volumes:
      - ./frontend:/app
      - /app/node_modules
      - /app/.astro
    ports:
      - "${WEB_PORT:-4321}:4321"
    depends_on:
      api:
        condition: service_healthy
    networks:
      - frontend
    command: npm run dev -- --host 0.0.0.0

  # Nginx Reverse Proxy (Optional for production-like setup)
  nginx:
    image: nginx:alpine
    container_name: ${PROJECT_NAME:-app}_nginx
    restart: unless-stopped
    volumes:
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./docker/nginx/conf.d:/etc/nginx/conf.d:ro
    ports:
      - "${NGINX_PORT:-80}:80"
    depends_on:
      - api
      - web
    networks:
      - frontend
    profiles:
      - production

  # Development Tools (only started with --profile tools)
  
  # pgAdmin - Database Management
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: ${PROJECT_NAME:-app}_pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@admin.com}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin}
      PGADMIN_LISTEN_PORT: 80
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
      - pgadmin_data:/var/lib/pgadmin
      - ./docker/pgadmin/servers.json:/pgadmin4/servers.json:ro
    ports:
      - "${PGADMIN_PORT:-5050}:80"
    depends_on:
      - db
    networks:
      - backend
    profiles:
      - tools

  # Redis Commander - Redis Management
  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: ${PROJECT_NAME:-app}_redis_commander
    restart: unless-stopped
    environment:
      REDIS_HOSTS: local:redis:6379:0:${REDIS_PASSWORD:-redis_password}
    ports:
      - "${REDIS_COMMANDER_PORT:-8081}:8081"
    depends_on:
      - redis
    networks:
      - backend
    profiles:
      - tools

  # Mailhog - Email Testing
  mailhog:
    image: mailhog/mailhog:latest
    container_name: ${PROJECT_NAME:-app}_mailhog
    restart: unless-stopped
    ports:
      - "${MAILHOG_SMTP_PORT:-1025}:1025"  # SMTP
      - "${MAILHOG_UI_PORT:-8025}:8025"    # Web UI
    networks:
      - backend
    profiles:
      - tools

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  pgadmin_data:
    driver: local
  api_logs:
    driver: local

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: false  # Set to true in production to isolate backend
```

### Environment Variables (.env)

```bash
# Project
PROJECT_NAME=myapp
ENVIRONMENT=development

# Database
DB_USER=postgres
DB_PASSWORD=your_secure_password_here
DB_NAME=app_db
DB_PORT=5432
DB_ECHO=false

# Redis
REDIS_PASSWORD=your_redis_password_here
REDIS_PORT=6379

# API
API_PORT=8000
SECRET_KEY=your_very_secret_key_here_change_in_production
DEBUG=true
LOG_LEVEL=info
CORS_ORIGINS=http://localhost:3000,http://localhost:4321

# Frontend
WEB_PORT=4321
PUBLIC_API_URL=http://localhost:8000
PUBLIC_WS_URL=ws://localhost:8000

# Tools
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050
REDIS_COMMANDER_PORT=8081
MAILHOG_SMTP_PORT=1025
MAILHOG_UI_PORT=8025

# Nginx
NGINX_PORT=80
```

## Database Initialization

### PostgreSQL Init Script

```sql
-- docker/postgres/init.sql
-- This runs once when the database is first created

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create additional databases if needed
CREATE DATABASE test_db;

-- Create roles
CREATE ROLE app_user WITH LOGIN PASSWORD 'app_password';

-- Grant permissions
GRANT CONNECT ON DATABASE app_db TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO app_user;

-- Create initial schema if needed
-- CREATE TABLE IF NOT EXISTS users (...);
```

### PostgreSQL Custom Configuration

```ini
# docker/postgres/postgresql.conf
# Performance Tuning

# Memory Settings
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 16MB
maintenance_work_mem = 64MB

# Connection Settings
max_connections = 100

# WAL Settings
wal_buffers = 8MB
checkpoint_completion_target = 0.9

# Query Tuning
random_page_cost = 1.1
effective_io_concurrency = 200

# Logging
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'mod'
log_duration = on
log_min_duration_statement = 1000
```

## Production Compose Pattern

```yaml
version: '3.9'

services:
  db:
    image: postgres:16-alpine
    restart: always
    environment:
      POSTGRES_USER_FILE: /run/secrets/db_user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    secrets:
      - db_user
      - db_password
    networks:
      - backend
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
        max_attempts: 3
        window: 120s
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 30s
      timeout: 10s
      retries: 3

  api:
    image: ${REGISTRY}/api:${VERSION}
    restart: always
    environment:
      DATABASE_URL_FILE: /run/secrets/database_url
      REDIS_URL_FILE: /run/secrets/redis_url
      SECRET_KEY_FILE: /run/secrets/secret_key
      ENVIRONMENT: production
    secrets:
      - database_url
      - redis_url
      - secret_key
    networks:
      - frontend
      - backend
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        order: start-first
      rollback_config:
        parallelism: 1
        delay: 5s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  web:
    image: ${REGISTRY}/web:${VERSION}
    restart: always
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - nginx_cache:/var/cache/nginx
    depends_on:
      - api
      - web
    networks:
      - frontend
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role == worker

secrets:
  db_user:
    external: true
  db_password:
    external: true
  database_url:
    external: true
  redis_url:
    external: true
  secret_key:
    external: true

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=storage.example.com,rw
      device: ":/mnt/data/postgres"
  nginx_cache:
    driver: local

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay
    internal: true
```

## Common Patterns

### 1. Wait for Service to be Ready

```yaml
# Method 1: Health checks (recommended)
services:
  api:
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

# Method 2: Wait script (legacy)
services:
  api:
    depends_on:
      - db
    command: >
      sh -c "
        while ! nc -z db 5432; do sleep 1; done;
        uvicorn app.main:app --host 0.0.0.0
      "
```

### 2. Override for Different Environments

```yaml
# docker-compose.yml (base)
services:
  api:
    image: myapi:latest
    environment:
      - ENVIRONMENT=production

# docker-compose.override.yml (development, auto-loaded)
services:
  api:
    build: .
    volumes:
      - .:/app
    environment:
      - ENVIRONMENT=development
      - DEBUG=true

# docker-compose.prod.yml (production, explicit)
services:
  api:
    environment:
      - ENVIRONMENT=production
      - DEBUG=false
    deploy:
      replicas: 3
```

Usage:
```bash
# Development (auto-uses override)
docker-compose up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### 3. Profiles for Optional Services

```yaml
services:
  # Always starts
  api:
    image: api:latest
  
  # Only with --profile tools
  pgadmin:
    image: dpage/pgadmin4
    profiles:
      - tools
  
  # Only with --profile monitoring
  prometheus:
    image: prom/prometheus
    profiles:
      - monitoring
```

```bash
# Start core services
docker-compose up

# Start with tools
docker-compose --profile tools up

# Start with multiple profiles
docker-compose --profile tools --profile monitoring up
```

## Useful Commands

```bash
# Start services
docker-compose up -d

# Start with profiles
docker-compose --profile tools up -d

# View logs
docker-compose logs -f api

# Execute command in container
docker-compose exec api bash
docker-compose exec db psql -U postgres

# Restart service
docker-compose restart api

# Rebuild and restart
docker-compose up -d --build api

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Check configuration
docker-compose config

# View resource usage
docker-compose top

# Scale service
docker-compose up -d --scale api=3
```

## Tips

- Use health checks for reliable dependency management
- Leverage profiles for optional development tools
- Keep secrets in `.env` (gitignored) or use Docker secrets
- Use named volumes for data persistence
- Implement proper networking (frontend/backend separation)
- Add resource limits in production
- Use `restart: unless-stopped` for automatic recovery
- Mount only necessary paths as volumes
- Use multi-stage Dockerfiles with development target
- Keep docker-compose.yml version controlled
- Document required environment variables in `.env.example`
