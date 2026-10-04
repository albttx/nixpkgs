final: prev:
let
  pkgs = prev;
  version = "1.2.1";

  systems = {
    "aarch64-darwin" = {
      suffix = "darwin_arm64";
      hash = "sha256-lSbnJ10CgO5xnXRxy+WKSe9BR4vJORLSwccmgbwq2sw=";
    };
    "x86_64-darwin" = {
      suffix = "darwin_amd64";
      hash = "sha256-Mw+lhATwOIdPhLEkkymUjR8SbJqQZSDHeD+QDQfr4Z4=";
    };
    "aarch64-linux" = {
      suffix = "linux_arm64";
      hash = "sha256-eODySHajk/amremdOYyqOHjVTki7a4Tqu1NrGPhaVzM=";
    };
    "x86_64-linux" = {
      suffix = "linux_amd64";
      hash = "sha256-s8wTJgIqAbBvlwCrfl5xOcop4X2DTO+9/VG+fw4N4sk=";
    };
  };

  source =
    systems.${pkgs.stdenv.hostPlatform.system}
      or (throw "gno-indexer: unsupported platform ${pkgs.stdenv.hostPlatform.system}");
in
{
  gno-indexer = pkgs.stdenvNoCC.mkDerivation {
    pname = "gno-indexer";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/gnolang/tx-indexer/releases/download/v${version}/tx-indexer_${version}_${source.suffix}.tar.gz";
      inherit (source) hash;
    };

    sourceRoot = ".";

    installPhase = ''
      install -Dm755 tx-indexer "$out/bin/tx-indexer"
    '';

    meta = {
      description = "Tendermint2 indexer for Gno.land chains";
      homepage = "https://github.com/gnolang/tx-indexer";
      license = pkgs.lib.licenses.asl20;
      mainProgram = "tx-indexer";
      platforms = builtins.attrNames systems;
      sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
    };
  };
}
