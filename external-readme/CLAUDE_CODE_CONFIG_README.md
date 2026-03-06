# Claude Code — Managed Configuration

This project's `.claude/` directory is managed by the shared Claude Code config repo.
Symlinked files are kept in sync automatically. Do not edit them directly — changes
will be overwritten on the next sync.

## Managing this configuration

| Command | What it does |
|---------|--------------|
| `/sync-config` | Detect and repair symlink drift |
| `/init-config` | Re-run setup to add or change linked components |

## Local overrides

- `.claude/settings.local.json` — Personal settings (gitignored, never committed)
- `./CLAUDE.md` (project root) — Project-specific instructions for Claude

## Ejecting

To remove all managed symlinks and take ownership of the config files, run `unlink.sh`
from the config repo. See the config repo for full instructions.
