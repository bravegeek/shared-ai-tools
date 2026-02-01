#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$SCRIPT_DIR/agents"
SHARED_DIR="$SCRIPT_DIR/shared"

BEGIN_MARKER="<!-- BEGIN SHARED-AI-TOOLS -->"
END_MARKER="<!-- END SHARED-AI-TOOLS -->"

usage() {
  echo "Usage: $0 <project-directory>"
  echo "Syncs shared agents and instructions into a project."
  exit 1
}

[[ $# -lt 1 ]] && usage

TARGET="$1"

if [[ ! -d "$TARGET" ]]; then
  echo "Error: $TARGET is not a directory"
  exit 1
fi

# --- Sync agents ---

# Claude Code: .claude/agents/<name>.md
claude_agents="$TARGET/.claude/agents"
mkdir -p "$claude_agents"
for f in "$AGENTS_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  cp "$f" "$claude_agents/$(basename "$f")"
done
echo "Synced agents to $claude_agents"

# Gemini CLI: .gemini/skills/<name>/SKILL.md
gemini_skills="$TARGET/.gemini/skills"
mkdir -p "$gemini_skills"
for f in "$AGENTS_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  name="$(basename "$f" .md)"
  mkdir -p "$gemini_skills/$name"
  cp "$f" "$gemini_skills/$name/SKILL.md"
done
echo "Synced agents to $gemini_skills"

# --- Sync shared instructions ---

# Claude Code: .claude/shared/<name>.md
claude_shared="$TARGET/.claude/shared"
mkdir -p "$claude_shared"
for f in "$SHARED_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  cp "$f" "$claude_shared/$(basename "$f")"
done
echo "Synced shared instructions to $claude_shared"

# Gemini CLI: .gemini/shared/<name>.md + @references in GEMINI.md
gemini_shared="$TARGET/.gemini/shared"
mkdir -p "$gemini_shared"
ref_block="$BEGIN_MARKER"$'\n'
for f in "$SHARED_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  cp "$f" "$gemini_shared/$(basename "$f")"
  ref_block+="@.gemini/shared/$(basename "$f")"$'\n'
done
ref_block+="$END_MARKER"
echo "Synced shared instructions to $gemini_shared"

# Inject @references into GEMINI.md
gemini_md="$TARGET/GEMINI.md"
if [[ ! -f "$gemini_md" ]]; then
  echo "$ref_block" > "$gemini_md"
  echo "Created $gemini_md with shared references"
else
  if grep -qF "$BEGIN_MARKER" "$gemini_md"; then
    before="$(sed "/$BEGIN_MARKER/,\$d" "$gemini_md")"
    after="$(sed "1,/$END_MARKER/d" "$gemini_md")"
    printf '%s\n%s\n%s' "$before" "$ref_block" "$after" > "$gemini_md"
  else
    printf '\n%s\n' "$ref_block" >> "$gemini_md"
  fi
  echo "Injected shared references into $gemini_md"
fi

# Remove markers from CLAUDE.md if present (no longer needed)
claude_md="$TARGET/CLAUDE.md"
if [[ -f "$claude_md" ]] && grep -qF "$BEGIN_MARKER" "$claude_md"; then
  before="$(sed "/$BEGIN_MARKER/,\$d" "$claude_md")"
  after="$(sed "1,/$END_MARKER/d" "$claude_md")"
  printf '%s%s' "$before" "$after" > "$claude_md"
  echo "Removed old shared block from $claude_md"
fi

echo "Done."
