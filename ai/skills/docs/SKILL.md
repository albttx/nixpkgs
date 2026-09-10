---
name: docs
description: Conventions for technical writing — READMEs, ADRs, API docs, onboarding guides, runbooks, changelogs, and inline code documentation. Use when writing or maintaining any .md documentation, an OpenAPI spec, or a changelog.
---

# Documentation

Clear, concise, well-structured docs that developers actually read. Good docs
reduce support burden, speed up onboarding, and act as a single source of truth.

## Voice

- Sharp, punchy, concise. Skip fluff, lead with what matters.
- **No em-dashes in prose that gets published.** Use a comma, a colon, or a full
  stop. This applies to READMEs, landing copy, blog posts, changelogs, and PR
  descriptions.
- Active voice: "Run the migration", not "The migration should be run".
- One idea per paragraph. Short sentences, but never at the cost of clarity.
- Define acronyms on first use. Bold key terms on first appearance.

## Language: FR / EN

Match the language of the repo and its audience, not the language of the request.

- Personal / family-facing products are French-facing (niles.family is French).
- Consulting, open source, and infrastructure work is English.
- Code, identifiers, and code comments are **always English**, regardless of the
  surrounding doc language.
- Never mix languages inside a single document. If a repo has both, keep them in
  separate files (`README.md` / `README.fr.md`), not interleaved.

## Accuracy over completeness

Document 5 things correctly rather than 20 things vaguely. Read the code before
documenting it. Never guess at behaviour.

## Document types

### README

```markdown
# Project Name

One-line description of what this does.

## Quick Start

Minimal steps to get running. Code block, not prose.

## Usage

Core workflows with examples.

## Configuration

Table of env vars / config options with types and defaults.

## Development

How to set up, test, and contribute.

## Architecture

Brief overview with pointers to deeper docs if needed.
```

- Lead with what the reader needs most: what is it, how do I use it.
- Quick Start must be copy-pasteable and actually work.
- No table of contents on a short README. It adds noise.

### ADR (Architecture Decision Record)

```markdown
# ADR-NNN: Title

## Status
Accepted | Superseded by ADR-NNN | Deprecated

## Context
What problem are we solving? What constraints exist?

## Decision
What did we decide and why?

## Consequences
What are the trade-offs? What do we gain and lose?
```

- One decision per ADR.
- Write the context as if the reader has no prior knowledge.
- Be honest about trade-offs. An ADR with no downsides listed is not finished.

### API documentation

- Document every public endpoint: method, path, params, body, response, errors.
- Include curl examples.
- Group by resource, not by HTTP method.
- Document auth requirements upfront.
- Version the docs alongside the API.

### Runbooks

- Numbered, step-by-step.
- Include expected output at each step.
- Troubleshooting section for common failures.
- Link to dashboards, logs, and alert definitions.
- Assume the reader is stressed at 3am. Be explicit, not clever.

### Changelogs

- Keep a Changelog format: Added, Changed, Deprecated, Removed, Fixed, Security.
- Write entries for humans, not a `git log` dump.
- Link to PRs/issues where relevant.
- Group by version with dates.

## Structure for scanning

Readers scan, they do not read top to bottom.

- Headings, bullets, tables, code blocks.
- Most important information first (inverted pyramid).
- Tables for anything comparative (config options, env vars, commands).

## Code examples are documentation

- Every concept gets a working example.
- Examples must be copy-pasteable and actually run.
- Show the output when it aids understanding.
- Use realistic values, never `foo`/`bar`/`baz`.

## Keep it maintainable

- Link to source instead of duplicating it.
- Relative links within the repo.
- Avoid hardcoding version numbers that will drift.
- Prefer generated docs (from types, schemas, OpenAPI) over hand-written.

## Scope

Documentation work reads code, it does not rewrite it. When docs reveal missing
functionality, unclear APIs, or inconsistencies: flag it, suggest what the code
should expose, and fix it as a separate change rather than smuggling behaviour
changes into a docs commit.

Directly in scope to write and edit: Markdown, plain text, changelogs, licenses,
OpenAPI/Swagger specs, GoDoc/JSDoc comments on existing code, config examples
and templates.

## Don't

- Don't document implementation details that churn — document behaviour and contracts
- Don't write walls of text
- Don't use marketing language in technical docs
- Don't assume the reader knows the project history
- Don't duplicate what the code already says clearly
- Don't ship a concept with no code example
- Don't write docs without reading the code first
