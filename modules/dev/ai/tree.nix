# Inventory of the ai/ working tree. Paths are relative to this file.
{ lib }:

{
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
}
