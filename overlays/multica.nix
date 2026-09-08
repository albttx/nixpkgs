final: super:
let
  pkgs = super.pkgs;

  version = "0.4.41";

  # Prebuilt release binaries from https://github.com/multica-ai/multica/releases
  # Same artifacts the official install.sh / Homebrew tap ship.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-darwin-arm64.tar.gz";
      hash = "sha256-WyKDKxIAJRWZmyU3rekCJW/L2YdmCJ6zCFUr4ze/7rw=";
    };
    x86_64-darwin = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-darwin-amd64.tar.gz";
      hash = "sha256-JUfLJ8n9VvV/T4rwXI7TtDF3L+BjQ99w5hYML8pySq4=";
    };
    aarch64-linux = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-linux-arm64.tar.gz";
      hash = "sha256-T95yG/S4VwxPPZ2D87rak4YngRWEnwhHnzyyHAhoHNE=";
    };
    x86_64-linux = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-linux-amd64.tar.gz";
      hash = "sha256-tmbvfsImeA2wS0W47Du9SARQm23I7wZ5HKft9kP42Hc=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "multica: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  multica = pkgs.stdenv.mkDerivation {
    pname = "multica";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.autoPatchelfHook
    ];
    buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.stdenv.cc.cc.lib
    ];

    # Tarball contains a single `multica` binary at the root.
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 multica $out/bin/multica
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Multica CLI — local agent runtime and management tool for the Multica platform";
      homepage = "https://github.com/multica-ai/multica";
      license = licenses.asl20;
      mainProgram = "multica";
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
