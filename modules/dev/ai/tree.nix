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

  # Codex reads agents as TOML, so these are hand-converted copies of agents,
  # not a third kind of agent.
  codexAgents = map (lib.removeSuffix ".toml") (
    lib.attrNames (
      lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".toml" n) (
        builtins.readDir ../../../ai/codex/agents
      )
    )
  );
}
