---
name: nodejs
description: Conventions for Node.js/Bun/TypeScript backend work — APIs, serverless and edge functions, workspaces, Zod validation, Drizzle, logging and testing. Use for any backend .ts/.js file, package.json, workspace config, serverless handler, or npm/yarn/bun dependency work.
---

# Node.js / Bun / TypeScript

Fast, type-safe backend services. Lean, dependency-conscious, strict TypeScript.

## TypeScript

`strict: true` everywhere. No `any` — use `unknown` and narrow. Model domains with
discriminated unions, generics and utility types rather than optional-everything
interfaces.

## Async semantics

The event loop is not an implementation detail you get to ignore.

- **Microtasks starve macrotasks.** A promise chain that never yields keeps
  timers and I/O callbacks waiting. Break long synchronous work with
  `await setImmediate()` or move it off-thread.
- **`Promise.all` vs `Promise.allSettled`**: `all` rejects on the first failure
  and abandons the rest (they still run, their results are discarded, their
  rejections become unhandled). Use `allSettled` when every result matters, and
  `all` only when one failure genuinely invalidates the batch.
- **`AbortController`** is the cancellation primitive. Thread a signal through
  `fetch`, stream reads and timers so a dropped client stops the work behind it.
  A request handler with no signal propagation keeps burning after the socket closes.
- **Streams over buffering.** `for await (const chunk of stream)` and
  `pipeline()` from `node:stream/promises`, which propagates errors and cleans up
  — a raw `.pipe()` chain leaks on error.
- **Error propagation**: an `async` function passed where a sync callback is
  expected returns a floating promise and its rejection escapes the try/catch
  around it. Await it or attach a handler; never leave one dangling.
- Concurrency needs a bound. Mapping `Promise.all` over a thousand items opens a
  thousand connections. Use a small pool or chunk the work.

## Runtime and package manager

- **Bun** for new projects: native TypeScript, fast test runner, built-in bundler,
  `Bun.serve()`. Pin the Bun version in `package.json` (`"packageManager"` or an
  explicit `bun@x.y.z`) — a minor Bun bump has broken installs before.
- **Node.js** when ecosystem compatibility matters. Node 22+ ships `fetch`,
  `test`, `parseArgs`, `Blob`, `FormData` — do not install packages for those.

**The lockfile decides the package manager, not preference.** Existing projects
legitimately use npm workspaces, yarn, or bun workspaces. Check for `bun.lock`,
`yarn.lock`, `pnpm-lock.yaml` or `package-lock.json` and use that one. Never mix
two in a repo; if a repo has two lockfiles, that is a bug to raise, not a choice
to make silently.

## Workspaces

Default to a workspace layout for anything that might grow a second deployable:

```
apps/
  web/                  # frontend
  admin/                # separate frontend, separate audience
  api/                  # backend service
packages/
  db/                   # schema + client
  shared/               # types, validators
  config/               # tsconfig, eslint
```

- `apps/` for deployables, `packages/` for shared internal libraries.
- Each package has its own `package.json` with a proper `exports` field.
- Workspace references: `"@repo/shared": "workspace:*"`.
- Zod schemas and shared types live in `packages/` so frontend and backend import
  one source of truth.
- Turborepo for task orchestration once the graph is non-trivial.

Adapt to the existing structure. A flat repo stays flat — do not migrate a
working layout as a side effect of another task.

## Validation with Zod

Schema is the single source of truth; derive types from it, not the reverse.

```typescript
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(100),
  email: z.string().email(),
  role: z.enum(["admin", "user"]),
  createdAt: z.coerce.date(),
});

type User = z.infer<typeof UserSchema>;

const CreateUserSchema = UserSchema.omit({ id: true, createdAt: true });
const UpdateUserSchema = CreateUserSchema.partial();
```

Validate at every trust boundary: request bodies, query params, env vars,
third-party API responses.

## HTTP

Hono when a framework is warranted — it runs on Bun, Node, Vercel and Cloudflare
unchanged.

```typescript
import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";

const app = new Hono();

app.post("/users", zValidator("json", CreateUserSchema), async (c) => {
  const data = c.req.valid("json");
  const user = await userService.create(data);
  return c.json(user, 201);
});
```

In a SvelteKit or Next.js app, the framework's own route handlers are the HTTP
layer. Do not mount a second framework inside one.

## Errors

```typescript
class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public code?: string,
  ) {
    super(message);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(404, `${resource} ${id} not found`, "NOT_FOUND");
  }
}

app.onError((err, c) => {
  if (err instanceof AppError) {
    return c.json({ error: err.message, code: err.code }, err.statusCode);
  }
  log.error({ err }, "unhandled error");
  return c.json({ error: "Internal server error" }, 500);
});
```

Handled errors carry a status and a stable machine code. Unhandled ones get
logged with the error under the `err` key and answered with a generic 500 — never
leak an internal message to a client.

## Logging

**`console.*` is banned in application source.** Use `pino` through a small
factory:

```typescript
const log = createLogger("chat:session");

log.info({ familyId, messageCount }, "session resumed");
log.error({ err, familyId }, "session resume failed");
```

- Structured object first, message string second. This is pino's argument order
  and getting it backwards silently drops the fields.
- Errors always under the `err` key so the serializer picks them up.
- Levels: `debug` for traces, `info` for lifecycle, `warn` for recoverable,
  `error` for failures. `LOG_LEVEL` controls the floor.
- Tag a request id in the server hook and let it flow through child loggers.
- Configure redaction for secret-shaped keys rather than remembering not to log them.

Seed and one-off scripts may use `console` — mark them as the exception.

## Database

Postgres. Two shapes are in use and both are legitimate; **follow the repo**:

1. **Drizzle query builder** as the runtime API. Import the client from a single
   server-only module. Raw SQL only in migrations.
2. **Drizzle for schema and migration generation only**, with runtime queries as
   tagged-template SQL against a serverless driver. This keeps hand-written JOINs
   and avoids the builder in hot paths.

Either way:

- Migrations are versioned SQL files committed to the repo alongside the schema
  change. Generate, **read the generated SQL**, commit both, then apply.
- Drizzle owns its own migration numbering through `meta/_journal.json`. Never
  hand-renumber a generated migration; if two branches collide in the journal,
  regenerate rather than patch.
- `db:push` is a local-development convenience. It is banned against staging and
  production.
- CI gates on migration state: a drift check and a migrate step, not trust.
- Never access the database from client code.
- Check plan/tenant limits before creating a resource, not after.
- Encrypt third-party integration credentials at rest.

See the `postgres` skill for schema and migration detail.

## Serverless / edge

```typescript
export const config = { runtime: "edge" };

export default async function handler(req: Request): Promise<Response> {
  const id = new URL(req.url).searchParams.get("id");
  if (!id) return Response.json({ error: "Missing id" }, { status: 400 });

  const data = await fetchData(id);
  return Response.json(data, {
    headers: { "Cache-Control": "s-maxage=60, stale-while-revalidate" },
  });
}
```

Cron and webhook endpoints authenticate themselves: validate
`Authorization: Bearer $CRON_SECRET` before any work. Give a scheduled job its
own endpoint rather than adding a query flag to a user-facing one.

## Testing

`bun:test` on Bun, `vitest` on Node. Colocate tests with the code they cover.

```typescript
import { describe, expect, it } from "bun:test";

describe("UserService", () => {
  it("creates a user", async () => {
    const user = await userService.create({ name: "Test", email: "test@example.com" });
    expect(user.id).toBeDefined();
  });

  it("rejects a duplicate email", async () => {
    await expect(
      userService.create({ name: "Dupe", email: "test@example.com" }),
    ).rejects.toThrow("already exists");
  });
});
```

Integration tests hit a real database, not a mock. A mocked database passes while
the migration that would have broken production goes unnoticed.

## Libraries

- **HTTP**: `hono`; `fastify` for Node-specific perf; `express` only for legacy
- **Validation**: `zod`, for everything
- **Database**: `drizzle-orm`; `@neondatabase/serverless` or `postgres` for direct SQL
- **Auth**: `better-auth`, or the platform's own (Supabase auth + RLS)
- **Logging**: `pino`
- **Queues**: `pg-boss` (Postgres-backed) before reaching for Redis + `bullmq`
- **WebSocket**: Bun's native WebSocket, Hono's helper, or `ws` on plain Node
- **HTTP testing**: `supertest`, or plain `fetch` against the app's handler
- **SQLite**: `bun:sqlite` on Bun, `node:sqlite` on Node 22+ — not a dependency
- **CLI**: `commander`, or Node's `parseArgs`
- **Config**: TOML/YAML with `*`-nullable fields where "unset" must differ from
  the zero value

## Don't

- Don't use `any`, `var`, or callbacks where async/await works
- Don't use `moment` — `date-fns`, `Temporal`, or `Intl.DateTimeFormat`
- Don't install a package for a trivial operation (lodash for `_.get`, axios for `fetch`)
- Don't use default exports
- Don't reach for a `class` where a function and a plain object do the job
- Don't nest promises
- Don't ignore a rejection
- Don't mix package managers
- Don't call `console.*` in application code
