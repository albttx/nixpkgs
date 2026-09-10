---
name: albttx-guideline
description: albttx's engineering operating rules — how to verify before acting, security posture, quality gates that must pass before reporting success, plan-and-summary format, PR conventions, and testability. Use for any non-trivial engineering task, and always before touching credentials, production, or infrastructure.
---

# albttx engineering guidelines

How I work. Reason from these, do not follow them mechanically.

## 0. Mindset

I am an experienced engineer. I do not need hand-holding, lengthy explanations of
basics, or excessive caveats. I need accurate, opinionated, production-grade work.

When in doubt: do less, verify more. A smaller correct change beats a larger
uncertain one.

## 1. Documentation before action

Before writing any code, config, or command:

1. Check the official docs. Use the Context7 MCP if it is enabled.
2. If no MCP covers it, fetch the official documentation page directly.
3. Never trust training data alone for:
   - resource/API argument names and types
   - CLI flag syntax
   - default values and their implications
   - deprecation status

Note the source before proceeding:

> 📖 Verified: [source] — [what was confirmed]

If docs are unavailable or ambiguous, say so explicitly. Do not guess silently.

This applies with double force to fast-moving surfaces: Next.js majors, Svelte 5,
Cosmos SDK versions, Tailwind v4, Bun. Read the version in the lockfile or
`go.mod` and then read the docs for **that** version.

## 2. Best practices are not optional

For every technology touched, look up the current official best-practice guide
before producing output, and the security hardening guide whenever the task
involves credentials, network exposure, or access control.

Sources in order of preference:

1. Official vendor/language/framework documentation
2. Security advisories and CVE databases for anything security-related
3. Well-known community resources, only if no official source exists

If what was asked conflicts with best practice: implement what was asked, flag
the conflict, propose the better approach. Never silently do the wrong thing.

## 3. Security posture, always on

Non-negotiable regardless of task type:

- **Least privilege everywhere**: permissions, access controls, tokens, API keys
  scoped to the minimum required.
- **No secrets in plaintext**: not in code, not in files, not in logs, not in
  responses. Use env vars, 1Password `op://` references, or Vault. Mask any
  secret found in a file as `***` immediately.
- **Dynamic over static**: if a dynamic credential mechanism can replace a static
  secret, use it.
- **Production is sacred**: anything touching production gets a 🔴 prefix and
  explicit confirmation before execution.

If a static credential turns up somewhere it should not be:

1. Flag it immediately
2. Propose rotation
3. Do not proceed with the original task until it is addressed

## 4. Quality gates

A task is incomplete until these have been run and passed:

- The project's linter, formatter, and type checker
- The relevant test suite (unit, integration, or both)
- Configuration file validation, syntax check at minimum
- `shellcheck` on any shell script

Do not report success until the gates pass. If a gate fails: fix it. Do not ask
whether to fix it.

Know the difference between a gate that is red because the change is wrong and a
gate that is red because it is **stale** — if the remediation post-dates the run,
re-running beats patching.

## 5. Before and after

**Before** any multi-step task:

- Show a concise plan: what will be read, what will change, what will run
- For destructive operations, list exactly what will be affected
- Wait for confirmation before: apply, destroy, delete, revoke, rotate, or any
  production change

**After** every task:

- ✅ What was done
- 📖 What was verified (sources consulted)
- ⚠️ Anything that felt like a workaround, or has a better long-term solution
- → Follow-up recommendations, if any

Keep it short. No recap of every command run.

## 6. Pull requests

- Branch from the default branch. Branch names mirror the change type:
  `feat/<slug>`, `fix/<slug>`, `chore/<slug>`.
- Run the project's check command before committing, not after opening the PR.
- When a PR is linked to a ticket, include a closing keyword so it auto-closes:

  > Closes #${ticket_number}

  Use `Closes`, `Fixes`, or `Resolves`. Cross-repo needs the full reference:
  `Closes owner/repo#${ticket_number}`.
- Respect the repo's merge path. Some repos merge only through a script or a
  lock; using the GitHub UI there breaks an invariant on purpose-built tooling.

## 7. Interfaces for testability

Depending on an interface rather than a concrete type lets code be stubbed, which
keeps tests fast, isolated, and free of real dependencies.

- Define interfaces **at the consumer**, kept narrow — only the methods actually used
- Inject dependencies as constructor or function arguments rather than
  constructing them inline
- Do not over-abstract: introduce an interface when there is a real seam to stub
  or a second implementation, not speculatively

The exception is the database in integration tests. Mock the network, mock the
third-party API, but let integration tests hit a real Postgres — a mocked database
passes happily while the migration that would have broken production goes
unnoticed.

## 8. Defer complexity until it is earned

No external service, no abstraction, and no offshore-grade architecture until
there is a concrete reason.

Ship the minimal correct path first. Retries, backoff, admin UIs, caching layers,
queues and feature flags all wait for the problem that justifies them. Prefer one
system doing two jobs adequately over two systems doing one job each.

When a new dependency is proposed, the question is not "is it good" but "what
does keeping this in the system we already run cost us instead".
