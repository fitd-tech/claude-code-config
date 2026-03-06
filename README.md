# claude-code-config

Shared Claude Code configuration distributed via symlinks. Edit once, propagate everywhere.

## Quick Start

```bash
# 1. Clone this repo
git clone <url> ~/claude-code-config
cd ~/claude-code-config

# 2. Install the global /init-config command (one-time)
claude
> /install

# 3. Link any project
cd ~/my-project && claude
> /init-config
```

## How It Works

Configuration files (hooks, commands, settings, shared CLAUDE.md) live in this repo. Projects get symlinks to these files, so edits here propagate instantly.

```
my-project/.claude/
  CLAUDE.md          -> ~/claude-code-config/CLAUDE.md
  settings.json      -> ~/claude-code-config/settings.json
  hooks/*.sh         -> ~/claude-code-config/hooks/*.sh
  commands/*.md      -> ~/claude-code-config/commands/*.md
  subagent-prompts.md   (copied, not symlinked — reference material)
```

Claude Code loads both `./CLAUDE.md` (project-specific) and `.claude/CLAUDE.md` (shared conventions).

## File Reference

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Shared conventions (commit format, code quality, review standards) |
| `settings.json` | Model default, hook wiring |
| `hooks/secret-scanner.sh` | PreToolUse — blocks commands exposing secrets |
| `hooks/commit-normalizer.sh` | PreToolUse — enforces conventional commits |
| `hooks/edit-logger.sh` | PostToolUse — logs file edits to JSONL |
| `commands/commit.md` | `/commit` — stage, commit, push |
| `commands/review.md` | `/review` — four-dimension code review |
| `commands/test.md` | `/test` — detect runner, run suite, report |
| `commands/sync-config.md` | `/sync-config` — detect and repair drift |
| `commands/install.md` | `/install` — one-time setup of global init-config |
| `commands/init-config.md` | Template for global `/init-config` command |
| `subagent-prompts.md` | Reference: 6 subagent prompt templates |
| `configs/main.md` | Profile: which files to link by default |
| `link.sh` | Interactive symlink creator |
| `unlink.sh` | Symlink remover (with copy option) |
| `sync.sh` | Drift detection and repair |

## Config Profiles

Profiles in `configs/` define which files get linked. The `main` profile includes everything. Create new profiles (e.g., `minimal.md`, `ci.md`) by listing a different subset of files under `## Files`.

## Per-Project Overrides

Symlinks give you the shared baseline. Override per-project using Claude Code's native layering:

| Override | How |
|----------|-----|
| Model, output style | `.claude/settings.local.json` (gitignored) |
| Extra hooks/commands | Add non-symlinked files alongside the symlinks |
| Project conventions | `./CLAUDE.md` in project root (project-specific context) |

## Eject

Replace symlinks with standalone copies:

```bash
cd ~/my-project
bash ~/claude-code-config/unlink.sh --copy
```

The project continues to work independently — no more dependency on this repo.

## Maintenance

Check for broken symlinks or new files:

```bash
# From a linked project
cd ~/my-project && claude
> /sync-config

# Or directly
cd ~/my-project && bash ~/claude-code-config/sync.sh
```

## Relationship to agentic-acedemia

This repo was extracted from the [agentic-acedemia](https://github.com/anthonypelusocook/agentic-acedemia) learning workspace. That repo documents the patterns; this repo distributes the runtime artifacts.
