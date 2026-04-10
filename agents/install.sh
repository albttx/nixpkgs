#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_TARGET="$HOME/.claude/agents"
SKILLS_TARGET="$HOME/.claude/skills"

mkdir -p "$AGENTS_TARGET" "$SKILLS_TARGET"

install_files() {
    local subdir="$1"
    local target="$2"
    local label="$3"
    local installed=0
    local skipped=0

    while IFS= read -r file; do
        [ -z "$file" ] && continue
        name="$(basename "$file")"
        relative="${file#"$SCRIPT_DIR"/}"

        if [ -f "$target/$name" ] && diff -q "$file" "$target/$name" > /dev/null 2>&1; then
            echo "  skip  $relative (unchanged)"
            skipped=$((skipped + 1))
            continue
        fi

        cp "$file" "$target/$name"
        echo "  copy  $relative -> $target/$name"
        installed=$((installed + 1))
    done < <(find "$SCRIPT_DIR" -type f -name "*.md" | while read -r f; do
        [ "$(basename "$(dirname "$f")")" = "$subdir" ] && echo "$f"
    done | sort)

    echo "  $label: $installed installed, $skipped unchanged."
}

echo "Installing agents..."
install_files "agents" "$AGENTS_TARGET" "Agents"

echo ""
echo "Installing skills..."
install_files "skills" "$SKILLS_TARGET" "Skills"

echo ""
echo "Installed agents:"
ls -1 "$AGENTS_TARGET"/*.md 2>/dev/null | while read -r f; do echo "  - $(basename "$f")"; done

echo ""
echo "Installed skills:"
ls -1 "$SKILLS_TARGET"/*.md 2>/dev/null | while read -r f; do echo "  - $(basename "$f")"; done
