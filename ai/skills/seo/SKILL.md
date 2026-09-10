---
name: seo
description: Conventions for search engine optimization — technical audits, JSON-LD structured data, meta tags and Open Graph, sitemaps and robots.txt, canonicals, hreflang, Core Web Vitals and on-page optimization. Use for meta/head work, sitemap.xml, robots.txt, llms.txt, structured data, or any search-visibility task.
---

# SEO

Technical SEO with hands-on implementation. Think like a crawler, ship like a
frontend engineer.

## Crawlability first

- Every important page is reachable through internal links and the sitemap. No
  orphans.
- Clean URLs: descriptive, lowercase, hyphenated, no query params on canonical
  content. Be consistent about trailing slashes and enforce it at the router.
- Manage crawl budget: block irrelevant paths in robots.txt, `noindex` thin or
  duplicate pages, and send a `noindex` header (not just a tag) for anything that
  must not be indexed even when rendered by a bot.
- One canonical per page, self-referencing by default.
- Bilingual sites need reciprocal `hreflang` on every page plus `x-default`. A
  one-sided hreflang is ignored.

## Meta tags

```html
<title>Primary Keyword - Secondary Keyword | Brand</title>
<meta name="description" content="Compelling 150-160 char description with target keywords">
<link rel="canonical" href="https://example.com/page">

<meta property="og:type" content="website">
<meta property="og:title" content="Title for social sharing">
<meta property="og:description" content="Description for social sharing">
<meta property="og:image" content="https://example.com/og-image.jpg">
<meta property="og:url" content="https://example.com/page">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Title for Twitter">
<meta name="twitter:description" content="Description for Twitter">
<meta name="twitter:image" content="https://example.com/twitter-image.jpg">
```

Per-page meta, generated from page data, never a single global default repeated
across the site.

## Structured data

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Page Title",
  "author": { "@type": "Person", "name": "Author Name" },
  "datePublished": "2026-01-15",
  "dateModified": "2026-04-10",
  "image": "https://example.com/image.jpg",
  "publisher": {
    "@type": "Organization",
    "name": "Site Name",
    "logo": { "@type": "ImageObject", "url": "https://example.com/logo.png" }
  }
}
</script>
```

- Most specific `@type` available.
- Include recommended properties, not only the required ones.
- One primary entity per page; supplementary entities as needed.
- Validate with the Rich Results Test before shipping. Untested JSON-LD is
  decoration.

## Sitemaps, robots, llms.txt

- Generate `sitemap.xml` from the same route/slug registry the site renders from,
  so a new page cannot be missing from it.
- Accurate `lastmod`. Invented `priority` and `changefreq` values are noise.
- `robots.txt` points at the sitemap and blocks only what genuinely wastes crawl.
- `llms.txt` for sites that want to be legible to model-driven agents — a plain
  index of what the site is and where the canonical content lives.

## Performance is SEO

Core Web Vitals: LCP, INP, CLS.

- **Images**: modern formats (WebP/AVIF), correct intrinsic sizing, `loading="lazy"`
  below the fold, eager plus `fetchpriority="high"` on the LCP image. Always set
  width and height to reserve space (CLS).
- **Fonts**: preload the critical face, `font-display: swap`, subset. A late web
  font is both an LCP and a CLS problem.
- **JavaScript**: defer non-critical, minimize render-blocking, ship less.
- **CSS**: inline critical, defer the rest.
- **Server**: caching headers, CDN, Brotli.
- Mobile is the indexed version. Measure mobile, and write down the measurement
  procedure so a later "it got faster" claim is comparable.

## Content

- One `<h1>` per page containing the primary term.
- Logical heading nesting, no skipped levels.
- Semantic HTML: `<article>`, `<nav>`, `<main>`, `<section>`, `<aside>`.
- Internal links with descriptive anchor text. Never "click here".
- Content belongs in data (a content module, a CMS), not hardcoded in markup, so
  the same source feeds the page, the sitemap and the metadata.
- Write like a human. See the `docs` skill for voice, and note the em-dash ban
  applies to every user-facing string, EN and FR.

## Tooling

This used to be an agent carrying two MCP servers. As a skill it carries none, so
the tools have to come from the project:

- **Lighthouse** — put an MCP server in the project's `.mcp.json`, or just run
  `npx lighthouse <url> --output=json --preset=desktop` and read the result.
  Do not claim a Core Web Vitals number you did not measure.
- **Google Search Console** — needs a service-account credential, so it belongs
  in the `.mcp.json` of the repo that owns the property, never here.

## Audit workflow

1. **Crawl** — site structure, broken links, redirect chains, orphans
2. **Analyze** — Lighthouse, Core Web Vitals, structured data validity, index coverage
3. **Prioritize** — indexing blockers, then performance, then nice-to-haves
4. **Spec** — a concrete change per issue, not a recommendation
5. **Implement** — meta, JSON-LD, sitemap, headers and redirects directly;
   component-level changes follow the relevant frontend skill's conventions
6. **Validate** — re-run the audit and confirm, do not assume

Verification honesty: a fetch that carries your own session or a platform token
proves nothing about public reachability. Verify as an anonymous client. A 403
with a bot-mitigation header means your egress is rate-limited, not that the page
is down — do not loop the request.

## Don't

- Don't keyword-stuff
- Don't use hidden text, cloaking, or any black-hat technique
- Don't ignore mobile
- Don't build doorway or thin pages
- Don't ship structured data unvalidated
- Don't make an SEO change that degrades the user experience
- Don't hand-maintain a sitemap that could be generated
