{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Ansible suite tools
    ansible
    ansible-lint

    ctop

    ipcalc

    nomad
    pkgs-master.nomad-pack

    nmap

    awscli2
    minio-client
    scaleway-cli

    ## tmtop
    (pkgs-master.buildGo122Module {
      pname = "tmtop";
      version = "v2.0.2";
      src = pkgs.fetchFromGitHub {
        owner = "QuokkaStake";
        repo = "tmtop";
        rev = "v2.0.2";
        sha256 = "sha256-n/vn7zHB5p/GTalDM+H92pZevyGmUHGsO1b/aQnEb1E=";
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
