---
name: go
description: Conventions for Go work — APIs, CLIs, middleware, gRPC, concurrency, database access, testing, linting and module layout. Use for any .go file, go.mod/go.sum, .golangci.yml, protobuf for a Go service, or Go tooling and CI.
---

# Go

Idiomatic, stdlib-first Go. Simplicity, explicit error handling, and "a little
copying is better than a little dependency".

## Toolchain

- Go 1.25+ (`go-version-file: go.mod` in CI, never a hardcoded version)
- Format with **gofumpt** locally. CI gates on `gofmt -l .` — gofumpt output is
  always gofmt-clean, so both hold at once.
- `golangci-lint` with an explicit allow-list, not the default set. Canonical config:

  ```yaml
  version: "2"
  linters:
    default: none
    enable:
      - errcheck
      - govet
      - ineffassign
      - misspell
      - staticcheck
      - unused
  ```

  Pin the golangci-lint action version and say why in a comment — the default
  linter set drifts between releases.
- `go mod tidy` discipline. Keep the direct dependency list short enough to read.

## CI layout

Split workflows by concern rather than one mega-workflow:

- `lint.yml` — `gofmt -l .` gate + `go vet ./...` + golangci-lint
- `tests.yml` — `go test -race -cover ./...`, matrix over ubuntu + macos
- `release.yml` — goreleaser (`CGO_ENABLED=0`, linux/darwin × amd64/arm64,
  `-ldflags="-s -w -X main.version=..."`)

Use `concurrency: cancel-in-progress` so pushes don't queue.

## Project layout

```
cmd/
  mytool/main.go       # thin: wire deps, start, handle signals
internal/              # private packages
  cli/
  config/
  store/
pkg/                   # only when genuinely reusable outside this module
```

- `cmd/` for entry points. `main.go` stays thin.
- `internal/` by default. Promote a package to `pkg/` only once it is actually
  consumed from outside, and do it as an explicit refactor commit.
- **`pkg/` must never import `internal/`.**
- Give reusable packages a `doc.go` with a short usage example.
- Exception: framework plugins that must expose their entry point at the module
  root (Traefik/yaegi plugins) stay flat — `plugin.go` at root, helpers in `internal/`.

## Errors

```go
// Wrap with a lowercase verb phrase describing what was being attempted
if err := db.QueryRowContext(ctx, query, id).Scan(&user); err != nil {
    return fmt.Errorf("get user %d: %w", id, err)
}

// Sentinel errors only where a caller actually branches on them
var ErrNotFound = errors.New("no matching project")
return fmt.Errorf("%w for %q", ErrNotFound, term)   // matched with errors.Is

// Custom error types when the caller needs structured detail
type ValidationError struct {
    Field   string
    Message string
}
func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation: %s: %s", e.Field, e.Message)
}
```

- `fmt.Errorf("doing X: %w", err)` — lowercase, no trailing punctuation, describes
  the action not the failure. `"parse %s: %w"`, `"rename temp state file into place: %w"`.
- `errors.New` for static messages. In library packages, prefix with the package
  name: `errors.New("x402: payTo is required")`.
- `errors.Is` for sentinels, `errors.As` for typed errors carrying detail
  (retry-after, status codes).
- Never ignore an error with `_` unless there is a documented reason.

## Testing

Stdlib `testing` only. **testify is not used** — do not introduce it.

```go
func TestParseConfig(t *testing.T) {
    t.Parallel()
    tests := []struct {
        name    string
        input   string
        want    Config
        wantErr bool
    }{
        {name: "valid config parses", input: `{"port": 8080}`, want: Config{Port: 8080}},
        {name: "empty input is rejected", input: "", wantErr: true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            got, err := ParseConfig([]byte(tt.input))
            if (err != nil) != tt.wantErr {
                t.Fatalf("ParseConfig() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !tt.wantErr && got != tt.want {
                t.Errorf("ParseConfig() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

- `t.Parallel()` at the top level **and** inside every subtest.
- Case names are descriptive sentences, not identifiers:
  `"already on disk: no clone, still ensures and attaches"`.
- `t.Helper()` in every assertion/fixture helper.
- Golden files in `testdata/*.golden` for anything with formatted output.
- Always `-race`. E2E tests may skip on a missing env var but must still compile in CI.

## HTTP

Reach for `net/http` first. Go 1.22+ `ServeMux` handles method and path patterns
(`mux.HandleFunc("GET /users/{id}", ...)`) and covers most services.

When a router is genuinely needed, use **chi** — it is `http.Handler` all the way
down, so handlers stay `func(w http.ResponseWriter, r *http.Request)` and middleware
stays standard. Never `gin`. Do not introduce a framework that replaces the stdlib
handler signature.

```go
r := chi.NewRouter()
r.Use(middleware.RequestID, middleware.Recoverer)

r.Route("/api/users", func(r chi.Router) {
    r.Get("/{id}", handleGetUser)
    r.Post("/", handleCreateUser)
})
```

Middleware is a plain `func(http.Handler) http.Handler`.

## Database

Stdlib-first: `database/sql` with a driver, or `pgx` when Postgres-specific
features earn it. No ORM.

- Always the `Context` variants: `QueryContext`, `QueryRowContext`, `ExecContext`.
  Propagate `ctx` from the handler down to the query, every time.
- Clean separation: **Store → service → handler**. The store owns SQL, the service
  owns business rules, the handler owns HTTP. Handlers never contain SQL.
- Define the store interface at the consumer (the service), narrow — only the
  methods actually used — so tests inject a fake instead of a database.
- Transactions with the defer-rollback pattern:

  ```go
  tx, err := db.BeginTx(ctx, nil)
  if err != nil {
      return fmt.Errorf("begin tx: %w", err)
  }
  defer tx.Rollback() //nolint:errcheck // no-op after Commit
  // ... work ...
  return tx.Commit()
  ```

### Migrations and query generation

- Migrations are versioned SQL files in the repo, applied by CI or a dedicated
  job. **`goose`** is the default runner: plain `.sql` files with `-- +goose Up`
  and `-- +goose Down` sections, embedded via `embed.FS` and applied from a
  dedicated `cmd/migrate` entry point or a CI step. `golang-migrate` is
  acceptable where it is already in place. Write the `Down` section even when you
  expect never to run it: writing it is what surfaces an irreversible migration
  while it is still cheap to redesign.
- **`sqlc`** generates type-safe Go from the same SQL. It is not an ORM: you
  write the query, it writes the struct and the method. Prefer it over
  hand-rolled `Scan` boilerplate on anything with more than a handful of queries.
  The `No ORM` rule below is about GORM-style runtime query builders, not sqlc.
- **`pgxpool`** for Postgres connections, always. Never a single `pgx.Conn` in a
  service — one connection serialises every request behind it.

See the `postgres` skill for schema, indexing and migration-safety detail.

## Concurrency

```go
// Context propagation everywhere
func (s *Service) Process(ctx context.Context, items []Item) error {
    g, ctx := errgroup.WithContext(ctx)
    for _, item := range items {
        g.Go(func() error {
            return s.processItem(ctx, item)
        })
    }
    return g.Wait()
}

// Graceful shutdown
ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
defer stop()
```

A mutex is often simpler than a channel. Use the one that makes the code readable.

## Libraries

Short list, reached for only when the stdlib genuinely falls short:

- **CLI**: `urfave/cli/v3`, or `spf13/cobra` when the command tree is large
- **TUI**: the Charm stack (`bubbletea`, `bubbles`, `huh`)
- **Config**: `BurntSushi/toml` or `gopkg.in/yaml.v3`. Note the TOML/YAML
  zero-value trap: use `*bool` when "unset" must differ from "false".
- **Logging**: `slog` (stdlib)
- **Postgres**: `pgx` + `pgxpool`; `sqlc` for query codegen; `goose` for migrations
- **gRPC**: `google.golang.org/grpc` + `buf`
- **Validation**: hand-written validators, or `go-playground/validator` when the
  struct-tag style earns its keep
- **Integration tests**: `testcontainers-go` for a real Postgres per test run
- **Concurrency**: `golang.org/x/sync/errgroup`

## Interfaces

Program to interfaces where there is a real seam. Define them at the **consumer**,
keep them narrow, inject dependencies via constructor args so tests can pass fakes.
Do not add an interface speculatively.

## Don't

- Don't use `init()` — it hides dependencies and breaks testability
- Don't use package-level mutable state or global singletons
- Don't use `any` where a concrete type or a generic works
- Don't define interfaces at the provider side
- Don't `panic` for expected error conditions
- Don't import a framework when the stdlib suffices
- Don't use an ORM (GORM and friends). `sqlc` is not an ORM: it generates code
  from SQL you wrote, it does not build queries at runtime.
- Don't create `utils` or `helpers` packages — name a package for what it provides
