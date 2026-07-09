final: super:
let
  pkgs = super.pkgs;

  version = "1.1.11";

  # Prebuilt macOS app bundle (code-signed with Developer ID
  # "Fastrepl, Inc." + notarized, ticket stapled) shipped as a .dmg in the
  # anarlog GitHub release. The bundle inside is named "Anarlog.app".
  # https://github.com/fastrepl/anarlog/releases/tag/desktop_v${version}
  sources = {
    aarch64-darwin = {
      url = "https://github.com/fastrepl/anarlog/releases/download/desktop_v${version}/hyprnote-macos-aarch64.dmg";
      hash = "sha256-WxiFCHI5BFSAfslxGIlLqol4mifZFasYcUaXmKuFA58=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "anarlog: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  anarlog = pkgs.stdenv.mkDerivation {
    pname = "anarlog";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    nativeBuildInputs = [ pkgs.undmg ];

    # undmg unpacks the DMG into the current directory; the app bundle sits
    # at the top level as "Anarlog.app".
    sourceRoot = ".";

    # The bundle is already code-signed with Developer ID "Fastrepl, Inc." and
    # notarized (ticket stapled). Nix's default fixupPhase runs `strip` on the
    # Mach-O binaries (removing the Developer ID signature) and the
    # aarch64-darwin auto-signing hook then re-signs them ad-hoc, destroying
    # notarization and breaking `codesign --verify --deep --strict` / `spctl`.
    # Disable fixup entirely to keep the original signature intact.
    dontFixup = true;

    # macOS `cp -R` and `undmg` both preserve extended attributes, so any
    # signing xattrs survive the copy into the store. Verified against the
    # store output: `codesign --verify --deep --strict` and `spctl` both pass
    # with source=Notarized Developer ID (Fastrepl, Inc. / 6SLY7V277V).
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R Anarlog.app "$out/Applications/Anarlog.app"
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "anarlog desktop app (notarized macOS GUI bundle)";
      homepage = "https://github.com/fastrepl/anarlog";
      license = licenses.unfree;
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
