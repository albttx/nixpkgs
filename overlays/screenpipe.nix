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

    # bsdtar (libarchive) is required to unpack the tarball with its macOS
    # code-signing extended attributes intact (see unpackPhase below).
    nativeBuildInputs = [ pkgs.libarchive ];

    # The updater artifact is a gzipped tarball containing `screenpipe.app`.
    sourceRoot = ".";

    # Unpack with bsdtar, NOT the GNU tar used by the default unpackPhase.
    # Non-Mach-O bundle components (e.g. Contents/MacOS/mlx.metallib) carry
    # their code signature in `com.apple.cs.*` extended attributes rather than
    # embedded in the file. GNU tar cannot read the `LIBARCHIVE.xattr.*` pax
    # headers and silently drops those xattrs on extraction ("Ignoring unknown
    # extended header keyword"), which breaks `codesign --verify --deep
    # --strict` ("code object is not signed at all") and notarization. bsdtar
    # with -p preserves the xattrs, keeping the notarized signature valid.
    unpackPhase = ''
      runHook preUnpack
      bsdtar -xpf "$src"
      runHook postUnpack
    '';

    # The bundle is already code-signed with a Developer ID and notarized.
    # Nix's default fixupPhase runs `strip` on the Mach-O binaries (removing the
    # Developer ID signature) and the aarch64-darwin auto-signing hook then
    # re-signs them ad-hoc, destroying notarization and breaking
    # `codesign --verify --deep --strict` / `spctl`. Disable fixup entirely to
    # keep the original signature intact.
    dontFixup = true;

    # macOS `cp -R` preserves extended attributes, so the signing xattrs
    # survive the copy into the store (verified against the store output).
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
