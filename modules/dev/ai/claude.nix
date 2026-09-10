{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.ai.claude;

  link = config.lib.file.mkOutOfStoreSymlink;
  aiPath = "${cfg.repoPath}/ai";

  # Enumerated from the store copy of the flake, so adding a skill needs a
  # `make switch` to create its link. The link targets are working-tree paths.
  skills = lib.attrNames (
    lib.filterAttrs (_: t: t == "directory") (builtins.readDir ../../../ai/skills)
  );

  agents = map (lib.removeSuffix ".md") (
    lib.attrNames (
      lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".md" n) (
        builtins.readDir ../../../ai/agents
      )
    )
  );

in
{
  options.modules.ai.claude = {
    linkConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Symlink ai/ into ~/.claude. Turn this off on machines that have no
        clone of this repo at {option}`modules.ai.claude.repoPath`, otherwise
        the links dangle.
      '';
    };

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/go/src/github.com/albttx/nixpkgs";
      example = "/root/go/src/github.com/albttx/nixpkgs";
      description = "Working-tree path of this repo, used as the link target.";
    };
  };

  config = {
    # From master: claude-code moves too fast for the stable channel.
    home.packages = [ pkgs.pkgs-master.claude-code ];

    # Links point at the working tree, not the nix store, so a skill edited
    # mid-task is live immediately and shows up as a git change here.
    #
    # A store symlink would be read-only. The write-new-then-rename that most
    # editors (and `sed -i`) perform would replace it with a real file, which
    # succeeds, and the next `make switch` would then quietly move that file
    # aside as .backup and re-link. The change would look applied, then vanish.
    #
    # ~/.claude/skills and ~/.claude/agents stay real directories, so
    # plugin-installed skills living alongside these are untouched.
    home.file = lib.mkIf cfg.linkConfig (
      {
        ".claude/CLAUDE.md".source = link "${aiPath}/CLAUDE.md";
      }
      // lib.listToAttrs (
        map (n: lib.nameValuePair ".claude/skills/${n}" { source = link "${aiPath}/skills/${n}"; }) skills
      )
      // lib.listToAttrs (
        map (
          n: lib.nameValuePair ".claude/agents/${n}.md" { source = link "${aiPath}/agents/${n}.md"; }
        ) agents
      )
    );
  };
}
