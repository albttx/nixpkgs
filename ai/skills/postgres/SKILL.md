---
name: postgres
description: Conventions for PostgreSQL work — schema design, versioned SQL migrations, indexing, query optimization, RLS and multi-tenancy, pgvector embeddings, connection pooling and database operations. Use for any .sql file, migrations directory, schema definition, query tuning, or Postgres configuration.
---

# PostgreSQL

Postgres 16+. Schemas that are correct, performant and maintainable. Think in
sets, not loops.

Postgres is the default answer for storage, queues, and vector search alike.
Adding a second datastore has to be argued for, not assumed.

## Migrations

**Migrations are versioned SQL files committed to the repo.** They are applied by
CI or a dedicated job. Ad-hoc DDL against a live database does not exist.

```
migrations/
  0001_initial_schema.sql
  0002_add_projects.sql
  0084_project_position.sql
```

Rules learned the hard way:

- **Numbering depends on who assigns it, and the two schemes do not mix:**
  - *Hand-numbered repos* (`supabase/migrations/NNNN_name.sql` and similar): pick
    the next number from the **live database's applied-migrations table**, not
    from `ls migrations/`. Two branches both reading the directory pick the same
    number and collide at merge.
  - *Tool-numbered repos* (`drizzle-kit generate`, and any generator with its own
    journal): the tool owns the index and reads its journal, not the database. Do
    not hand-edit it. Here the collision shows up as a **journal conflict at
    merge**, which is the thing to watch for: resolve it by regenerating, never by
    hand-renumbering the file.
- Apply through the repo's wrapper script, so that running the DDL and recording
  it in the migrations table happen in one step and cannot drift apart.
- A drift check in CI compares the repo against the live schema. Drift is a
  failure, not a warning.
- Generated migrations get read before they get committed. Never commit ORM
  output unreviewed.
- Push-style schema sync (`db:push`, `drizzle-kit push`) is a local-development
  convenience only. Banned against staging and production.
- Write the down/rollback path even when you expect never to run it. Writing it
  is what surfaces an irreversible migration while it is still cheap to redesign.
  Where the tooling has no down step, say in the file's header comment how a
  rollback would work.
- Test a migration against a copy of production data before it runs on production.
- Where a migration encodes a behaviour (ordering, defaults, a constraint), pin
  it with a test file next to the migration.

### Zero-downtime shape

```sql
-- 1. Add nullable (no lock)
ALTER TABLE orders ADD COLUMN status text;

-- 2. Backfill in batches (no long transaction)
UPDATE orders SET status = 'pending' WHERE status IS NULL AND id BETWEEN $1 AND $2;

-- 3. Constrain after backfill
ALTER TABLE orders ALTER COLUMN status SET NOT NULL;
ALTER TABLE orders ADD CONSTRAINT chk_orders_status
  CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled'));

-- 4. Index without locking
CREATE INDEX CONCURRENTLY idx_orders_status ON orders (status);
```

- Never `ADD COLUMN ... NOT NULL` without a default on a hot table.
- Always `CREATE INDEX CONCURRENTLY` in production.
- Never drop a column in the same release that stops using it. Wait one cycle.

## Schema design

```sql
CREATE TABLE users (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email       text NOT NULL UNIQUE,
    name        text NOT NULL,
    role        text NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user', 'viewer')),
    metadata    jsonb NOT NULL DEFAULT '{}',
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),
    deleted_at  timestamptz
);

CREATE INDEX idx_users_email_active ON users (email) WHERE deleted_at IS NULL;

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

- Use the real type system: enums, arrays, `jsonb`, `uuid`, `timestamptz`, `inet`,
  `cidr`, `numeric`. No stringly-typed workarounds.
- Foreign keys are not optional. `CHECK` constraints for valid ranges.
- `NOT NULL` unless nullability is documented and meant.
- Normalize by default; denormalize deliberately and write down why.

## pgvector

Embeddings live **in Postgres** via `pgvector`. No external vector database.

```sql
CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE memories ADD COLUMN embedding vector(1536);

CREATE INDEX idx_memories_embedding ON memories
  USING hnsw (embedding vector_cosine_ops);
```

The reason is not benchmarks, it is that keeping vectors in Postgres preserves
JOINs against the rest of the data, keeps one backup and one consistency story,
and keeps GDPR deletion to a single `DELETE`. A managed vector service buys speed
at the cost of all three. Do not reintroduce one without a measured reason.

Always filter with the tenant predicate in the same query as the vector search,
not afterwards in application code.

## Multi-tenancy and RLS

```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON projects
    USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

- Every tenant-scoped table carries the tenant column and an RLS policy.
- The application sets the tenant context per request: `SET LOCAL app.tenant_id = ...`.
- Privileged operations that RLS must not permit go through a `SECURITY DEFINER`
  function called as an RPC, never through a service-role client in request code.
- Test RLS. A policy nobody exercised is a policy that does not work.

## Indexing

```sql
-- B-tree: equality and range (default)
CREATE INDEX idx_orders_created ON orders (created_at);

-- GIN: jsonb, arrays, full-text
CREATE INDEX idx_users_metadata ON users USING gin (metadata);

-- Partial: the common WHERE clause
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = 'pending';

-- Covering: avoid the heap lookup
CREATE INDEX idx_orders_user_summary ON orders (user_id) INCLUDE (status, total);

-- Composite: column order matters
CREATE INDEX idx_orders_user_status ON orders (user_id, status, created_at DESC);
```

Index what you query. Do not index what you cannot justify with a query pattern —
every index taxes writes.

## Query optimization

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.name, count(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id AND o.created_at > now() - interval '30 days'
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.name
HAVING count(o.id) > 5
ORDER BY order_count DESC;
```

Read the plan before and after. Common fixes: add the missing join/filter index,
use a partial index for the hot predicate, replace a correlated subquery with a
join or lateral, materialize an expensive aggregate, batch a large write.

Partition by time or tenant once a table passes roughly 100M rows.

## Agent-facing queries

Anything an agent or LLM can trigger gets bounded by construction:

- A default `LIMIT` on every exploratory query. No unbounded `SELECT`.
- Cursor pagination as the tool surface, so "get more" is an explicit next call.
- A statement timeout on the role the agent connects as.
- Read-only role unless the tool genuinely writes.

## Connections

- PgBouncer, or application-level pooling, in front of the database once more than
  one service or agent connects. Serverless drivers plus a connection-per-request
  will exhaust a Postgres instance quickly.
- In transaction pooling mode, session-level features (prepared statements,
  `SET`, advisory locks held across statements) do not survive. Design for it.

```sql
SELECT state, count(*) FROM pg_stat_activity GROUP BY state;

SELECT pid, now() - query_start AS duration, query
FROM pg_stat_activity
WHERE state = 'active' AND query_start < now() - interval '30 seconds'
ORDER BY duration DESC;

SELECT pg_cancel_backend(pid);     -- graceful
SELECT pg_terminate_backend(pid);  -- force
```

## Tooling

This skill carries no MCP server. Database access comes from the project: a
Postgres MCP server in the repo's `.mcp.json`, `psql`, or the platform's own
tooling. Point it at a **read-only role** unless the task genuinely writes, and
never at production without the 🔴 confirmation.

## Local environment

Postgres 16+ alpine images with healthchecks in compose. Dev-only tooling
(adminer, studio) goes behind a compose profile so it never starts in a real
deployment.

## Internals worth knowing

- **MVCC**: an `UPDATE` writes a new row version and leaves the old one dead.
  Long-running transactions hold the horizon back and stop dead tuples being
  reclaimed, so a forgotten idle-in-transaction session bloats tables it never
  touched.
- **Vacuum and bloat**: autovacuum reclaims dead tuples; it does not return disk
  to the OS. Watch `pg_stat_user_tables.n_dead_tup` and
  `last_autovacuum`. A table taking writes faster than autovacuum settings allow
  needs per-table `autovacuum_vacuum_scale_factor`, not a manual `VACUUM FULL`
  (which takes an ACCESS EXCLUSIVE lock and rewrites the table).
- **WAL and checkpoints**: every change is written to WAL first. Checkpoints
  flush dirty buffers; too-frequent ones cause write spikes, too-rare ones cause
  long recovery. WAL is also what streaming replication and PITR consume.
- **Isolation levels**: the default is READ COMMITTED, where each statement sees
  a fresh snapshot — so two statements in one transaction can disagree. Use
  REPEATABLE READ when a transaction must see one consistent snapshot throughout,
  and SERIALIZABLE when correctness depends on there being no concurrent
  interleaving. The latter two can abort with a serialization failure; the
  application must be prepared to retry.

## Roles and access

- The application never connects as a superuser or as the table owner. Give it a
  role with exactly the DML it needs, and keep DDL to the migration role.
- Separate roles per concern: migrations, application read/write, read-only
  analytics, agent/tooling access. That way a leaked credential has a blast
  radius you can describe.
- Grant on schemas and tables explicitly. Check `DEFAULT PRIVILEGES` so a table
  created by a later migration does not silently arrive without grants.
- Revoke `CREATE` on `public` from `PUBLIC`.

## Backups

Continuous WAL archiving for point-in-time recovery, plus regular `pg_dump`.
**Test the restore.** An untested backup is not a backup. Monitor replication lag.

## Don't

- Don't `SELECT *`
- Don't store money as float — `numeric` or integer cents
- Don't use `timestamp` without time zone — always `timestamptz`
- Don't use `serial` — `bigint GENERATED ALWAYS AS IDENTITY` or `uuid`
- Don't use `varchar(n)` without a real constraint — `text`
- Don't hold a transaction open longer than necessary
- Don't run ORM-generated migrations unread
- Don't reach for `TRUNCATE` when you mean `DELETE`: it ignores `WHERE`, fires no
  row triggers, and cannot be part of a partial rollback the way a `DELETE` can
- Don't run `UPDATE`/`DELETE` without a `WHERE`
