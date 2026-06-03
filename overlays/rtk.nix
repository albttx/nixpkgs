final: super:
let
  pkgs = super.pkgs;

  version = "0.42.0";

  # Prebuilt release binaries from https://github.com/rtk-ai/rtk/releases
  sources = {
    aarch64-darwin = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-apple-darwin.tar.gz";
      hash = "sha256-zdyc0RzfgLM0LuuroOarJtnI3sRSlepEz5gGKYcYVyQ=";
    };
    x86_64-darwin = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-apple-darwin.tar.gz";
      hash = "sha256-OxufE1SFma6dkg9eMWnMQC2xkwBE6iTgvk4ja38HKpk=";
    };
    aarch64-linux = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-Yrt0nfHtZPCRSZmMMd6GSTLwR6G+Tg+IKozq2oSeCHE=";
    };
    x86_64-linux = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-zdT4esl86Vj3G1OpkYgNatzEHMW8oQRBdaZGMJgBUr4=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "rtk: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  rtk = pkgs.stdenv.mkDerivation {
    pname = "rtk";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    # The Linux -gnu build is a dynamically linked ELF; patch its interpreter
    # and rpath so it runs on NixOS. No-op for the static musl/Mach-O builds.
    nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.autoPatchelfHook
    ];
    buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.stdenv.cc.cc.lib
    ];

    # Tarball contains a single `rtk` binary at the root.
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 rtk $out/bin/rtk
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Rust Token Killer - CLI proxy that compresses command output for LLMs";
      homepage = "https://github.com/rtk-ai/rtk";
      license = licenses.mit;
      mainProgram = "rtk";
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
