---
name: signed-app-overlays
description: How to package prebuilt notarized macOS .app bundles as overlays without breaking their Developer ID signature
metadata:
  type: project
---

The overlays `overlays/screenpipe.nix`, `overlays/anarlog.nix`, `overlays/meetily.nix` package prebuilt, notarized Tauri `.app` bundles fetched from releases into `$out/Applications/`.

Fix applied (2026-07-09): each mkDerivation sets `dontFixup = true;` to stop the default fixupPhase (`strip` + aarch64-darwin auto-signing hook) from stripping the Developer ID signature and re-signing ad-hoc.

**Why:** Without `dontFixup`, the store bundle ends up `Signature=adhoc`, `TeamIdentifier=not set`, and `codesign --verify --deep --strict` / `spctl` fail; notarization is lost.

**Non-obvious gotchas (verified against the STORE output, not a temp dir):**
- Non-Mach-O bundle components carry their signature in `com.apple.cs.*` **extended attributes**, not embedded. screenpipe's `Contents/MacOS/mlx.metallib` is one. GNU tar (default unpackPhase) cannot read `LIBARCHIVE.xattr.*` pax headers and silently drops these xattrs ("Ignoring unknown extended header keyword"), so `--deep --strict` fails with "code object is not signed at all". Fix: screenpipe uses a custom `unpackPhase` with `bsdtar -xpf "$src"` (add `pkgs.libarchive` to `nativeBuildInputs`). bsdtar preserves the xattrs; setxattr works in the relaxed sandbox.
- anarlog (unpacks a `.dmg` via `undmg`) and meetily (GNU-tar tarball) have NO xattr-only-signed components, so `dontFixup` + `cp -R` alone passes for them. Do not add bsdtar there unnecessarily.
- macOS `cp -R` preserves xattrs, so the install-phase copy is fine.
- `/usr/bin/ditto` is NOT usable — it's outside the Nix build sandbox paths ("Operation not permitted"). Do not use ditto in these installPhases.

**How to apply:** When adding a new signed-.app overlay, after building the store path verify on `$out/Applications/<App>.app` with `codesign --verify --deep --strict` and `spctl -a -t exec -vv` (must show `source=Notarized Developer ID`). If any subcomponent shows "not signed at all", the unpack dropped its xattrs — switch that overlay's unpackPhase to bsdtar. Signing identities: screenpipe URFF7QHPUR (Louis Beaumont), anarlog 6SLY7V277V (Fastrepl, Inc.), meetily 554AZZ38TB (ZACKRIYA SOLUTIONS).
