#!/usr/bin/env bash
# Hook: PostToolUse | Matcher: Edit|Write|NotebookEdit
# Logs every file-modifying tool call to .claude/edit-log.jsonl.
#
# Shared via symlink from claude-code-config repo.
# Wire in .claude/settings.json under hooks.PostToolUse with matcher "Edit|Write|NotebookEdit"
# Add .claude/edit-log.jsonl to your .gitignore

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')

case "$TOOL" in
  Edit|Write|NotebookEdit) ;;
  *) exit 0 ;;
esac

LOG_FILE="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")/.claude/edit-log.jsonl"

jq -c \
  --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --arg tool "$TOOL" \
  '{
    timestamp: $ts,
    tool: $tool,
    file: (.tool_input.file_path // .tool_input.notebook_path // "unknown")
  }' <<< "$INPUT" >> "$LOG_FILE"
