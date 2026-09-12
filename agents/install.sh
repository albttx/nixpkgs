#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_TARGET="$HOME/.claude/agents"
SKILLS_TARGET="$HOME/.claude/skills"
CODEX_AGENTS_TARGET="$HOME/.codex/agents"

mkdir -p "$AGENTS_TARGET" "$SKILLS_TARGET" "$CODEX_AGENTS_TARGET"

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

# Codex discovers custom agents as TOML files in ~/.codex/agents/, with
# name, description and developer_instructions fields. Generate them from
# the same markdown sources so the .md files stay the single source of
# truth. Claude-specific frontmatter (model, color, memory, skills,
# mcpServers) is dropped on purpose: a codex agent inherits the parent
# session's model and tooling.
install_codex_agents() {
    local installed=0
    local skipped=0

    while IFS= read -r file; do
        [ -z "$file" ] && continue
        relative="${file#"$SCRIPT_DIR"/}"

        name="$(awk '/^---$/{c++; next} c==1 && /^name:/{sub(/^name:[ \t]*/, ""); print; exit}' "$file")"
        if [ -z "$name" ]; then
            echo "  warn  $relative: no name in frontmatter, skipped"
            continue
        fi

        # YAML double-quoted scalars use the same \n and \" escapes as TOML
        # basic strings, so a quoted value is reused verbatim.
        description="$(awk '/^---$/{c++; next} c==1 && /^description:/{sub(/^description:[ \t]*/, ""); print; exit}' "$file")"
        case "$description" in
            \"*\") ;;
            *) description="\"$description\"" ;;
        esac

        target="$CODEX_AGENTS_TARGET/$name.toml"
        tmp="$(mktemp)"
        {
            echo "name = \"$name\""
            echo "description = $description"
            echo "developer_instructions = '''"
            awk '/^---$/{c++; next} c>=2' "$file"
            echo "'''"
        } > "$tmp"

        if [ -f "$target" ] && diff -q "$tmp" "$target" > /dev/null 2>&1; then
            echo "  skip  $relative (unchanged)"
            skipped=$((skipped + 1))
            rm -f "$tmp"
            continue
        fi

        mv "$tmp" "$target"
        echo "  gen   $relative -> $target"
        installed=$((installed + 1))
    done < <(find "$SCRIPT_DIR" -type f -name "*.md" | while read -r f; do
        [ "$(basename "$(dirname "$f")")" = "agents" ] && echo "$f"
    done | sort)

    echo "  Codex agents: $installed generated, $skipped unchanged."
}

echo "Installing agents..."
install_files "agents" "$AGENTS_TARGET" "Agents"

echo ""
echo "Installing codex agents..."
install_codex_agents

echo ""
echo "Installing skills..."
install_files "skills" "$SKILLS_TARGET" "Skills"

echo ""
echo "Installed agents:"
for f in "$AGENTS_TARGET"/*.md; do [ -e "$f" ] || continue; echo "  - $(basename "$f")"; done

echo ""
echo "Installed skills:"
for f in "$SKILLS_TARGET"/*.md; do [ -e "$f" ] || continue; echo "  - $(basename "$f")"; done

echo ""
echo "Installed codex agents:"
for f in "$CODEX_AGENTS_TARGET"/*.toml; do [ -e "$f" ] || continue; echo "  - $(basename "$f")"; done
