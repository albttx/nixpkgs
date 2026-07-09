final: super:
let
  pkgs = super.pkgs;

  version = "2.5.98";

  # Prebuilt Tauri app bundle (code-signed + notarized) from screenpipe's
  # updater CDN. The GitHub releases carry no assets; artifacts live in
  # Cloudflare R2 behind this stable, version-pinned URL.
  # Discovered via https://screenpipe.com/api/app-update/stable/darwin-aarch64/<ver>
  sources = {
    aarch64-darwin = {
      url = "https://screenpi.pe/api/app-update/download/stable/${version}/aarch64-apple-darwin/screenpipe.app.tar.gz";
      hash = "sha256-QAjyDtOxeNtS83ahZrAgaZhP78Vu2NoF6EN/AP9W/Gk=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "screenpipe: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  screenpipe = pkgs.stdenv.mkDerivation {
    pname = "screenpipe";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    # The updater artifact is a gzipped tarball containing `screenpipe.app`.
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R screenpipe.app "$out/Applications/screenpipe.app"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "AI app store powered by 24/7 desktop & mobile screen and audio recording (Tauri GUI)";
      homepage = "https://screenpi.pe";
      license = licenses.mit;
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
