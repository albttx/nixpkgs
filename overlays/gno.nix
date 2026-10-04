final: prev:
let
  pkgs = prev;

  systems = {
    "aarch64-darwin" = "darwin_arm64";
    "x86_64-darwin" = "darwin_amd64";
    "aarch64-linux" = "linux_arm64";
    "x86_64-linux" = "linux_amd64";
  };

  mkReleaseTool =
    {
      version,
      name,
      hashes,
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      suffix = systems.${system} or (throw "gno: unsupported platform ${system}");
    in
    pkgs.stdenvNoCC.mkDerivation {
      pname = "gno-${name}";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/gnolang/gno/releases/download/v${version}/${name}_${suffix}";
        hash = hashes.${system};
      };

      dontUnpack = true;

      installPhase = ''
        install -Dm755 "$src" "$out/bin/${name}"
      '';

      meta = {
        homepage = "https://github.com/gnolang/gno";
        license = pkgs.lib.licenses.gpl3Only;
        mainProgram = name;
        platforms = builtins.attrNames hashes;
        sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
      };
    };

  mkTools =
    packages:
    pkgs.symlinkJoin {
      name = "gno-tools-${packages.gno.version}";
      paths = builtins.attrValues packages;
      passthru = packages;
    };

  gnoFromRelease =
    {
      version,
      hashes,
    }:
    let
      packages = builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value = mkReleaseTool {
              inherit version name;
              hashes = hashes.${name};
            };
          })
          [
            "gno"
            "gnokey"
            "gnoland"
            "gnodev"
            "gnoweb"
          ]
      );
    in
    mkTools packages;

  gnoFromSource =
    {
      rev,
      hash,
      version ? rev,
      rootVendorHash,
      gnodevVendorHash,
    }:
    let
      src = pkgs.fetchFromGitHub {
        owner = "gnolang";
        repo = "gno";
        inherit rev hash;
      };

      root = pkgs.buildGoModule {
        pname = "gno-tools-source";
        inherit version src;

        subPackages = [
          "gno.land/cmd/gnoland"
          "gno.land/cmd/gnokey"
          "gno.land/cmd/gnoweb"
          "gnovm/cmd/gno"
        ];

        vendorHash = rootVendorHash;
        env.CGO_ENABLED = 0;
      };

      gnodev = pkgs.buildGoModule {
        pname = "gnodev";
        inherit version src;
        modRoot = "contribs/gnodev";
        subPackages = [ "." ];
        vendorHash = gnodevVendorHash;
        env.CGO_ENABLED = 0;
      };
    in
    pkgs.symlinkJoin {
      name = "gno-tools-${version}";
      paths = [
        root
        gnodev
      ];
      passthru = {
        inherit gnodev root src;
        inherit version;
      };
    };

  releaseVersion = "1.5.0";
  releaseHashes = {
    gno = {
      "aarch64-darwin" = "sha256-gewtLcxBNzW0GEBWMC0XqentzrNGgxepBh73OyeS4MM=";
      "x86_64-darwin" = "sha256-LylGI+LsLg+mXg2nzYHL+na2y74dZnj1Pm20MTOo6Nk=";
      "aarch64-linux" = "sha256-4JZabKMTeL4OwOHHTf3iJiapiAWTdML8z60n+jybLiE=";
      "x86_64-linux" = "sha256-Zk0WBe+LRRxerHyYAHvxu5VbG84Sr+QtqcJoSpiOaQk=";
    };
    gnokey = {
      "aarch64-darwin" = "sha256-qGOk6PrYxLXKgmnpIqXz+Qku5Wy9oMPAMYAGtGDVEbk=";
      "x86_64-darwin" = "sha256-fu1egumi7GJlA44Y7ALRD+LySzhN/8lEvL3zreT+s28=";
      "aarch64-linux" = "sha256-qHl8xt99rO7Jc8T3ge3bnzTQd37wcV5FCEntTnqavrs=";
      "x86_64-linux" = "sha256-h462WZFh9JGjf9y9QhRHetKNXWII+EKPC//NMRXNNbQ=";
    };
    gnoland = {
      "aarch64-darwin" = "sha256-iungqGlsNdmWYJCn4VYCLH3mlOH7vPAam6BY6ngMQas=";
      "x86_64-darwin" = "sha256-WvhuMvXZF5TwMulHyA3G/K3MEaAuOuHjLePOhNqL3gE=";
      "aarch64-linux" = "sha256-3eO7OQwt+fGOL3dsJAu4PDI1gTHH29vgSnFoVfV5t6U=";
      "x86_64-linux" = "sha256-jc/0giiogeOY0jjj4UdgwXXIcvsWToXyHltO6UqLB20=";
    };
    gnodev = {
      "aarch64-darwin" = "sha256-hLbb39QNpTPPX5rgYpfboevtMrX0tTTUgCixgJn9WVc=";
      "x86_64-darwin" = "sha256-I4Bkt8/I4myO6TYhkVhnybFKDC3pvoVYZm9Ney9e6eU=";
      "aarch64-linux" = "sha256-COgPywFaaVrDdtCh+zJqggbvwCKHuu8Y7Hr1urLeZG0=";
      "x86_64-linux" = "sha256-v9dG551njDLlpUTO35Pt0gz3aqtMHUved/lZMFq491M=";
    };
    gnoweb = {
      "aarch64-darwin" = "sha256-JYq/2dahYgsGezkp4DqxgdQvfk+qw5XlZnPcgWllAYQ=";
      "x86_64-darwin" = "sha256-70GSxmuRP+nrKhYIzduFN0i79GPNyAf3ptDRsh1GosY=";
      "aarch64-linux" = "sha256-j+TbUsXO2PRhaOJix7oiOo6wIGuhzEPVu90Y2Rm+zaw=";
      "x86_64-linux" = "sha256-LlyugAhd8pmUl3sR2DO31+J53fx2PtwJ7PWVpgNdg/w=";
    };
  };
in
{
  gnoFromRelease = gnoFromRelease;
  gnoFromSource = gnoFromSource;

  gno-tools = gnoFromRelease {
    version = releaseVersion;
    hashes = releaseHashes;
  };
}
