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

  inherit (import ./tree.nix { inherit lib; }) skills codexAgents;

in
{
  config = {
    # From master: codex moves too fast for the stable channel.
    home.packages = [ pkgs.pkgs-master.codex ];

    # Same working-tree links as claude.nix, under ~/.codex. CLAUDE.md doubles
    # as codex's global AGENTS.md, and skills are the Agent Skills standard, so
    # both link as-is. Agents are codex's own TOML format: committed files in
    # ai/codex/agents/, converted by hand from ai/agents/*.md, which stay the
    # reference.
    home.file = lib.mkIf cfg.linkConfig (
      {
        ".codex/AGENTS.md".source = link "${aiPath}/CLAUDE.md";
      }
      // lib.listToAttrs (
        map (n: lib.nameValuePair ".codex/skills/${n}" { source = link "${aiPath}/skills/${n}"; }) skills
      )
      // lib.listToAttrs (
        map (
          n: lib.nameValuePair ".codex/agents/${n}.toml" { source = link "${aiPath}/codex/agents/${n}.toml"; }
        ) codexAgents
      )
    );
  };
}
