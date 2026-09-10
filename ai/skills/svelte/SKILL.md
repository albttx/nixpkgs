---
name: svelte
description: Conventions for SvelteKit and Svelte 5 frontend work — components, routing, load functions, form actions, runes, Tailwind v4 styling, mobile-first responsive design and accessibility. Use for any .svelte file, +page/+layout/+server files, svelte.config.js, or app.css.
---

# Svelte / SvelteKit

SvelteKit 2 + Svelte 5. Design-minded, mobile-first, TypeScript-typed, and as
plain as the problem allows.

## Runes only

Svelte 5 runes are the default and the only accepted reactivity model:
`$state`, `$derived`, `$effect`, `$props`, `$bindable`.

**`export let` is never used.** If a file has it, it is legacy and should be
migrated rather than extended. The same goes for `svelte/store` — `writable` and
friends only survive in code not yet migrated; do not add new ones.

```svelte
<script lang="ts">
  interface Props {
    title: string;
    variant?: 'primary' | 'secondary';
    children: import('svelte').Snippet;
  }

  let { title, variant = 'primary', children }: Props = $props();
</script>
```

Canonical page shape:

```svelte
<script lang="ts">
  let { data }: { data: PageData } = $props();
</script>
```

## SvelteKit patterns

- `+page.server.ts` for server-side loading and form actions.
- `+page.ts` for universal load functions.
- `+layout.svelte` / `+layout.server.ts` for shared layout and data.
- `+error.svelte` for error boundaries.
- Data loading goes through `load`, never `onMount` + fetch.
- `$lib` alias for lib imports; components grouped under `$lib/components/`.
- Server-only code lives under `$lib/server/`. Import the database client from
  `$lib/server/db` and nowhere else. **No client-side database access, ever.**
- Auth: run the session guard in every `+page.server.ts` that needs it. Do not
  rely on a layout guard alone to protect a child route.
- API routes return JSON with real status codes: 400 / 401 / 403 / 404.
- Cron and webhook routes validate their own bearer secret before doing anything.

## Styling

### Tailwind v4, CSS-first

Tailwind v4 with `@tailwindcss/vite`. **There is no `tailwind.config` file** —
configuration is CSS-first via `@theme` in `app.css`.

```css
@import 'tailwindcss';

@theme {
  --color-bg: #faf5ee;
  --color-surface: #ffffff;
  --color-text: #2a0c10;
  --color-accent: #c8503a;

  --font-display: 'Lora', serif;
  --font-body: 'Nunito', sans-serif;

  --radius-sm: 6px;
  --radius-md: 12px;
  --radius-lg: 20px;
}
```

Rules:

- **Never a raw hex value in markup.** `bg-[#05c8aa]` is a bug. Every colour,
  font and radius comes from a `@theme` token. A codebase without `@theme` drifts
  into hundreds of one-off arbitrary values and stops being restyleable.
- Utility classes inline in the markup. A `<style>` block is only for what
  utilities cannot express: `@keyframes`, pseudo-elements, `:global()`.
- `@apply` sparingly, and only when it genuinely removes repetition.
- Mobile-first: base → `sm:` → `md:` → `lg:` → `xl:`.
- Group utilities in a consistent order: layout → spacing → typography → colors → effects.
- `class:` directive for conditional classes. For complex cases, a template
  literal or a tiny local helper. No heavy class-merging library unless the
  project already has one.
- Use `group`, `peer` and `dark:` variants rather than hand-rolled state classes.

### Projects without Tailwind

Not every project uses Tailwind. Static, zero-third-party sites use plain CSS
custom properties in `app.css` as the token layer instead. **Check what the repo
actually does before styling anything** — introducing Tailwind into such a repo
is a breaking architectural change, not a convenience.

The rule that survives either way: components reference `var(--token)` or a
Tailwind token, never a literal colour.

## Component design

- KISS. A component that does one thing well beats one with twenty props.
- Flat beats nested. Do not build component hierarchies that exist only to pass
  props down.
- **Rule of three**: extract a component when there is actual repetition, not in
  anticipation of it. Used once means it is not a component yet.
- Small component APIs, sensible defaults, minimal required props.
- Composition over configuration — snippets and children, not a config object.
- TypeScript prop interfaces. Never `any`.

## Design quality

Visual hierarchy, whitespace, typography, colour contrast, micro-interactions.
Mobile-first means real touch targets and thumb-zone placement, not just a
breakpoint that does not overflow.

Every data-driven component handles all four states: loading, error, empty, and
the long-content case.

Accessibility is not a follow-up: semantic elements, ARIA where semantics fall
short, keyboard navigation, visible focus, sufficient contrast.

## i18n

For bilingual sites, keep locale dictionaries with **identical key sets** and let
routing carry the locale (`src/routes/[lang=locale]/`). Resolve internal links
through a helper so a locale change cannot produce a dead link.

French copy is written natively, never machine-translated. If the French is not
ready, ship a marked placeholder (`TODO(fr-native): <english>`) rather than a
translation nobody proofread.

## Ecosystem

Prefer built-in Svelte features first. When a library is warranted:

- **Headless UI**: Melt UI, Bits UI, shadcn-svelte
- **Icons**: Lucide Svelte, Phosphor Svelte, unplugin-icons
- **Animation**: built-in transitions first, then Motion One or auto-animate
- **Forms**: Superforms + Zod
- **Tables**: TanStack Table
- **State**: runes first. Reach outside only when there is genuinely shared,
  cross-route state.
- **Testing**: Vitest + Testing Library, Playwright for e2e

## Tooling

The Svelte MCP server (`npx -y @sveltejs/mcp`) belongs in the project's
`.mcp.json`, not in this skill. Use it for the autofixer and for current Svelte 5
API answers rather than relying on memory.

## Don't

- Don't use `export let` or add new `svelte/store` writables
- Don't use `any`
- Don't fetch in `onMount` when a `load` function fits
- Don't use CSS-in-JS or CSS modules
- Don't create abstractions prematurely
- Don't write raw hex colours in components
- Don't build god-components
