{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # Ansible suite tools
    ansible
    ansible-lint

    ctop

    ipcalc

    pkgs-master.nomad
    pkgs-master.nomad-pack

    pkgs-master.terraform

    postgresql

    lz4

    nmap

    awscli2
    minio-client
    scaleway-cli

    speedtest-cli

    ## tfreveal
    (pkgs-master.buildGo124Module {
      pname = "tfreveal";
      version = "v0.0.4";
      src = pkgs.fetchFromGitHub {
        owner = "breml";
        repo = "tfreveal";
        rev = "v0.0.4";
        sha256 = "sha256-Bd6AYQZcVGHWjubax9v/guRPFoONSrfOqY23wrzA/ts=";
      };
      lsFlags = [ "-mod=mod" ];
      vendorHash = "sha256-lxYR29P6XvRF+qQ1/Z0TG/hFOcraNBJFdWBkpSiRVt8=";
    })

    ## tmtop
    (pkgs-master.buildGoModule {
      pname = "tmtop";
      version = "v2.1.0";
      src = pkgs.fetchFromGitHub {
        owner = "QuokkaStake";
        repo = "tmtop";
        rev = "v2.1.0";
        sha256 = "sha256-1Vq25HToIfrUcB0mGPsKTExupR3DsWZirGIuyX2uuWY=";
      };
      subPackages = [ "cmd" ];
      lsFlags = [ "-mod=mod" ];
      vendorHash = "sha256-bXUg4mE5Cy0uKr095n2uvryDo3+LV/QP0XS/oiXe8+0=";

      # Custom install phase to rename the binary
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mv $GOPATH/bin/cmd $out/bin/tmtop
        runHook postInstall
      '';
    })

  ];

}
