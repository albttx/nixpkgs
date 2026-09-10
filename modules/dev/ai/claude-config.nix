{ config, pkgs, ... }:

{
  # Claude Code configuration lives in this repo under ai/ and is symlinked into
  # ~/.claude. Skills are knowledge, agents are isolation: most per-technology
  # conventions are skills, and only the boundaries (MCP-holding devops, the
  # noisy osint tooling, the read-only reviewer) stay agents.
  #
  # recursive = true so each file is linked individually and ~/.claude itself
  # stays writable: Claude Code writes settings, history and plugin state there,
  # and unrelated skills installed by plugins survive.
  #
  # Caveat: because it links alongside rather than replacing the directory,
  # home-manager will NOT remove files left by the old agents/install.sh
  # (go-specialist.md, son-of-albert.md, the flat albttx-guideline.md, ...).
  # Those carry guidance the new skills deliberately reverse, so clear them once:
  #
  #   ./ai/install.sh --dry-run   # lists exactly what it would prune
  #   ./ai/install.sh
  home.file = {
    ".claude/CLAUDE.md".source = ../../../ai/CLAUDE.md;

    ".claude/skills" = {
      source = ../../../ai/skills;
      recursive = true;
    };

    ".claude/agents" = {
      source = ../../../ai/agents;
      recursive = true;
    };
  };
}
