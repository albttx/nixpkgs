final: super:
let
  pkgs = super.pkgs;
in
{
  # Project switcher for a GOPATH-style source tree: https://github.com/albttx/p
  p = pkgs.buildGoModule (finalAttrs: {
    pname = "p";
    version = "0.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "albttx";
      repo = "p";
      rev = "v${finalAttrs.version}";
      hash = "sha256-C+fHM+0wGAQgvyuLOO/F7RHe7MNwHkjBd5tiWUii6nw=";
    };

    vendorHash = "sha256-1oU2POF3UJ+PiliuwoAn2URosVvEi97uc92AcPCg97s=";

    subPackages = [ "cmd/p" ];

    env.CGO_ENABLED = 0;
    ldflags = [
      "-s"
      "-w"
      "-X main.version=${finalAttrs.version}"
    ];

    meta = with pkgs.lib; {
      description = "Project switcher for a GOPATH-style source tree, with tmux session-per-project";
      homepage = "https://github.com/albttx/p";
      mainProgram = "p";
    };
  });
}
