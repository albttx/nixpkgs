final: super:
let
  pkgs = super.pkgs;

  version = "0.9.0";

  # Prebuilt release binaries from https://github.com/herdrdev/herdr/releases
  # Raw single-file binaries (statically linked on Linux), no tarball.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-macos-aarch64";
      hash = "sha256-MrU98JhyYoBZx4mmnwKmuOKeFN3yZxFCHzRj9wwa7xc=";
    };
    x86_64-darwin = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-macos-x86_64";
      hash = "sha256-0MkgsqEmp0gJ+hSRQRyaCXpEeGysnCylG4GKmVWBzxY=";
    };
    aarch64-linux = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-aarch64";
      hash = "sha256-nI2yD7fnQnsTjVNnET8WIf/TGfL2XW8AniWUApEV8NI=";
    };
    x86_64-linux = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-x86_64";
      hash = "sha256-T6GgEVjdgEPaktMbJweAsNzBBgMDjZthysTYGrY/tx8=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "herdr: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  herdr = pkgs.stdenv.mkDerivation {
    pname = "herdr";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/herdr
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Terminal runtime for coding agents - persistent sessions, panes, and agent status across machines";
      homepage = "https://github.com/herdrdev/herdr";
      license = licenses.asl20;
      mainProgram = "herdr";
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
