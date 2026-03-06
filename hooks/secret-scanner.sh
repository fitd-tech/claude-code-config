#!/usr/bin/env bash
# Hook: PreToolUse | Matcher: Bash
# Blocks Bash commands that appear to expose secrets.
#
# Shared via symlink from claude-code-config repo.
# Wire in .claude/settings.json under hooks.PreToolUse with matcher "Bash"

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')

if [ "$TOOL" != "Bash" ]; then
  echo '{}'
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

PATTERNS=(
  '(echo|print|printf).*\$(.*)(key|token|secret|password|passwd|credential|auth)'
  '(cat|head|tail|less|more)\s+.*\.(env|pem|key|p12|pfx)'
  '-H\s+.*(Authorization|Bearer|token)'
  '^(env|printenv|export)(\s+-\w+)?\s*$'
)

for PATTERN in "${PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -Eiq -- "$PATTERN"; then
    MSG="Blocked: command appears to expose secrets (matched pattern: $PATTERN). Review and run manually if intentional."
    echo "{\"decision\": \"block\", \"reason\": $(echo "$MSG" | jq -Rs .)}"
    exit 0
  fi
done

echo '{}'
