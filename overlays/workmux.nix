final: super:
let
  pkgs = super.pkgs;

  version = "0.1.250";

  # Prebuilt release binaries from https://github.com/raine/workmux/releases
  # Same artifacts the official install.sh / Homebrew tap ship.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/raine/workmux/releases/download/v${version}/workmux-darwin-arm64.tar.gz";
      hash = "sha256-opFFWQw6y0/tlBP/RrSSGLYDbjcwyITvDq3nUX9d/Is=";
    };
    x86_64-darwin = {
      url = "https://github.com/raine/workmux/releases/download/v${version}/workmux-darwin-amd64.tar.gz";
      hash = "sha256-NDg8esMW88pQFyszzrUw79pUEJmexfBQHRh3TscKYG8=";
    };
    aarch64-linux = {
      url = "https://github.com/raine/workmux/releases/download/v${version}/workmux-linux-arm64.tar.gz";
      hash = "sha256-JyFRodm8wuUC9FSxpA99vaNeoAWQEKnlycvDeK6AWRY=";
    };
    x86_64-linux = {
      url = "https://github.com/raine/workmux/releases/download/v${version}/workmux-linux-amd64.tar.gz";
      hash = "sha256-uCvYFjj6GIQZqaLdyoFbMz0fxLpNm07nD+RLfONnf1k=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "workmux: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  workmux = pkgs.stdenv.mkDerivation {
    pname = "workmux";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    # Tarball contains a single statically-linked `workmux` binary at the root.
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 workmux $out/bin/workmux
      ln -s workmux $out/bin/wm
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Git worktree + tmux workflow tool for parallel development";
      homepage = "https://github.com/raine/workmux";
      license = licenses.mit;
      mainProgram = "workmux";
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
