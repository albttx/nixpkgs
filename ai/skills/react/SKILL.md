---
name: react
description: Conventions for React frontend work in Next.js and in Vite SPAs — App Router, Server/Client Components, Server Actions, TanStack Router/Query, shadcn/Base UI, Tailwind v4 styling, forms, state and mobile-first responsive design. Use for any .tsx/.jsx file, next.config.ts, vite.config.ts, app/ or routes/ files, or React component work.
---

# React

Two shapes are in use, and the first section of this skill applies to only one of
them:

- **Next.js App Router + React 19** — the default for anything server-rendered.
- **Vite SPA** — for a client-only app with no server story: an internal tool, a
  dashboard behind auth, an embedded widget. TanStack Router for type-safe
  routing, TanStack Query for server state. None of the RSC rules below apply;
  everything from *Component design* onward does.

Check which one you are in before writing routing or data-fetching code.
TypeScript everywhere, mobile-first, and as plain as the problem allows.

## Read the installed Next.js first

Next.js moves faster than any model's training data, and a major version can
change the router, the caching defaults and the config surface underneath you.
Before writing router, caching or config code, check the version in
`package.json` and read the docs shipped in `node_modules/next/dist/docs/`.
Assume nothing about defaults.

## React 19 APIs

`use()` to unwrap a promise or context during render, `useActionState` for form
action state, `useOptimistic` for optimistic UI, `useFormStatus` for pending
state inside a form's subtree, and `ref` as a plain prop (no `forwardRef`).
Document metadata (`<title>`, `<meta>`, `<link>`) hoists from anywhere in the
tree. Check these against the installed React version before using them.

## Server / Client split

- **Server Components by default.** Add `"use client"` only for interactivity,
  browser APIs, or hooks — and add it as low in the tree as possible.
- Server Actions for mutations, colocated with the component or in `actions.ts`.
- Route Handlers (`route.ts`) for HTTP endpoints.
- `app/` with `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`.
- `@/` alias for project-root imports; components grouped under `@/components/`
  (`ui/`, `forms/`, `layouts/`).

```tsx
// Server Component
interface Props {
  id: string;
}

export async function UserProfile({ id }: Props) {
  const user = await getUser(id);
  return (
    <div className="flex flex-col gap-4 p-4">
      <h1 className="text-2xl font-bold">{user.name}</h1>
      <UserActions userId={id} />
    </div>
  );
}
```

```tsx
"use client";

import { useState } from "react";

interface Props {
  userId: string;
}

export function UserActions({ userId }: Props) {
  const [isFollowing, setIsFollowing] = useState(false);
  // ...
}
```

### The RSC boundary is a serialization boundary

Data crossing from a Server Component into a Client Component must be
serializable. A module of shared constants can hold **component functions** (fine
on the server side of the boundary) or **already-rendered elements** (fine to
pass across) — but the two shapes are not interchangeable, and mixing them is a
runtime error that types will not catch. Decide which shape a shared data module
holds and keep it consistent.

## Routing config beats filesystem routes

In `next.config.ts`, `redirects` are evaluated **before** filesystem routes. A
wildcard `source` will silently shadow a route handler that still exists and
still needs to work. Enumerate the sources you mean, or prove the wildcard cannot
swallow a live route.

## Styling: Tailwind v4, CSS-first

Tailwind v4 via `@tailwindcss/postcss`. **There is no `tailwind.config` file** —
configuration is CSS-first.

```css
@import "tailwindcss";
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  --color-background: var(--background);
  --color-primary: var(--primary);
  --color-brand: var(--brand);

  --radius-sm: calc(var(--radius) * 0.6);
  --radius-pill: 100px;
}
```

Rules:

- **Never a raw hex value in markup.** Everything routes through a `@theme`
  token, including the semantic shadcn tokens and the brand extras.
- Mobile-first: base → `sm:` → `md:` → `lg:` → `xl:`.
- Utility order: layout → spacing → typography → colors → effects.
- `cn()` (clsx + tailwind-merge) for conditional classes.
- `group`, `peer`, `dark:` variants rather than hand-rolled state classes.
- Named radius tokens (`--radius-pill`, `--radius-panel`, `--radius-btn`) beat
  raw `rounded-[14px]` — they keep the shape language consistent.

### Projects without Tailwind

Not every React project uses Tailwind. CSS Modules and vanilla-extract are both
reasonable in an app that predates it or deliberately avoids it. **Check what the
repo does before styling anything** — introducing Tailwind is an architectural
change, not a convenience.

The rule that survives either way: components reference a token, never a literal
colour.

## Component design

- KISS. One thing well beats twenty props.
- Flat beats nested.
- **Rule of three**: extract a component or a custom hook on actual repetition,
  not in anticipation of it.
- Composition over configuration: `children`, render props, compound components.
- Named exports for components; default exports only for pages and routes.
- Controlled vs uncontrolled: default to uncontrolled for simple forms.
- TypeScript throughout. Discriminated unions, generics, utility types. No `any`.

## Design quality

Visual hierarchy, whitespace, typography, contrast, micro-interactions.
Mobile-first means real touch targets and thumb-zone placement.

Every data-driven component handles loading, error, empty, and long-content.
Use `Suspense` boundaries and error boundaries so one slow fetch does not blank
the page.

Accessibility: semantic elements, ARIA where semantics fall short, keyboard
navigation, visible focus, sufficient contrast.

## Ecosystem

Prefer platform features first. When a library is warranted:

- **UI**: shadcn on Base UI or Radix primitives; `class-variance-authority` for
  variants; `lucide-react` for icons; `next-themes` for theming
- **Forms**: React Hook Form + Zod, or Conform with Server Actions
- **State**: React state and context first, then Zustand; TanStack Query for
  server state when you are not in RSC-land
- **Tables**: TanStack Table
- **Animation**: CSS transitions and `@starting-style` first, then Framer Motion
- **Routing (non-Next)**: TanStack Router; React Router where already in place
- **State**: Jotai for fine-grained atomic state where Zustand's single store chafes
- **Headless**: Ark UI and Headless UI alongside Radix and Base UI
- **Animation**: React Spring for physics-based motion
- **Testing**: Vitest + Testing Library (tests colocated next to the component),
  Playwright for e2e, MSW for API mocking
- **Tooling**: Vite for non-Next projects; Biome, or ESLint + Prettier; Storybook
  for component development where the component library is the deliverable

## Copy

When copy is dictated or pinned, it ships as written. Do not reword product copy
to taste. Before trimming a line, grep for it — copy frequently also lives in
plain data modules (`lib/competitors.ts`, `lib/legal-copy.ts`), not only in JSX,
and a page-local guard does not prove the next surface stopped repeating a claim.

Any negative or comparative claim about a competitor needs a cited source landing
in the same change.

## Don't

- Don't use `any`
- Don't put `"use client"` higher than it needs to be
- Don't `useEffect` for data fetching when a Server Component or TanStack Query fits
- Don't create abstractions prematurely
- Don't write raw hex colours in components
- Don't build god-components
- Don't use class components, `defaultProps` or `propTypes` in new code
- Don't install a library for something the framework already does
