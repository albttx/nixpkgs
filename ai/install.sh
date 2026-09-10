#!/usr/bin/env bash
#
# Fallback installer for non-nix machines.
#
# On nix machines this is handled declaratively by
# modules/dev/ai/claude-config.nix, which symlinks ai/ into ~/.claude.
# Use this script only where home-manager is not available.
#
# Layout installed:
#   ~/.claude/CLAUDE.md          <- ai/CLAUDE.md
#   ~/.claude/skills/<name>/     <- ai/skills/<name>/   (directories)
#   ~/.claude/agents/<name>.md   <- ai/agents/<name>.md (files)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_TARGET="$CLAUDE_HOME/skills"
AGENTS_TARGET="$CLAUDE_HOME/agents"

DRY_RUN=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true

run() {
    if [ "$DRY_RUN" = true ]; then
        return 0
    fi
    "$@"
}

# The old agents/install.sh flattened agents/*/agents/*.md into ~/.claude/agents/
# and agents/_shared/skills/*.md into ~/.claude/skills/. Those stale files carry
# guidance the new skills deliberately reverse (Echo over chi, testify, yarn over
# the lockfile) and a son-of-albert delegation table for agents that no longer
# exist. Remove exactly those names, nothing else.
LEGACY_AGENTS=(
    cosmos-specialist.md
    docs-specialist.md
    frontend-react-specialist.md
    frontend-svelte-specialist.md
    go-specialist.md
    nix-specialist.md
    nodejs-specialist.md
    postgres-specialist.md
    seo-specialist.md
    son-of-albert.md
)

# Flat .md skills from the old layout, now directories under skills/<name>/.
LEGACY_SKILLS=(
    agentcash.md
    albttx-guideline.md
)

prune_legacy() {
    local removed=0

    for name in "${LEGACY_AGENTS[@]}"; do
        local target="$AGENTS_TARGET/$name"
        [ -f "$target" ] || continue
        run rm -f "$target"
        echo "  prune agents/$name (superseded by a skill)"
        removed=$((removed + 1))
    done

    for name in "${LEGACY_SKILLS[@]}"; do
        local target="$SKILLS_TARGET/$name"
        [ -f "$target" ] || continue
        run rm -f "$target"
        echo "  prune skills/$name (now a directory)"
        removed=$((removed + 1))
    done

    if [ "$removed" -eq 0 ]; then
        echo "  Nothing to prune."
    else
        echo "  Pruned: $removed."
    fi
}

install_claude_md() {
    local src="$SCRIPT_DIR/CLAUDE.md"
    local dst="$CLAUDE_HOME/CLAUDE.md"

    if [ ! -f "$src" ]; then
        echo "  ERROR ai/CLAUDE.md is missing" >&2
        return 1
    fi

    if [ -f "$dst" ] && diff -q "$src" "$dst" >/dev/null 2>&1; then
        echo "  skip  CLAUDE.md (unchanged)"
        return 0
    fi

    run mkdir -p "$CLAUDE_HOME"
    run cp "$src" "$dst"
    echo "  copy  CLAUDE.md -> $dst"
}

# Skills are directories: ai/skills/<name>/SKILL.md plus any supporting files.
install_skills() {
    local installed=0 skipped=0

    run mkdir -p "$SKILLS_TARGET"

    for dir in "$SCRIPT_DIR"/skills/*/; do
        [ -d "$dir" ] || continue

        local name target
        name="$(basename "$dir")"
        target="$SKILLS_TARGET/$name"

        if [ ! -f "$dir/SKILL.md" ]; then
            echo "  WARN  skills/$name has no SKILL.md, skipping" >&2
            continue
        fi

        if [ -d "$target" ] && diff -rq "$dir" "$target" >/dev/null 2>&1; then
            echo "  skip  skills/$name (unchanged)"
            skipped=$((skipped + 1))
            continue
        fi

        # Replace wholesale so a file deleted from the repo also disappears here.
        run rm -rf "$target"
        run mkdir -p "$target"
        run cp -R "$dir." "$target/"
        echo "  copy  skills/$name -> $target"
        installed=$((installed + 1))
    done

    echo "  Skills: $installed installed, $skipped unchanged."
}

install_agents() {
    local installed=0 skipped=0

    run mkdir -p "$AGENTS_TARGET"

    for file in "$SCRIPT_DIR"/agents/*.md; do
        [ -f "$file" ] || continue

        local name target
        name="$(basename "$file")"
        target="$AGENTS_TARGET/$name"

        if [ -f "$target" ] && diff -q "$file" "$target" >/dev/null 2>&1; then
            echo "  skip  agents/$name (unchanged)"
            skipped=$((skipped + 1))
            continue
        fi

        run cp "$file" "$target"
        echo "  copy  agents/$name -> $target"
        installed=$((installed + 1))
    done

    echo "  Agents: $installed installed, $skipped unchanged."
}

if [ "$DRY_RUN" = true ]; then
    echo "Dry run, nothing will be written."
    echo ""
fi

echo "Pruning the old flat layout..."
prune_legacy

echo ""
echo "Installing CLAUDE.md..."
install_claude_md

echo ""
echo "Installing skills..."
install_skills

echo ""
echo "Installing agents..."
install_agents

echo ""
echo "Installed skills:"
for d in "$SKILLS_TARGET"/*/; do
    [ -d "$d" ] && echo "  - $(basename "$d")"
done

echo ""
echo "Installed agents:"
for f in "$AGENTS_TARGET"/*.md; do
    [ -f "$f" ] && echo "  - $(basename "$f" .md)"
done
