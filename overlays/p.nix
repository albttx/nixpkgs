final: super:
let
  pkgs = super.pkgs;
in
{
  # Project switcher for a GOPATH-style source tree: https://github.com/albttx/p
  p = pkgs.buildGoModule {
    pname = "p";
    version = "0-unstable-2026-09-07";

    src = pkgs.fetchFromGitHub {
      owner = "albttx";
      repo = "p";
      rev = "10db109c295c705f8730905b3e0ee50b7cbe63cc";
      hash = "sha256-lcoFUzzVz7iE0XqH58wW/pX7mYyClZQUKs2d7BWfq7s=";
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
