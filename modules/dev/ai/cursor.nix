{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.ai;

  link = config.lib.file.mkOutOfStoreSymlink;
  aiPath = "${cfg.repoPath}/ai";

  inherit (import ./tree.nix { inherit lib; }) skills;

in
{
  config = {
    # Cursor (installed as a Homebrew cask) reads ~/.claude/skills and
    # ~/.codex/skills locally, but its cloud skill sync only copies
    # ~/.cursor/skills, so link the same working-tree skills there too.
    home.file = lib.mkIf cfg.linkConfig (
      lib.listToAttrs (
        map (n: lib.nameValuePair ".cursor/skills/${n}" { source = link "${aiPath}/skills/${n}"; }) skills
      )
    );
  };
}
