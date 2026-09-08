final: super:
let
  pkgs = super.pkgs;
in
{
  # Project switcher for a GOPATH-style source tree: https://github.com/albttx/p
  p = pkgs.buildGoModule {
    pname = "p";
    version = "0-unstable-2026-09-08";

    src = pkgs.fetchFromGitHub {
      owner = "albttx";
      repo = "p";
      rev = "9a43a1515ce8df1222a283c77b3bbf7659f7f9ba";
      hash = "sha256-1Sz0cycwR971xaVGAfzNmFtr64ilq3m5VHgms5Xt9/0=";
    };

    vendorHash = "sha256-1oU2POF3UJ+PiliuwoAn2URosVvEi97uc92AcPCg97s=";

    subPackages = [ "cmd/p" ];

    env.CGO_ENABLED = 0;
    ldflags = [
      "-s"
      "-w"
    ];

    meta = with pkgs.lib; {
      description = "Project switcher for a GOPATH-style source tree, with tmux session-per-project";
      homepage = "https://github.com/albttx/p";
      mainProgram = "p";
    };
  };
}
