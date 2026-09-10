# albttx — global rules

Always loaded. Domain conventions live in skills; this file is the part that
applies everywhere.

## Language

Respond in the language I write in. If I write French, answer in French.

**Code is always English**: identifiers, comments, commit messages, log messages,
error strings, branch names. No exceptions, regardless of the conversation
language or the product's UI language.

Product copy follows its audience. Personal and family-facing products are
French-facing; consulting, open source and infrastructure work is English. Some
repos are bilingual with full parity. Check the repo before writing a user-facing
string.

**No em-dashes in prose that gets published.** Use a comma, a colon, or a full
stop. This covers READMEs, landing copy, marketing pages, blog posts and
changelogs, in English and in French. Some repos enforce it in CI.

## Philosophy

**KISS above all.** Prefer simple, readable solutions over clever abstractions.
Flat beats nested. A smaller correct change beats a larger uncertain one.

**Defer complexity until it is earned.** No external service, no abstraction, no
offshore-grade architecture until there is a concrete reason. Ship the minimal
correct path first; retries, backoff, admin UIs, caching layers and queues wait
for the problem that justifies them. Prefer one system doing two jobs adequately
over two systems doing one job each. When a new dependency is proposed, the
question is not "is it good" but "what does keeping this inside the system we
already run cost us instead".

**Rule of three.** Extract a component, a helper or an interface on actual
repetition, not in anticipation of it.

**Load context thoroughly before proposing a solution.** Read the code, the
lockfile, the config and the existing conventions first. A proposal built on an
assumption about the stack is worse than no proposal.

**Answer at implementation depth.** For anything non-trivial I want a structured,
layered breakdown — capture, storage, retrieval, maintenance — with concrete
schema, types and code alongside the recommendation. High-level advice with no
implementation specifics is not an answer.

**Flag conflicts, do not resolve them silently.** If what I asked for contradicts
best practice, or the local evidence contradicts a stated preference: implement
what I asked, name the conflict, propose the better path.

## Git

Conventional Commits by default:

```
type(scope): description
```

- Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `ci`, `perf`
- Imperative, lowercase after the colon, no trailing period
- Scope is the domain or module (`feat(memory):`, `fix(ipad-box):`), not a file path
- Breaking change: `!` after the scope plus a `BREAKING CHANGE:` footer
- Body wrapped around 72 columns, explaining **why**, including alternatives rejected
- Ticket reference where the repo uses one: `(ALB-1207)` or `[ALB-1207]`

**Match the repo, not the rule.** Some repos deliberately use a different house
style. Read the last twenty commits before writing the first one.

Branch from the default branch: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`.
Fast-forward to `origin/main` **before** starting work or briefing an agent — a
stale base silently invalidates everything built on it.

Respect the repo's merge path. Where a repo merges only through a script or a
lock, using the GitHub UI breaks an invariant on purpose-built tooling.

### Secrets

**Never commit a secret.** Not in code, not in a config, not in a test fixture,
not in a comment, not in a log line.

- `.env.example` is always committed, with every key present and no real value
- Real values come from 1Password (`op://` references) or Vault
- A secret found in a file gets masked as `***`, flagged, and rotated before the
  original task continues

## Quality gates

A task is not done until the project's linter, formatter, type checker and
relevant tests have run and passed, config files validate, and `shellcheck` is
clean on any shell script. If a gate fails, fix it — do not ask whether to.

Distinguish a red gate caused by the change from a red gate that is **stale**. If
the remediation post-dates the run, re-run rather than patch.

Verify claims against reality: a deployed artifact may predate the fix, an
authenticated fetch does not prove public reachability, and an alert path that
has never fired successfully is not an alert path.

## How work gets done

**Work in the main thread by default.** Load skills; do not spawn agents.

Skills are knowledge — they cost a file read and they compose. A cross-stack
feature that touches Postgres, a Go API and a Svelte page is **one** thread with
three skills loaded, not three agents. Splitting it across agents loses the type
contracts, the naming, and the integration at the boundaries, which is exactly
the part that is hard.

Delegate only where there is a real boundary:

| Agent | The boundary |
|---|---|
| `devops-specialist` | Holds the Terraform and Vault MCP connections. Vault reads and writes secrets; that should not be ambient. |
| `osint-specialist` | Isolated tool posture and very noisy output that should not fill the main context. |
| `reviewer` | Cannot edit files: no Write, no Edit. A reviewer that can rewrite the diff it is judging is not a reviewer. It keeps `Bash` for `git diff`, so the no-mutating-commands rule is prose, not enforcement. |

Everything else is a skill.

A read-only fan-out over many files — mapping a subsystem, sweeping for a pattern
across repos — is also worth delegating, because the point is to keep the file
dumps out of the main context and get back only the conclusion.

### When you do delegate

- Give a self-contained brief: what to do, the constraints, how it connects to the
  rest, and the shared conventions (naming, file layout, API contract)
- Define the interface **before** anyone starts building against it
- Run independent work in parallel, dependent work in sequence
- Review what comes back for consistency and integration correctness, not just
  whether the task was done
- Surface a blocker immediately rather than working around it quietly

### Planning

For any multi-step task, show a concise plan first: what will be read, what will
change, what will run. For destructive operations, list exactly what is affected
and wait for confirmation before apply, destroy, delete, revoke, rotate, or any
production change.

Production operations get a 🔴 prefix and explicit confirmation.

### After a task

- ✅ What was done
- 📖 What was verified, with sources
- ⚠️ Anything that felt like a workaround, or has a better long-term fix
- → Follow-ups

Keep it short. No recap of every command.

## Verify before you write

Never trust training data for API argument names, CLI flags, default values, or
deprecation status. Read the version from the lockfile or `go.mod`, then read the
docs for **that** version. This matters most on the fast-moving surfaces:
Next.js majors, Svelte 5, Tailwind v4, Bun, Cosmos SDK.

Note the source: `📖 Verified: [source] — [what was confirmed]`. If the docs are
unavailable or ambiguous, say so. Do not guess silently.

## Repo-local instructions win

A repo's own `CLAUDE.md` or `AGENTS.md` overrides everything here on conflict.
Read it before starting.

Several of my repos also keep `.claude/agent-memory/<namespace>/MEMORY.md`: an
index of hard-won project notes. The namespaces were named after the old
per-technology agents (`go`, `postgres`, `nodejs`, `svelte-frontend-dev`,
`react-frontend-dev`, `devops`, `docs`, `nix`), which no longer exist as agents.
Map the namespace to the **skill** covering the same ground and read the index
for whatever the task touches — `react-frontend-dev/` is the frontend memory for
a React repo whether or not an agent by that name is running. When a repo has
several, read the ones matching the files you are about to change.
