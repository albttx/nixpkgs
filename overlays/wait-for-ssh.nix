final: super:
let
  pkgs = super.pkgs;

  version = "0.1.0";

  # Prebuilt release binaries from https://github.com/albttx/wait-for-ssh/releases
  sources = {
    aarch64-darwin = {
      url = "https://github.com/albttx/wait-for-ssh/releases/download/v${version}/wait-for-ssh_${version}_darwin_arm64.tar.gz";
      hash = "sha256-oxldurH4ZIgMiDfmqnxx3J2qSkEEdpOiYeM390TceQI=";
    };
    x86_64-darwin = {
      url = "https://github.com/albttx/wait-for-ssh/releases/download/v${version}/wait-for-ssh_${version}_darwin_amd64.tar.gz";
      hash = "sha256-cMfg78V3Vx2GiJOB71JBX/IPv3kS4D7e0nU1xSn4VVU=";
    };
    aarch64-linux = {
      url = "https://github.com/albttx/wait-for-ssh/releases/download/v${version}/wait-for-ssh_${version}_linux_arm64.tar.gz";
      hash = "sha256-OnodmGkwUNLueL5D1qYAbS7s9+ddNtotFUHjIYJy1Jg=";
    };
    x86_64-linux = {
      url = "https://github.com/albttx/wait-for-ssh/releases/download/v${version}/wait-for-ssh_${version}_linux_amd64.tar.gz";
      hash = "sha256-1WYiyyoYJyNcJhkyNTvYdnU9K/kkMHmbT4tMe6e53gI=";
    };
  };

  source =
    sources.${pkgs.stdenv.hostPlatform.system}
      or (throw "wait-for-ssh: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  wait-for-ssh = pkgs.stdenv.mkDerivation {
    pname = "wait-for-ssh";
    inherit version;

    src = pkgs.fetchurl { inherit (source) url hash; };

    nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.autoPatchelfHook
    ];
    buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.stdenv.cc.cc.lib
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 wait-for-ssh $out/bin/wait-for-ssh
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "CLI that waits for an SSH endpoint to become reachable";
      homepage = "https://github.com/albttx/wait-for-ssh";
      license = licenses.mit;
      mainProgram = "wait-for-ssh";
      platforms = builtins.attrNames sources;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
}
