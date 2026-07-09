final: super:
let
  pkgs = super.pkgs;

  version = "0.4.0";

  # Prebuilt Tauri app bundle (code-signed with Developer ID
  # "ZACKRIYA SOLUTIONS" + notarized) shipped as a signed .app tarball in the
  # meetily GitHub release. The bundle inside is named "meetily.app".
  # A .dmg exists too, but the tarball needs no undmg step.
  # https://github.com/Zackriya-Solutions/meetily/releases/tag/v${version}
  sources = {
    aarch64-darwin = {
      url = "https://github.com/Zackriya-Solutions/meetily/releases/download/v${version}/meetily_aarch64.app.tar.gz";
      hash = "sha256-+s/AM46otWZpgspW35fvPkn7nyRreNeXKEtnNTMMZqs=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "meetily: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  meetily = pkgs.stdenv.mkDerivation {
    pname = "meetily";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    # The updater artifact is a gzipped tarball containing `meetily.app`.
    sourceRoot = ".";

    # The bundle is already code-signed with Developer ID "ZACKRIYA SOLUTIONS"
    # and notarized. Nix's default fixupPhase runs `strip` on the Mach-O
    # binaries (removing the Developer ID signature) and the aarch64-darwin
    # auto-signing hook then re-signs them ad-hoc, destroying notarization and
    # breaking `codesign --verify --deep --strict` / `spctl`. Disable fixup
    # entirely to keep the original signature intact.
    dontFixup = true;

    # macOS `cp -R` preserves extended attributes, so any signing xattrs
    # survive the copy into the store. Verified against the store output:
    # `codesign --verify --deep --strict` and `spctl` both pass with
    # source=Notarized Developer ID (ZACKRIYA SOLUTIONS / 554AZZ38TB).
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R meetily.app "$out/Applications/meetily.app"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Privacy-first AI meeting assistant with on-device transcription and summaries (Tauri GUI)";
      homepage = "https://github.com/Zackriya-Solutions/meetily";
      license = licenses.mit;
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
