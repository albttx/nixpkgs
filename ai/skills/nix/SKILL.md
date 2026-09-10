---
name: nix
description: Conventions for Nix, flakes, nix-darwin, Home Manager and NixOS work — writing flakes, derivations, overlays, modules, devShells, and debugging builds. Use for any .nix file, flake.nix, flake.lock, Home Manager or nix-darwin config, or Nix package build.
---

# Nix

Idiomatic, readable Nix following community conventions. Reproducibility is the
whole point — if it is not pinned and declarative, it does not count.

## Language

- Master the expression language: lazy evaluation, attribute sets, functions,
  imports, `let...in`, `inherit`, list/set operations, string interpolation.
- Write readable Nix, not clever Nix.
- Avoid `rec` unless truly needed — prefer `let...in` for clarity.
- Avoid `with pkgs;` in large scopes — it hides where names come from.

## Flakes

```nix
{
  description = "Project description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ go gopls golangci-lint ];
        };
      }
    );
}
```

- Pin all inputs — `flake.lock`, never channels.
- Use `follows` to align transitive nixpkgs versions and avoid multiple evaluations.
  Exception: when an input's own overlay pins a package version that the followed
  nixpkgs has dropped, let it keep its own pin and leave a comment saying why.
- Never `builtins.fetchTarball` in a flake — use a proper flake input.
- Split large configs into modules; do not put everything in one `flake.nix`.

## Home Manager modules

```nix
{ config, pkgs, lib, ... }:
{
  options.modules.myTool = {
    enable = lib.mkEnableOption "myTool";
  };

  config = lib.mkIf config.modules.myTool.enable {
    home.packages = [ pkgs.myTool ];

    home.file.".config/mytool/config.toml".text = ''
      # config content
    '';
  };
}
```

- `lib.mkEnableOption` for toggles, `lib.mkOption` with proper types for config.
- `lib.mkIf` for conditional config, `lib.mkMerge` for combining.
- Prefer the `options`/`config` pattern over raw attribute sets.
- One concern per module file.

### Linking directories into `$HOME`

Use `recursive = true` when the target directory must stay writable by the tool
that owns it (agents, skills, caches). A plain `source = ./dir` symlinks the whole
directory read-only.

```nix
home.file.".config/tool" = {
  source = ./tool;
  recursive = true;
};
```

## nix-darwin

macOS configured declaratively. `system.defaults` covers the plist settings you
would otherwise click through in System Settings (dock, finder, trackpad,
`NSGlobalDomain`); prefer it to a `defaults write` in an activation script.

- `launchd.user.agents.<name>` for user daemons, `launchd.daemons` for system
  ones. A `serviceConfig` with `KeepAlive` and `RunAtLoad` beats a hand-written
  plist.
- Homebrew integration (`homebrew.enable`, `casks`, `brews`, `masApps`) is for
  what nixpkgs genuinely cannot package: GUI apps with self-updaters, Mac App
  Store apps, and anything requiring a signed installer. Set
  `onActivation.cleanup = "zap"` so the declared list is the whole truth.
- `system.stateVersion` is not a version to bump casually. Leave it.
- Rebuild with `darwin-rebuild switch --flake .#<host>`.

## NixOS

- Rebuild on the machine: `nixos-rebuild switch --flake .#<host>`. Do not edit
  files on the box; change the flake and rebuild.
- `services.*` before a hand-written systemd unit. When you do need one,
  `systemd.services.<name>` with an explicit `serviceConfig`.
- Harden by default: no root SSH login, key-only auth, a firewall with an
  explicit `allowedTCPPorts`, and fail2ban on anything internet-facing.
- `lib.mkForce` when a module default fights you, and leave a comment saying
  which default you are overriding and why.

## Builders

`buildGoModule`, `buildNpmPackage`, `buildPythonPackage`, `buildRustPackage`, and
`stdenv.mkDerivation` when nothing more specific fits.

```nix
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "mytool";
  version = "1.0.0";

  src = pkgs.fetchurl {
    url = "https://example.com/mytool-${finalAttrs.version}.tar.gz";
    hash = "sha256-...";   # fixed-output: the hash is the contract
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 mytool $out/bin/mytool
    runHook postInstall
  '';
})
```

Fixed-output derivations (`fetchurl`, `fetchFromGitHub`, `vendorHash`,
`npmDepsHash`) are the only derivations allowed network access, which is exactly
why they must declare a hash. A wrong hash is a build failure; a missing one is
not reproducible.

For a one-off package that does not deserve its own overlay file, define it
inline in the config with the relevant builder.

Packaging a pre-signed macOS `.app`: set `dontFixup = true` and unpack with
`bsdtar`, which preserves the extended attributes carrying the signature.
`/usr/bin/ditto` and the default fixup phase both break it.

## Derivations

```nix
{ pkgs }:
pkgs.buildGoModule {
  pname = "mytool";
  version = "1.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "user";
    repo = "mytool";
    rev = "v1.0.0";
    hash = lib.fakeHash;   # replace after first build
  };
  vendorHash = lib.fakeHash;  # replace after first build
}
```

- Prefer Nixpkgs packages over hand-written derivations when one exists.
- `overrideAttrs` to patch an existing package, not a rewrite.
- Never write `hash = ""` and hope — use `lib.fakeHash` or `nix-prefetch-*`.

## Overlays

```nix
final: prev: {
  myPackage = prev.myPackage.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./fix.patch ];
  });
}
```

- Use `pkgs-master` / `pkgs-stable` / `pkgs-unstable` channel overlays to pin a
  single package to a different channel instead of moving the whole system.
  Fast-moving tools (CLIs, AI tooling) belong on master; everything else stable.
- One overlay per file under `overlays/`, registered in the flake's `overlays`
  attribute set.

## Debugging

- `nix repl` to explore attribute sets and evaluate expressions
- `nix build --print-build-logs` for build output
- `nix flake show` / `nix flake metadata` for flake inspection
- `builtins.trace` for evaluation-time debug printing
- `nix-diff` to compare derivations

## Don't

- Don't hardcode system architecture — use the `system` parameter or `flake-utils`
- Don't use `nix-env` — everything declarative
- Don't use channels — flakes with pinned inputs only
- Don't leave a formatting pass out: run `nixfmt` (`make fmt`) before committing
