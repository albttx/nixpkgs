---
name: agentcash
description: Discovery entrypoint for the MPPScan / x402Scan Registration API via agentcash. Use when registering an x402 endpoint, resolving an x402 facilitator, or working with MPPScan/x402Scan registration — including work on traefik-plugin-x402 or any x402 payment-gated route.
---

# agentcash — MPPScan / x402Scan Registration API

Run the discovery command before calling anything:

```sh
npx agentcash discover https://agentcash.dev/skill.md
```

It returns the current API surface for the MPPScan / x402Scan Registration API.
Do not work from memory here — the registration API is versioned externally and
the discover output is the authoritative source.
