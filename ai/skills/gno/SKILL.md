---
name: gno
description: Conventions for gno.land smart-contract work — writing realms (r/) and pure packages (p/), interrealm crossing functions and payment guards, the security-review checklist, storage and incremental reads, gno testing gotchas, deployment under a namespace with gnokey, and connecting a web frontend (vm/qeval, Adena, the sign-doc pitfall). Use for any .gno file, gnomod.toml, gnodev/gnokey work, or a dapp talking to a gno chain.
---

# gno.land

Deterministic Gno smart contracts on gno.land. This is the realm/package layer;
for the chain itself (CometBFT, genesis, node ops, upgrades) use the `cosmos`
skill. Gno is a Go-like interpreted language, not the Go toolchain: no `go.mod`
inside a package, no compile step, state persists automatically.

## CRITICAL: detect the version first

APIs moved fast around mainnet. Before writing code, pin the exact revision:

- `gno version`, `gno env GNOROOT` — the toolchain you build/test against.
- Mainnet is chain-id **`gnoland-1`** (`rpc.gno.land:443`), launched from the
  `chain/mainnet` tag; its RPC `node_info.version` reports `v1.0.0-rc.0`.
- `GNOROOT` must be a `gnolang/gno` checkout at the revision the target chain
  runs. A client newer or older than the chain can fail opaquely (amino account
  query, or signature mismatch). For mainnet use the `chain/mainnet` tag.
- Tests pass or fail depending on which GNOROOT is active. Verify it before
  trusting a green run.

The current API surface (mainnet era): `chain`, `chain/runtime`,
`chain/banker`, `chain/runtime/unsafe`, versioned std packages under
`gno.land/p/nt/*/v0` (`avl`, `ufmt`, `uassert`, `ownable`, `testutils`,
`markdown/sanitize`). Older trees used unversioned `p/demo/*` and no
`chain/runtime/unsafe`; do not mix.

## Package layout and versioning

```
p/<ns>/<name>/         pure package → gno.land/p/<ns>/<name>/vN   (no chain state)
r/<ns>/<name>/         realm        → gno.land/r/<ns>/<name>/vN   (stateful app)
```

- The **version lives in the `gnomod.toml` `module` line, not the directory**.
  `module = "gno.land/r/<ns>/foo/v0"`; the directory is `r/<ns>/foo`. The
  toolchain resolves imports from the module line and ignores the dir name.
- `gnomod.toml`: `module = "..."` and `gno = "0.9"`.
- New contracts start at **v0** (gno's "initial, unaudited"). A published path
  is immutable: a breaking change (removed/renamed export, changed signature or
  storage layout) ships as a new `/vN`; non-breaking work edits in place.
- Split reusable logic into a pure `p/` library (unit-tested, no realm globals,
  caller supplies height/address) plus a thin `r/` realm that wires it to the
  chain and shows it via `Render`.
- `gnowork.toml` (empty file) at a workspace root lets local `p/` ↔ `r/`
  imports resolve without publishing.

## Interrealm: crossing functions

State-mutating exported realm functions are **crossing functions**: the first
parameter is `cur realm`.

```go
func Set(cur realm, key, value string) {
	if !cur.IsCurrent() { panic("spoofed realm") }
	caller := cur.Previous().Address() // the verified caller
	...
}
```

- Identity comes from `cur.Previous().Address()`, **never** an `address`
  parameter (attacker-controlled).
- A function whose first param is typed `realm` MUST name it `cur`, and calling
  it resets `Previous()` to *this* realm. So an internal helper that needs the
  original caller takes the realm **not first** — the `p/nt/ownable` idiom:
  `func assertOwner(_ int, rlm realm)`, called `assertOwner(0, cur)`.
- Never store a `realm` value (ephemeral, panics at attach). Store
  `Address()`/`PkgPath()` strings.
- `chain/runtime/unsafe.PreviousRealm()` skips the `IsCurrent()` check — never
  use it alongside a `cur realm` param.

## Payment guards (the pattern that matters)

Coins arrive push-only via the transaction's `-send` envelope; there is no
ERC-20-style `transferFrom`. To charge for a call, pair two checks and keep them
together:

```go
import (
	"chain"
	"chain/banker"
	"chain/runtime/unsafe"
)

func Buy(cur realm) {
	if !cur.IsCurrent() { panic("spoofed realm") }
	// (a) EOA-only: only a direct user call guarantees the -send envelope
	//     actually landed at this realm's address. Rejects intermediate code
	//     realms AND maketx-run ephemeral realms.
	if !cur.Previous().IsUserCall() { panic("must be a direct user call") }
	// (b) exact amount actually attached to this tx.
	if unsafe.OriginSend().AmountOf("ugnot") != price { panic("wrong amount") }
	// forward immediately so nothing accrues in the realm:
	bnk := banker.NewBanker(banker.BankerTypeOriginSend, cur)
	bnk.SendCoins(cur.Address(), owner, chain.NewCoins(chain.NewCoin("ugnot", price)))
}
```

- `IsUserCall()` (pkgPath == "") not `IsUser()` (also accepts user-run
  ephemeral realms). `OriginSend()` without the EOA guard is lying about
  receipt; the EOA guard without the amount check lets users pay nothing.
- `OriginSend` is in `chain/runtime/unsafe` on the mainnet API, not in
  `chain/banker`.
- Single-denom balance: `banker.GetCoin(addr, denom)`, not
  `GetCoins(addr).AmountOf(denom)` — `GetCoins` is unbounded (anyone can mint
  junk denoms to any address) and its cost is attacker-controlled. Exception:
  in `Render` where the denom is caller-supplied, `GetCoin` panics on a
  malformed denom while `AmountOf` returns 0.

## Security review checklist

- Authenticated mutators take `cur realm` and call `cur.IsCurrent()`.
- No `chain/runtime/unsafe` import alongside `cur realm` params.
- Payment-guarded funcs use `cur.Previous().IsUserCall()`.
- No exported function returns a pointer to internal mutable state.
- No exported func returns a `/p/`-type pointer whose type has mutation methods
  (e.g. never `func GetStore() *avl.Tree` — attacker calls `.Set` under your
  authority); expose read accessors instead.
- No exported `/p/`-struct field that is a pointer to a type with mutators.
- No caller-supplied `func(...)` callback invoked with realm authority; type
  callbacks with your own `/r/`-declared type.
- Interface params from external callers: assert the canonical concrete type
  (`grc20.IsCanonicalTeller(t)`) before dispatch.
- No `realm`-typed package var, field, or closure capture.
- `Render(path)` sanitizes path segments, keys and user values before writing
  markdown (`gno.land/p/nt/markdown/sanitize/v0`, e.g. escape `|` in tables).

## Storage and reads

- State persists by assigning to package-level vars; no keeper, no KVStore.
- Storage is paid: a **storage deposit** (~100 ugnot/byte, GovDAO param) is
  locked per byte written, charged to the writer's tx on top of gas. Deleting
  refunds it. Design for lazy allocation (allocate a row/bucket on first write,
  leave the rest nil).
- `Render(path string) string` returns markdown and is the read API gnoweb
  serves. Test it (an `ExampleRender` with `// Output:`, or `uassert.Equal`).
- For large mutable state, make reads incremental: keep a `version int64` that
  bumps per write and a per-chunk last-touched version, and expose
  `Version()` + `DirtyRows(since)` so clients fetch only what changed. A single
  `vm/qeval` cannot return unbounded data (per-query gas cap; a full 1M-cell
  board read fails), so page it.

## Testing gotchas (each has bitten)

- `testing.SetRealm(testing.NewUserRealm(addr))` affects **only the calling
  frame** — cannot be wrapped in a helper; set it inline in each test. Pair with
  `testing.SetOriginSend(...)` / `SetOriginCaller(...)`; reset the per-message
  spend with `SetOriginSpend(nil)` between paid calls, and fund the realm with
  `testing.IssueCoins(realmAddr, ...)` as the chain would pre-message.
- Use `testutils.TestAddress("name")` (`p/nt/testutils/v0`) for addresses;
  hand-made `g1...` strings fail `address.IsValid()`.
- `recover()` cannot catch a panic across a crossing call. Assert refusals with
  `uassert.AbortsWithMessage(t, cur, "msg", func(){ F(cross(cur), ...) })` /
  `AbortsContains`.
- `uassert.Equal` does not support structs ("unsupported type") — compare with
  `!=` and `t.Errorf`.
- `init(cur realm)` sees an empty `cur.Previous().Address()` under `gno test`;
  a test-file `init()` can set the owner var for tests.
- `avl` `Get` returns ONE value (nil on miss), not `(v, ok)`; comma-ok is only
  for the type assertion of the result.
- No `sort.Slice` (only `sort.Sort(Interface)` + `Search*`); break ties
  deterministically and never iterate a map to build `Render` output (unspecified
  order).
- `ufmt` has no width/padding flags: `ufmt.Sprintf("%03d", 7)` == `"7"`. Pad by
  hand; matters for avl numeric keys (`"0","1","10","2"` sort).
- `testing.SkipHeights` is relative; there is no absolute height setter.
- A filetest's `// PKGPATH:` last path element must be literally `main`.

Green before commit: `gno lint ./...` and `gno test ./...` (needs a correct
`GNOROOT`).

## Local dev with gnodev

```
gnodev local -extra-root . -paths gno.land/r/<ns>/<name>/v0
```

- Node RPC on `:26657`, gnoweb on `:8888`, chain-id `dev`, RPC CORS `*`.
- Auto-loads the workspace packages at their module paths and hot-reloads on
  save. **Hot reload / restart reassigns account numbers and can drop
  out-of-band txs**, which breaks a wallet that cached the old number. Premine
  and stabilize an address at genesis with
  `-add-account <bech32>=100000000000ugnot`.
- Restarting resets the board/state; replays only txs sent through gnodev.

## Deploying with gnokey

```
gnokey maketx addpkg -pkgdir ./p/<ns>/<name> -pkgpath gno.land/p/<ns>/<name>/v0 \
  -gas-fee 1000000ugnot -gas-wanted 100000000 -max-deposit 20000000ugnot \
  -broadcast -chainid gnoland-1 -remote https://rpc.gno.land:443 <key>
```

Publish the pure package before the realm that imports it.

**Namespaces** (authorization is `r/sys/names`):

- Any address may deploy under its **own address namespace**,
  `gno.land/{p,r}/<its-bech32>/...`, with no registration. This is the
  no-friction path: deploy with that key. The namespace is the **deploy key's
  address** and is independent of any admin/owner var inside the realm.
- Human names are registered via `r/sys/namereg/v0.Register(name)` and only
  match `nym-<5..13 lowercase letters><3 digits>` (e.g. `nym-alice123`),
  currently free. `albttx`-style vanity names need a GovDAO `ProposeNewName`.
- `unauthorized to deploy packages to namespace X` → you don't own X; use your
  address namespace or register a `nym-`.
- `package already exists` → a path is immutable and cannot be re-published;
  bump to a new `/vN` (fresh empty state, no migration).
- On mainnet a post-genesis `addpkg` is **queued by the approvals oracle**: a
  "success" is accepted-into-queue, not yet live. Fund the account for gas +
  storage deposit.

Make parameters owner-settable (a `var` + an owner-guarded setter, e.g.
`SetPrice`, `SetMaxBatch`, `TransferOwnership`) so tuning them later is a tx, not
a new version. `const` values can only change by redeploying a new version.

## Frontend integration

**Read** through the node's `vm/qeval` ABCI query — no library needed:

```
POST <rpc> {jsonrpc,id,method:"abci_query",
  params:{ path:"vm/qeval", data: base64("<pkgpath>.<Expr(args)>") }}
```

`data` is `<pkgpath>.<expression>` base64-encoded with **no trailing newline**
(`base64 | tr -d '\n'`). The response `ResponseBase.Data` is base64; a value
comes back typed as `("hello" string)` / `(42 int)` / `(100000 int64)` — unwrap
it. `vm/qrender` renders `Render(path)`. Balances: `bank/balances/<addr>`.

**Write** through a wallet. **Adena** (`window.adena`, source
`onbloc/adena-wallet`) is injected asynchronously — poll for it, don't check
once at mount, or you'll show "install" while it's present and skip
auto-reconnect. `AddEstablish` once (returns `ALREADY_CONNECTED` on repeat), then
`DoContract`:

```js
adena.DoContract({ messages:[{ type:"/vm.m_call", value:{
  caller, send:"50000ugnot", max_deposit:"", pkg_path, func:"F", args:[...] }}],
  gasFee, gasWanted, memo })
```

- `max_deposit` is **required** in the MsgCall value (use `""`). Omitting it
  makes the signed doc lack the field while the node signs over it →
  `std.UnauthorizedError: signature verification failed`.
- Error `NOT_CONNECTED` (code 1000) at sign time (seen with Ledger after a
  refresh): re-run `AddEstablish` and retry the `DoContract` once.
- Confirm the wallet's active network chain-id equals the node's, or every
  signature verifies against the wrong chain-id.

**Sign-doc caveat (verified):** gno **v1.2.0** builds the fee in its sign bytes
as `{"gas_fee":"...ugnot","gas_wanted":N}`, but the JS libs `tm2-js-client`
(3.3.0) / `gno-js-client` (3.1.0) sign `{"amount":[...],"gas":"..."}`. Those
differ, so a JS-signed tx is rejected as UnauthorizedError against a v1.2.0 node
while `gnokey` (the Go client shipped with the node) works. If browser signing
fails only on a local v1.2.0 node, this is why; provide a gnokey/CLI fallback
(generate `gnokey maketx call` commands) or run a node matching the wallet's
sign format.
