{ pkgs, ... }:

# Cloudflare's security-audit skill, pinned as a flake input and linked from
# the nix store. Unlike the working-tree skills in ai/skills/, this is
# upstream content: a store symlink stays read-only and updates with
# `nix flake update security-audit-skill`.
#
# Not gated on modules.ai.linkConfig. The source is a store path, so the
# links never dangle on machines without a clone of this repo.

let
  skill = pkgs.security-audit-skill;
in
{
  config = {
    home.file = {
      ".claude/skills/security-audit".source = skill;
      ".codex/skills/security-audit".source = skill;
      ".config/opencode/skills/security-audit".source = skill;
    };
  };
}
