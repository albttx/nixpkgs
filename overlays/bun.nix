final: prev:
let
  # nixpkgs (even master) lags behind bun releases; override to the official
  # prebuilt zips from https://github.com/oven-sh/bun/releases while keeping
  # the nixpkgs derivation's install/patchelf/codesign logic.
  # Drop this overlay once nixpkgs catches up to >= this version.
  version = "1.4.2";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
      hash = "sha256-kJh6OhbX21VtiGrD1VHnttPt8KHPQ6yu1iLoZ2vh0S8=";
    };
    aarch64-linux = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
      hash = "sha256-VDKLvC2cjgyfiSxUTWbFeoO4QTnjSQnl7oF1jxrI/ac=";
    };
    x86_64-linux = {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
      hash = "sha256-xngEDxT+BEDrg503y9DOTAUaMtpygGrJfeamqra/co8=";
    };
  };

  source =
    sources.${prev.stdenv.hostPlatform.system}
      or (throw "bun: unsupported platform ${prev.stdenv.hostPlatform.system}");
in
{
  bun = prev.bun.overrideAttrs (old: {
    inherit version;
    src = prev.fetchurl { inherit (source) url hash; };
  });
}
