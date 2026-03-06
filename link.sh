#!/usr/bin/env bash
# link.sh — Interactive symlink creator for Claude Code configuration
# Usage: ./link.sh [--config <profile>] [--all]

set -euo pipefail

CONFIG_REPO="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$(pwd)"
CLAUDE_DIR="$TARGET_DIR/.claude"

# --- Argument parsing ---
PROFILE=""
AUTO_ALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) PROFILE="$2"; shift 2 ;;
    --all)    AUTO_ALL=true; shift ;;
    *)        echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Helpers ---
print_header() {
  echo ""
  echo "=== $1 ==="
  echo ""
}

# --- Step 1: Config profile selection ---
print_header "Claude Code Config Linker"
echo "Config repo:  $CONFIG_REPO"
echo "Target:       $TARGET_DIR"
echo ""

# Discover profiles
PROFILES=()
for f in "$CONFIG_REPO"/configs/*.md; do
  [ -f "$f" ] && PROFILES+=("$(basename "$f" .md)")
done

if [ ${#PROFILES[@]} -eq 0 ]; then
  echo "Error: no profiles found in $CONFIG_REPO/configs/"
  exit 1
fi

if [ -z "$PROFILE" ]; then
  echo "Available profiles:"
  for i in "${!PROFILES[@]}"; do
    DEFAULT_TAG=""
    [ "${PROFILES[$i]}" = "main" ] && DEFAULT_TAG=" (default)"
    echo "  $((i+1)). ${PROFILES[$i]}$DEFAULT_TAG"
  done
  echo ""
  read -rp "Select profile [1]: " CHOICE
  CHOICE="${CHOICE:-1}"
  PROFILE="${PROFILES[$((CHOICE-1))]}"
fi

PROFILE_FILE="$CONFIG_REPO/configs/$PROFILE.md"
if [ ! -f "$PROFILE_FILE" ]; then
  echo "Error: profile '$PROFILE' not found at $PROFILE_FILE"
  exit 1
fi

echo "Using profile: $PROFILE"

# --- Parse profile: extract files from ## Files section ---
PROFILE_FILES=()
IN_FILES=false
while IFS= read -r line; do
  if [[ "$line" =~ ^##[[:space:]]+Files ]]; then
    IN_FILES=true
    continue
  fi
  if $IN_FILES; then
    [[ "$line" =~ ^## ]] && break
    if [[ "$line" =~ ^-[[:space:]]+(.*) ]]; then
      PROFILE_FILES+=("${BASH_REMATCH[1]}")
    fi
  fi
done < "$PROFILE_FILE"

# --- Discover all linkable files ---
# Categories: config files, hooks, commands
ALL_FILES=()
CATEGORIES=()

# Config files (top-level)
for f in CLAUDE.md settings.json; do
  if [ -f "$CONFIG_REPO/$f" ]; then
    ALL_FILES+=("$f")
    CATEGORIES+=("config")
  fi
done

# Hooks
for f in "$CONFIG_REPO"/hooks/*.sh; do
  if [ -f "$f" ]; then
    name="hooks/$(basename "$f")"
    ALL_FILES+=("$name")
    CATEGORIES+=("hooks")
  fi
done

# Commands (exclude install.md and init-config.md)
for f in "$CONFIG_REPO"/commands/*.md; do
  if [ -f "$f" ]; then
    base="$(basename "$f")"
    [[ "$base" = "install.md" || "$base" = "init-config.md" ]] && continue
    name="commands/$base"
    ALL_FILES+=("$name")
    CATEGORIES+=("commands")
  fi
done

if [ ${#ALL_FILES[@]} -eq 0 ]; then
  echo "Error: no linkable files found in config repo"
  exit 1
fi

# --- Build selection state ---
# 1=selected, 0=deselected, D=disabled (already linked)
SELECTED=()
STATUS=()  # "", "[linked]", "[exists]"

for i in "${!ALL_FILES[@]}"; do
  file="${ALL_FILES[$i]}"

  # Determine target path
  case "$file" in
    CLAUDE.md)        target="$CLAUDE_DIR/CLAUDE.md" ;;
    settings.json)    target="$CLAUDE_DIR/settings.json" ;;
    hooks/*)          target="$CLAUDE_DIR/$file" ;;
    commands/*)       target="$CLAUDE_DIR/$file" ;;
    *)                target="$CLAUDE_DIR/$file" ;;
  esac

  # Check current state
  if [ -L "$target" ]; then
    link_target="$(readlink "$target" 2>/dev/null || true)"
    if [[ "$link_target" == "$CONFIG_REPO/"* ]]; then
      SELECTED+=("D")
      STATUS+=("[linked]")
      continue
    fi
  fi

  if [ -e "$target" ]; then
    STATUS+=("[exists]")
  else
    STATUS+=("")
  fi

  # Pre-select if in profile
  found=false
  for pf in "${PROFILE_FILES[@]}"; do
    if [ "$pf" = "$file" ]; then
      found=true
      break
    fi
  done
  $found && SELECTED+=("1") || SELECTED+=("0")
done

# --- Step 2: File selection ---
if ! $AUTO_ALL; then
  while true; do
    print_header "Select files to link"
    current_cat=""
    for i in "${!ALL_FILES[@]}"; do
      cat="${CATEGORIES[$i]}"
      if [ "$cat" != "$current_cat" ]; then
        echo ""
        echo "  -- ${cat^^} --"
        current_cat="$cat"
      fi

      if [ "${SELECTED[$i]}" = "D" ]; then
        echo "  -  ${ALL_FILES[$i]}  ${STATUS[$i]}"
      elif [ "${SELECTED[$i]}" = "1" ]; then
        echo "  $((i+1)). [x] ${ALL_FILES[$i]}  ${STATUS[$i]}"
      else
        echo "  $((i+1)). [ ] ${ALL_FILES[$i]}  ${STATUS[$i]}"
      fi
    done

    echo ""
    echo "Toggle by number (space-separated), 'a' for all, Enter to confirm:"
    read -rp "> " INPUT

    [ -z "$INPUT" ] && break

    if [ "$INPUT" = "a" ]; then
      for i in "${!ALL_FILES[@]}"; do
        [ "${SELECTED[$i]}" != "D" ] && SELECTED[$i]="1"
      done
      continue
    fi

    for num in $INPUT; do
      idx=$((num - 1))
      if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#ALL_FILES[@]} ]; then
        if [ "${SELECTED[$idx]}" = "D" ]; then
          echo "  (${ALL_FILES[$idx]} is already linked — skipping)"
        elif [ "${SELECTED[$idx]}" = "1" ]; then
          SELECTED[$idx]="0"
        else
          SELECTED[$idx]="1"
        fi
      fi
    done
  done
fi

# If --all, select everything not already linked
if $AUTO_ALL; then
  for i in "${!ALL_FILES[@]}"; do
    [ "${SELECTED[$i]}" != "D" ] && SELECTED[$i]="1"
  done
fi

# --- Step 3: Create symlinks ---
print_header "Linking files"

LINKED=()
SKIPPED=()

for i in "${!ALL_FILES[@]}"; do
  [ "${SELECTED[$i]}" != "1" ] && continue

  file="${ALL_FILES[$i]}"
  source="$CONFIG_REPO/$file"

  case "$file" in
    CLAUDE.md)        target="$CLAUDE_DIR/CLAUDE.md" ;;
    settings.json)    target="$CLAUDE_DIR/settings.json" ;;
    hooks/*)          target="$CLAUDE_DIR/$file" ;;
    commands/*)       target="$CLAUDE_DIR/$file" ;;
    *)                target="$CLAUDE_DIR/$file" ;;
  esac

  # Handle existing non-symlink files
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    if ! $AUTO_ALL; then
      read -rp "  $file exists and is not a symlink. Overwrite? [y/N] " CONFIRM
      if [[ ! "$CONFIRM" =~ ^[Yy] ]]; then
        SKIPPED+=("$file (exists, not overwritten)")
        continue
      fi
    else
      SKIPPED+=("$file (exists, use interactive mode to overwrite)")
      continue
    fi
    rm "$target"
  fi

  # Create parent directory
  mkdir -p "$(dirname "$target")"

  # Create symlink
  ln -sf "$source" "$target"
  LINKED+=("$file -> $source")
done

# --- Step 4: Update .gitignore ---
GITIGNORE="$TARGET_DIR/.gitignore"
IGNORE_ENTRIES=(".claude/settings.local.json" ".claude/edit-log.jsonl" "CLAUDE_CODE_CONFIG_README.md")

for entry in "${IGNORE_ENTRIES[@]}"; do
  if [ -f "$GITIGNORE" ]; then
    grep -qxF "$entry" "$GITIGNORE" 2>/dev/null || echo "$entry" >> "$GITIGNORE"
  else
    echo "$entry" >> "$GITIGNORE"
  fi
done

# --- Summary ---
print_header "Summary"

if [ ${#LINKED[@]} -gt 0 ]; then
  echo "Linked:"
  for item in "${LINKED[@]}"; do
    echo "  + $item"
  done
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo ""
  echo "Skipped:"
  for item in "${SKIPPED[@]}"; do
    echo "  - $item"
  done
fi

echo ""
echo "Updated .gitignore with: ${IGNORE_ENTRIES[*]}"

# --- Root README symlink ---
ROOT_README_SRC="$CONFIG_REPO/external-readme/CLAUDE_CODE_CONFIG_README.md"
ROOT_README_DST="$TARGET_DIR/CLAUDE_CODE_CONFIG_README.md"
if [ -f "$ROOT_README_SRC" ]; then
  ln -sf "$ROOT_README_SRC" "$ROOT_README_DST"
  echo "Linked CLAUDE_CODE_CONFIG_README.md"
fi

echo ""
echo "Done. Config repo: $CONFIG_REPO"
