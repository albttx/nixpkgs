{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.ai;

  link = config.lib.file.mkOutOfStoreSymlink;
  aiPath = "${cfg.repoPath}/ai";

  inherit (import ./tree.nix { inherit lib; }) skills agents;

in
{
  config = {
    # From master: opencode moves too fast for the stable channel.
    home.packages = [ pkgs.pkgs-master.opencode ];

    # Same working-tree links as claude.nix, under OpenCode's config dir.
    # Skills would also be picked up from ~/.claude/skills via Claude-compat,
    # but agents are not: those only load from ~/.config/opencode/agents/.
    home.file = lib.mkIf cfg.linkConfig (
      {
        ".config/opencode/AGENTS.md".source = link "${aiPath}/CLAUDE.md";
      }
      // lib.listToAttrs (
        map (
          n: lib.nameValuePair ".config/opencode/skills/${n}" { source = link "${aiPath}/skills/${n}"; }
        ) skills
      )
      // lib.listToAttrs (
        map (
          n: lib.nameValuePair ".config/opencode/agents/${n}.md" { source = link "${aiPath}/agents/${n}.md"; }
        ) agents
      )
    );
  };
}
