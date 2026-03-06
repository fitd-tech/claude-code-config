Initialize this project with shared Claude Code configuration from the config repo.

Instructions:
1. Detect the config repo location. Check these in order:
   - If any symlink in `.claude/` already points to a config repo, use that path
   - Otherwise, check if `~/claude-code-config` exists
   - If not found, ask the user for the path

2. Ask which components to link:
   - All (default) — links settings, hooks, commands, and shared CLAUDE.md
   - Or let the user pick: settings, hooks, commands

3. Run the link script from the config repo:
   ```bash
   bash <CONFIG_REPO_PATH>/link.sh --config main --all
   ```
   Or for interactive selection:
   ```bash
   bash <CONFIG_REPO_PATH>/link.sh
   ```

4. Copy the subagent prompts reference file (as a real copy, not a symlink):
   ```bash
   cp <CONFIG_REPO_PATH>/subagent-prompts.md .claude/subagent-prompts.md
   ```

5. If `./CLAUDE.md` does not exist in the project root, generate a starter one:
   - Ask the user about their project (or detect from package.json/pyproject.toml/etc.)
   - Create a minimal `CLAUDE.md` with: project name, tech stack, build commands, project structure
   - This is the project-specific file (separate from `.claude/CLAUDE.md` which has shared conventions)

6. Print a summary of what was linked and what to do next:
   - List all symlinks created
   - Mention that `.claude/CLAUDE.md` has shared conventions
   - Mention that `./CLAUDE.md` is for project-specific context
   - Mention `.claude/settings.local.json` for personal overrides
   - Mention `/sync-config` to check for updates later
