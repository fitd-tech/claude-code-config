#!/usr/bin/env bash
# sync.sh — Detect and repair broken symlinks, offer new files
# Usage: ./sync.sh [--fix]

set -euo pipefail

CONFIG_REPO="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$(pwd)"
CLAUDE_DIR="$TARGET_DIR/.claude"

AUTO_FIX=false
[[ "${1:-}" = "--fix" ]] && AUTO_FIX=true

if [ ! -d "$CLAUDE_DIR" ]; then
  echo "No .claude/ directory found in $TARGET_DIR"
  exit 0
fi

echo ""
echo "=== Sync Config ==="
echo "Config repo: $CONFIG_REPO"
echo "Target:      $TARGET_DIR"
echo ""

ISSUES=0

# --- Check for broken symlinks ---
BROKEN=()
BROKEN_NAMES=()

while IFS= read -r -d '' link; do
  target="$(readlink "$link" 2>/dev/null || true)"
  if [[ "$target" == "$CONFIG_REPO/"* ]] && [ ! -e "$target" ]; then
    BROKEN+=("$link")
    BROKEN_NAMES+=("$(basename "$link")")
  fi
done < <(find "$CLAUDE_DIR" -type l -print0 2>/dev/null)

if [ ${#BROKEN[@]} -gt 0 ]; then
  echo "Broken symlinks (target removed from config repo):"
  for i in "${!BROKEN[@]}"; do
    rel="${BROKEN[$i]#$TARGET_DIR/}"
    echo "  $((i+1)). $rel -> $(readlink "${BROKEN[$i]}")"
  done
  echo ""

  if $AUTO_FIX; then
    for link in "${BROKEN[@]}"; do
      rm "$link"
      echo "  Removed: ${link#$TARGET_DIR/}"
    done
  else
    echo "Actions: (r)emove broken symlinks, (s)kip"
    read -rp "> " ACTION
    if [[ "$ACTION" =~ ^[Rr] ]]; then
      for link in "${BROKEN[@]}"; do
        rm "$link"
        echo "  Removed: ${link#$TARGET_DIR/}"
      done
    else
      echo "  Skipped."
    fi
  fi
  ISSUES=$((ISSUES + ${#BROKEN[@]}))
  echo ""
fi

# --- Check for renamed files (broken symlink name matches a new file) ---
# Collect all currently linked files
LINKED_SOURCES=()
while IFS= read -r -d '' link; do
  target="$(readlink "$link" 2>/dev/null || true)"
  if [[ "$target" == "$CONFIG_REPO/"* ]] && [ -e "$target" ]; then
    LINKED_SOURCES+=("$target")
  fi
done < <(find "$CLAUDE_DIR" -type l -print0 2>/dev/null)

# --- Discover new files not yet linked ---
NEW_FILES=()

check_new() {
  local file="$1"
  local source="$CONFIG_REPO/$file"

  # Already linked?
  for ls in "${LINKED_SOURCES[@]+"${LINKED_SOURCES[@]}"}"; do
    [ "$ls" = "$source" ] && return
  done

  NEW_FILES+=("$file")
}

# Check config files
for f in CLAUDE.md settings.json; do
  [ -f "$CONFIG_REPO/$f" ] && check_new "$f"
done

# Check hooks
for f in "$CONFIG_REPO"/hooks/*.sh; do
  [ -f "$f" ] && check_new "hooks/$(basename "$f")"
done

# Check commands (exclude install.md, init-config.md)
for f in "$CONFIG_REPO"/commands/*.md; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  [[ "$base" = "install.md" || "$base" = "init-config.md" ]] && continue
  check_new "commands/$base"
done

if [ ${#NEW_FILES[@]} -gt 0 ]; then
  echo "New files in config repo (not yet linked):"
  for i in "${!NEW_FILES[@]}"; do
    echo "  $((i+1)). ${NEW_FILES[$i]}"
  done
  echo ""

  if ! $AUTO_FIX; then
    echo "Link new files? Enter numbers (space-separated), 'a' for all, or Enter to skip:"
    read -rp "> " INPUT

    if [ -n "$INPUT" ]; then
      INDICES=()
      if [ "$INPUT" = "a" ]; then
        for i in "${!NEW_FILES[@]}"; do INDICES+=("$i"); done
      else
        for num in $INPUT; do INDICES+=("$((num - 1))"); done
      fi

      for idx in "${INDICES[@]}"; do
        if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#NEW_FILES[@]} ]; then
          file="${NEW_FILES[$idx]}"
          source="$CONFIG_REPO/$file"
          case "$file" in
            CLAUDE.md)     target="$CLAUDE_DIR/CLAUDE.md" ;;
            settings.json) target="$CLAUDE_DIR/settings.json" ;;
            *)             target="$CLAUDE_DIR/$file" ;;
          esac
          mkdir -p "$(dirname "$target")"
          ln -sf "$source" "$target"
          echo "  Linked: $file"
        fi
      done
    else
      echo "  Skipped."
    fi
  fi
  ISSUES=$((ISSUES + ${#NEW_FILES[@]}))
  echo ""
fi

if [ $ISSUES -eq 0 ]; then
  echo "Everything is in sync."
fi
