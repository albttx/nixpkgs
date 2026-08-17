final: super:
let
  pkgs = super.pkgs;

  version = "1.1.23";

  # The npm package `@higgsfield/cli` is only a thin launcher: its postinstall
  # downloads the real native `hf` binary from GitHub releases into vendor/.
  # That impure download can't run in Nix's sandbox, so we fetch the prebuilt
  # binary directly and expose the same `higgsfield` / `higgs` commands the npm
  # bin entries provide (both just exec `hf`).
  # https://github.com/higgsfield-ai/cli/releases/tag/v${version}
  sources = {
    aarch64-darwin = {
      arch = "arm64";
      hash = "sha256-qAU2O9pmWf5KTx58lkhMK+8WtKPQPo4SITD7q2sHMDo=";
    };
    x86_64-darwin = {
      arch = "amd64";
      hash = "sha256-ARHo+NmN1hx5P5h4wdcE+l+lvtbKcd4sYREIQ0lKRRA=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "higgsfield-cli: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  higgsfield-cli = pkgs.stdenv.mkDerivation {
    pname = "higgsfield-cli";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/higgsfield-ai/cli/releases/download/v${version}/hf_${version}_darwin_${source.arch}.tar.gz";
      inherit (source) hash;
    };

    # Tarball holds a single top-level `hf` executable.
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 hf "$out/bin/hf"
      ln -s hf "$out/bin/higgsfield"
      ln -s hf "$out/bin/higgs"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Higgsfield AI CLI — generate images and videos from the terminal";
      homepage = "https://higgsfield.ai";
      license = licenses.mit;
      mainProgram = "higgsfield";
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
