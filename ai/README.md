# ai

Claude Code configuration: global rules, skills, and agents.

The organising principle is **skills = knowledge, agents = isolation**.

A skill is a body of conventions. It costs a file read, it loads on demand, and
several can be loaded at once, so a feature touching Postgres, a Go API and a
Svelte page is one thread with three skills, not three agents handing work to
each other across a context boundary.

An agent is a separate context with its own tools. That is only worth paying for
when there is a real boundary: a live MCP connection that should not be ambient,
a tool posture that must stay isolated, or a permission set that must be smaller
than the main thread's.

## Layout

```
ai/
├── CLAUDE.md          # always loaded: philosophy, git, orchestration, language
├── skills/<name>/SKILL.md
├── agents/<name>.md
└── install.sh         # fallback for non-nix machines
```

## Skills

| Skill | Covers |
|---|---|
| `albttx-guideline` | Operating rules: verify before acting, security, quality gates, PR conventions |
| `go` | Go: layout, errors, tests, chi, database/sql, golangci-lint, CI split |
| `svelte` | SvelteKit 2 + Svelte 5 runes, Tailwind v4 CSS-first, i18n |
| `react` | Next.js App Router, React 19, RSC boundary, Tailwind v4 CSS-first |
| `nodejs` | Bun/Node, workspaces, Zod, Drizzle, pino, serverless |
| `postgres` | Versioned SQL migrations, RLS, pgvector, indexing, pooling |
| `nix` | Flakes, home-manager, overlays, derivations |
| `cosmos` | Cosmos SDK, CometBFT, IBC, gno.land, AtomOne, validator ops |
| `docs` | READMEs, ADRs, runbooks, changelogs, FR/EN, em-dash ban |
| `seo` | Technical SEO, JSON-LD, Core Web Vitals, sitemaps |
| `agentcash` | MPPScan / x402Scan registration API discovery |

## Agents

| Agent | Why it is an agent and not a skill |
|---|---|
| `devops-specialist` | Holds the Terraform and Vault MCP servers. Vault reads and writes secrets; that capability should not be ambient in every session. |
| `osint-specialist` | Isolated tool posture and very noisy output that should not fill the main context. |
| `reviewer` | Cannot edit files. A reviewer that can rewrite the diff it is judging is not a reviewer. See the caveat below. |

### Reviewer enforcement, a known gap

`reviewer` has `tools: Read, Grep, Glob, Bash` plus
`disallowedTools: Write, Edit, NotebookEdit`, so it cannot edit files. But it
needs `Bash` for `git diff`, and **agent frontmatter cannot restrict individual
bash commands**. Its "never run `git commit`" rule is prose, not enforcement.

If that gap matters, close it in `~/.claude/settings.json` with deny rules:

```json
{
  "permissions": {
    "deny": [
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(gh pr merge:*)"
    ]
  }
}
```

Left undone for now, on the principle that complexity waits for a concrete
reason. The prose constraint is honoured in practice; add the deny rules the
first time it is not.

There is deliberately no orchestrator agent. Sub-agents cannot spawn sub-agents,
so an orchestrator sub-agent could never delegate. The orchestration rules live
in `CLAUDE.md` and apply to the main thread, which *can* delegate.

## Deployment

On nix machines this is declarative. `modules/dev/ai/claude-config.nix`
symlinks `ai/` into `~/.claude`:

```nix
home.file.".claude/CLAUDE.md".source = ../../../ai/CLAUDE.md;
home.file.".claude/skills" = { source = ../../../ai/skills; recursive = true; };
home.file.".claude/agents" = { source = ../../../ai/agents; recursive = true; };
```

`recursive = true` links each file individually, so `~/.claude` stays writable
for Claude Code's own state and unrelated skills installed there survive.

Apply with `make switch`.

**One-time cleanup.** home-manager links alongside existing files, it does not
remove them, so anything the old `agents/install.sh` copied into `~/.claude`
survives the switch. Those stale agents carry guidance these skills reverse.
Clear them once with the installer, which prunes exactly that set and nothing
else:

```sh
./ai/install.sh --dry-run   # lists what it would prune
./ai/install.sh
```

On a machine without home-manager:

```sh
./ai/install.sh --dry-run   # show what would change
./ai/install.sh
```

## Adding a skill

```sh
mkdir -p ai/skills/<name>
```

`ai/skills/<name>/SKILL.md` needs exactly two frontmatter keys:

```markdown
---
name: <name>
description: <when this knowledge applies: the trigger, not the summary>
---
```

`name` must match the directory. The `description` is what selects the skill, so
write it as a trigger: which file types, which tasks, which tools.

No `model`, `color`, or `memory`. Those are agent concepts.
