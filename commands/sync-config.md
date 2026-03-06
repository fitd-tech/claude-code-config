Detect and repair configuration drift between this project and the shared config repo.

Instructions:
1. Determine the config repo path by reading any existing symlink in `.claude/`:
   ```bash
   readlink .claude/settings.json 2>/dev/null || readlink .claude/CLAUDE.md 2>/dev/null
   ```
   Extract the repo root from the symlink target (everything before `/settings.json` or `/CLAUDE.md`).

2. If no symlinks found, inform the user that this project is not linked to a config repo.

3. Run the sync script from the config repo:
   ```bash
   bash <CONFIG_REPO_PATH>/sync.sh
   ```

4. Report what was found and fixed:
   - Broken symlinks (removed or re-linked)
   - New files available for linking
   - Current sync status
