{ config, lib, ... }:

{
  imports = [
    ./claude.nix
    ./codex.nix
    ./grok-code.nix
    ./opencode.nix
    (lib.mkRenamedOptionModule [ "modules" "ai" "claude" "linkConfig" ] [ "modules" "ai" "linkConfig" ])
    (lib.mkRenamedOptionModule [ "modules" "ai" "claude" "repoPath" ] [ "modules" "ai" "repoPath" ])
  ];

  options.modules.ai = {
    linkConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Symlink ai/ into ~/.claude, ~/.codex and ~/.config/opencode. Turn this
        off on machines that have no clone of this repo at
        {option}`modules.ai.repoPath`, otherwise the links dangle.
      '';
    };

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/go/src/github.com/albttx/nixpkgs";
      example = "/root/go/src/github.com/albttx/nixpkgs";
      description = "Working-tree path of this repo, used as the link target.";
    };
  };
}
