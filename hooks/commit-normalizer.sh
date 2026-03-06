#!/usr/bin/env bash
# Hook: PreToolUse | Matcher: Bash
# Blocks git commit commands whose messages don't follow conventional commit format.
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

if ! echo "$COMMAND" | grep -q 'git commit'; then
  echo '{}'
  exit 0
fi

MSG=$(echo "$COMMAND" | sed -n "s/.*-m ['\"]\\(.*\\)['\"].*/\\1/p" | head -1)

if [ -z "$MSG" ]; then
  echo '{}'
  exit 0
fi

SUBJECT=$(echo "$MSG" | head -1)

TYPES="feat|fix|chore|docs|style|refactor|test|perf|ci|build|revert"
PATTERN="^($TYPES)(\([a-zA-Z0-9_/-]+\))?: .+"

if echo "$SUBJECT" | grep -Eiq "$PATTERN"; then
  echo '{}'
else
  REASON="Commit message does not follow conventional commit format.

Subject: \"$SUBJECT\"

Required format:  type(scope): description
                  type: description

Valid types: feat, fix, chore, docs, style, refactor, test, perf, ci, build, revert

Examples:
  feat: add login page
  fix(auth): handle expired tokens
  chore: update dependencies"

  echo "{\"decision\": \"block\", \"reason\": $(echo "$REASON" | jq -Rs .)}"
fi
