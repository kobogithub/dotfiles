---
name: postgres-optimization
description: PostgreSQL performance optimization techniques and query tuning
license: MIT
compatibility: opencode
metadata:
  stack: postgresql, sql, database
  audience: backend-developers, dba
---

## What I do

I provide comprehensive guidance on optimizing PostgreSQL databases including:

- Query optimization with EXPLAIN ANALYZE
- Index strategy and design
- Performance monitoring queries
- Configuration tuning
- Common performance anti-patterns
- Best practices for scalability

## When to use me

Use this skill when:

- Database queries are slow
- Need to optimize existing database schema
- Planning indexes for new features
- Investigating performance bottlenecks
- Setting up monitoring and alerting
- Preparing database for production scale

## Query Optimization Workflow

### 1. Identify Slow Queries

```sql
-- Enable pg_stat_statements extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find slowest queries by average execution time
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time,
    stddev_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Find queries with highest total time
SELECT 
    query,
    calls,
    total_exec_time,
    mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

### 2. Analyze Query Plans

```sql
-- EXPLAIN shows the query plan
EXPLAIN
SELECT u.username, p.title
FROM users u
JOIN posts p ON u.id = p.user_id
WHERE u.created_at > '2024-01-01';

-- EXPLAIN ANALYZE actually runs the query and shows real timing
EXPLAIN ANALYZE
SELECT u.username, p.title
FROM users u
JOIN posts p ON u.id = p.user_id
WHERE u.created_at > '2024-01-01';

-- Additional options for detailed output
EXPLAIN (ANALYZE, BUFFERS, VERBOSE, COSTS, FORMAT JSON)
SELECT * FROM posts WHERE user_id = 123;
```

### 3. Reading EXPLAIN Output

**Key metrics to look for:**

- **Seq Scan**: Full table scan (usually bad for large tables)
- **Index Scan**: Using index (good)
- **Index Only Scan**: Using index without table access (best)
- **Bitmap Heap Scan**: Using multiple indexes
- **Nested Loop**: Join strategy (good for small datasets)
- **Hash Join**: Join strategy (good for larger datasets)
- **Merge Join**: Join strategy (good for pre-sorted data)
- **Actual time**: Real execution time (vs estimated cost)
- **Rows**: Actual vs estimated rows (large differences indicate stale statistics)

**Example output interpretation:**

```
Seq Scan on posts  (cost=0.00..1234.56 rows=10000 width=100)
                   (actual time=0.015..45.678 rows=9876 loops=1)
  Filter: (created_at > '2024-01-01'::date)
  Rows Removed by Filter: 5432
Planning Time: 0.123 ms
Execution Time: 46.789 ms
```

## Indexing Strategies

### 1. When to Add Indexes

```sql
-- Index columns used in WHERE clauses
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Index columns used in JOIN conditions
CREATE INDEX idx_comments_post_id ON comments(post_id);

-- Index columns used in ORDER BY
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Composite index for multiple columns (order matters!)
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);

-- Partial index for subset of data
CREATE INDEX idx_published_posts ON posts(created_at) 
WHERE published = true;

-- Expression index for computed values
CREATE INDEX idx_users_lower_email ON users(LOWER(email));

-- Unique index for constraints
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);
```

### 2. Index Types

```sql
-- B-tree (default, good for equality and range queries)
CREATE INDEX idx_posts_id ON posts USING btree(id);

-- Hash (only equality, faster but limited use cases)
CREATE INDEX idx_sessions_token ON sessions USING hash(token);

-- GIN (Generalized Inverted Index - for arrays, JSONB, full-text search)
CREATE INDEX idx_posts_tags ON posts USING gin(tags);
CREATE INDEX idx_products_data ON products USING gin(data jsonb_path_ops);

-- GiST (Generalized Search Tree - for geometric data, full-text)
CREATE INDEX idx_locations_coords ON locations USING gist(coordinates);

-- BRIN (Block Range Index - for very large tables with natural ordering)
CREATE INDEX idx_logs_created ON logs USING brin(created_at);
```

### 3. Index Maintenance

```sql
-- Find unused indexes (candidates for removal)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
    AND indexrelname NOT LIKE 'pg_toast%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check index bloat
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS size,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Rebuild bloated index
REINDEX INDEX CONCURRENTLY idx_posts_user_id;

-- Update index statistics
ANALYZE posts;
```

## Query Optimization Techniques

### 1. Use Specific Columns (Avoid SELECT *)

```sql
-- Bad: Fetches all columns
SELECT * FROM posts WHERE user_id = 123;

-- Good: Fetch only needed columns
SELECT id, title, created_at FROM posts WHERE user_id = 123;
```

### 2. Optimize JOINs

```sql
-- Ensure foreign keys have indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_comments_post_id ON comments(post_id);

-- Use appropriate JOIN types
-- INNER JOIN (only matching rows)
SELECT p.title, u.username
FROM posts p
INNER JOIN users u ON p.user_id = u.id;

-- Use EXISTS instead of IN for subqueries
-- Bad
SELECT * FROM users WHERE id IN (SELECT user_id FROM posts);

-- Good
SELECT * FROM users u WHERE EXISTS (
    SELECT 1 FROM posts p WHERE p.user_id = u.id
);
```

### 3. Use CTEs (Common Table Expressions) Wisely

```sql
-- CTEs for readability
WITH active_users AS (
    SELECT id, username 
    FROM users 
    WHERE last_login > NOW() - INTERVAL '30 days'
),
recent_posts AS (
    SELECT user_id, COUNT(*) as post_count
    FROM posts
    WHERE created_at > NOW() - INTERVAL '7 days'
    GROUP BY user_id
)
SELECT 
    u.username,
    COALESCE(p.post_count, 0) as recent_posts
FROM active_users u
LEFT JOIN recent_posts p ON u.id = p.user_id;

-- Note: CTEs materialize results, sometimes LATERAL JOIN is better
```

### 4. Pagination Best Practices

```sql
-- Bad: OFFSET is slow for large offsets
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET 10000;

-- Good: Keyset pagination (cursor-based)
SELECT * FROM posts 
WHERE created_at < '2024-01-15 12:00:00'
ORDER BY created_at DESC 
LIMIT 20;

-- With composite index for better performance
CREATE INDEX idx_posts_created_id ON posts(created_at DESC, id DESC);

SELECT * FROM posts 
WHERE (created_at, id) < ('2024-01-15 12:00:00', 12345)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

### 5. Avoid N+1 Queries

```sql
-- Bad: N+1 queries (1 query + N queries in loop)
-- SELECT * FROM posts;
-- For each post: SELECT * FROM users WHERE id = post.user_id;

-- Good: Single query with JOIN
SELECT 
    p.*,
    u.username,
    u.email
FROM posts p
JOIN users u ON p.user_id = u.id;

-- Or use aggregation
SELECT 
    u.*,
    json_agg(p.*) as posts
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id;
```

## Performance Monitoring

### 1. Active Queries

```sql
-- See currently running queries
SELECT 
    pid,
    usename,
    application_name,
    state,
    query,
    NOW() - query_start AS duration
FROM pg_stat_activity
WHERE state = 'active'
    AND query NOT LIKE '%pg_stat_activity%'
ORDER BY duration DESC;

-- Kill long-running query
SELECT pg_cancel_backend(pid);  -- Graceful
SELECT pg_terminate_backend(pid);  -- Forceful
```

### 2. Table Statistics

```sql
-- Table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Vacuum and analyze statistics
SELECT 
    schemaname,
    tablename,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    n_live_tup,
    n_dead_tup
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
```

### 3. Connection Monitoring

```sql
-- Connection counts by state
SELECT 
    state,
    COUNT(*) as count
FROM pg_stat_activity
GROUP BY state;

-- Connection limits
SELECT 
    setting::int as max_connections,
    (SELECT count(*) FROM pg_stat_activity) as current_connections,
    setting::int - (SELECT count(*) FROM pg_stat_activity) as available_connections
FROM pg_settings
WHERE name = 'max_connections';
```

## Configuration Tuning

```sql
-- View current settings
SELECT name, setting, unit, context 
FROM pg_settings 
WHERE name IN (
    'shared_buffers',
    'effective_cache_size',
    'maintenance_work_mem',
    'work_mem',
    'max_connections'
);
```

### Recommended postgresql.conf Settings

```ini
# Memory Settings (adjust based on available RAM)
shared_buffers = 4GB              # 25% of RAM for dedicated server
effective_cache_size = 12GB       # 50-75% of RAM
work_mem = 50MB                   # RAM / max_connections / 4
maintenance_work_mem = 1GB        # RAM / 16

# Connection Settings
max_connections = 100             # Adjust based on workload

# Checkpoint Settings
checkpoint_completion_target = 0.9
wal_buffers = 16MB

# Planner Settings
random_page_cost = 1.1           # Lower for SSD (default 4.0)
effective_io_concurrency = 200   # Higher for SSD

# Query Monitoring
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
```

## Common Anti-Patterns

### 1. Not Using LIMIT

```sql
-- Bad: Returns all rows
SELECT * FROM posts;

-- Good: Limit results
SELECT * FROM posts LIMIT 100;
```

### 2. Implicit Type Conversions

```sql
-- Bad: Integer column with string comparison
SELECT * FROM users WHERE id = '123';  -- Prevents index usage

-- Good: Proper types
SELECT * FROM users WHERE id = 123;
```

### 3. Using OR in WHERE Clauses

```sql
-- Bad: OR prevents index usage
SELECT * FROM posts WHERE user_id = 1 OR user_id = 2;

-- Good: Use IN
SELECT * FROM posts WHERE user_id IN (1, 2);

-- Or UNION for different columns
SELECT * FROM posts WHERE user_id = 1
UNION ALL
SELECT * FROM posts WHERE category_id = 5;
```

### 4. Not Using Connection Pooling

```bash
# Always use connection pooling in production
# PgBouncer, pgpool-II, or application-level pooling
```

## Quick Optimization Checklist

- [ ] Enable `pg_stat_statements` for query monitoring
- [ ] Run `EXPLAIN ANALYZE` on slow queries
- [ ] Add indexes on foreign keys
- [ ] Add indexes on frequently filtered/sorted columns
- [ ] Use composite indexes for multiple-column queries
- [ ] Remove unused indexes
- [ ] Run `VACUUM ANALYZE` regularly (or enable autovacuum)
- [ ] Use specific columns instead of SELECT *
- [ ] Implement cursor-based pagination for large datasets
- [ ] Use connection pooling
- [ ] Monitor active queries and connection counts
- [ ] Set appropriate `work_mem` and `shared_buffers`
- [ ] Update table statistics after bulk operations
- [ ] Use appropriate index types (B-tree, GIN, GiST, etc.)
- [ ] Check for N+1 query problems

## Tools

- **pg_stat_statements**: Query performance monitoring
- **EXPLAIN ANALYZE**: Query execution analysis
- **pgBadger**: Log analyzer
- **pg_stat_activity**: Active connections and queries
- **PgBouncer**: Connection pooling
- **pgAdmin**: GUI administration tool
