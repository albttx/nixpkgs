final: super:
let
  pkgs = super.pkgs;

  version = "0.4.30";

  # Prebuilt release binaries from https://github.com/multica-ai/multica/releases
  # Same artifacts the official install.sh / Homebrew tap ship.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-darwin-arm64.tar.gz";
      hash = "sha256-NilCjuq31kXvLA/4zxqa/EiZAtlbjBpYBd9VRBeKqiI=";
    };
    x86_64-darwin = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-darwin-amd64.tar.gz";
      hash = "sha256-DH0Umh3gTsGHbWT2izkC+9PW+zvL66bZreGi7gTMEns=";
    };
    aarch64-linux = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-linux-arm64.tar.gz";
      hash = "sha256-Wc1Fm8It2sIvUU1k1aVf2UkPIDVw4urNdrmvCiomlhg=";
    };
    x86_64-linux = {
      url = "https://github.com/multica-ai/multica/releases/download/v${version}/multica-cli-${version}-linux-amd64.tar.gz";
      hash = "sha256-+F0PpgXGtAsmOKg0hV3QSao+uW889Jawnf6SGtOEZpU=";
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
