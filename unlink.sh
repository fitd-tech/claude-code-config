#!/usr/bin/env bash
# unlink.sh — Remove symlinks to the config repo
# Usage: ./unlink.sh [--copy | --remove]

set -euo pipefail

CONFIG_REPO="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$(pwd)"
CLAUDE_DIR="$TARGET_DIR/.claude"

# --- Argument parsing ---
MODE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy)   MODE="copy"; shift ;;
    --remove) MODE="remove"; shift ;;
    *)        echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Find all symlinks pointing into config repo ---
SYMLINKS=()
SYMLINK_TARGETS=()

while IFS= read -r -d '' link; do
  target="$(readlink "$link" 2>/dev/null || true)"
  if [[ "$target" == "$CONFIG_REPO/"* ]]; then
    SYMLINKS+=("$link")
    SYMLINK_TARGETS+=("$target")
  fi
done < <(find "$CLAUDE_DIR" -type l -print0 2>/dev/null)

if [ ${#SYMLINKS[@]} -eq 0 ]; then
  echo "No symlinks pointing to $CONFIG_REPO found in $CLAUDE_DIR"
  exit 0
fi

# --- Selection ---
SELECTED=()
for i in "${!SYMLINKS[@]}"; do
  SELECTED+=("1")
done

if [ -z "$MODE" ]; then
  while true; do
    echo ""
    echo "=== Symlinks to config repo ==="
    echo ""
    for i in "${!SYMLINKS[@]}"; do
      rel="${SYMLINKS[$i]#$TARGET_DIR/}"
      if [ "${SELECTED[$i]}" = "1" ]; then
        echo "  $((i+1)). [x] $rel"
      else
        echo "  $((i+1)). [ ] $rel"
      fi
    done

    echo ""
    echo "Toggle by number (space-separated), Enter to confirm:"
    read -rp "> " INPUT

    [ -z "$INPUT" ] && break

    for num in $INPUT; do
      idx=$((num - 1))
      if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#SYMLINKS[@]} ]; then
        [ "${SELECTED[$idx]}" = "1" ] && SELECTED[$idx]="0" || SELECTED[$idx]="1"
      fi
    done
  done
fi

# --- Process selected symlinks ---
echo ""
echo "=== Processing ==="
echo ""

for i in "${!SYMLINKS[@]}"; do
  [ "${SELECTED[$i]}" != "1" ] && continue

  link="${SYMLINKS[$i]}"
  target="${SYMLINK_TARGETS[$i]}"
  rel="${link#$TARGET_DIR/}"

  action="$MODE"

  # If no global mode, ask per-file
  if [ -z "$action" ]; then
    read -rp "  $rel — (c)opy or (r)emove? [c/r] " CHOICE
    case "$CHOICE" in
      r|R) action="remove" ;;
      *)   action="copy" ;;
    esac
  fi

  if [ "$action" = "copy" ]; then
    if [ -f "$target" ]; then
      rm "$link"
      cp "$target" "$link"
      echo "  Copied:  $rel"
    else
      rm "$link"
      echo "  Removed: $rel (target missing, cannot copy)"
    fi
  else
    rm "$link"
    echo "  Removed: $rel"
  fi
done

echo ""
echo "Done."
