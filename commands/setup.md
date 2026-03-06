Bootstrap Claude Code configuration for the current project.

Instructions:
1. Read the codebase to detect:
   - Programming language(s)
   - Framework (if any)
   - Package manager
   - Test runner
   - Build tool
   - Project structure (key directories)
   - Existing conventions (from README, config files, existing code)

2. Generate `CLAUDE.md` at the project root:
   - Fill in the Tech Stack section with detected values
   - Fill in Build & Run with actual commands from package.json / Makefile / pyproject.toml / etc.
   - Fill in Project Structure with actual directories
   - Infer conventions from existing code patterns
   - Use `templates/CLAUDE.md` as the structural template

3. Create `.claude/settings.json`:
   - Use `templates/settings.json` as the base
   - Set the model to `claude-sonnet-4-6`
   - Wire the secret scanner and commit normalizer hooks

4. Create `.claude/hooks/` and copy hook scripts:
   - `secret-scanner.sh` from `templates/hooks/secret-scanner.sh`
   - `commit-normalizer.sh` from `templates/hooks/commit-normalizer.sh`
   - `edit-logger.sh` from `templates/hooks/edit-logger.sh`
   - Make all hooks executable with `chmod +x`

5. Create `.claude/commands/` and copy slash commands:
   - `commit.md` from `templates/commands/commit.md`
   - `review.md` from `templates/commands/review.md`
   - `test.md` from `templates/commands/test.md`

6. Update `.gitignore` to include:
   - `.claude/settings.local.json`
   - `.claude/edit-log.jsonl`
   Only add lines that are not already present.

7. Suggest additional configuration:
   - If the project uses a database, suggest an MCP server for it
   - If the project has a specific linting tool, suggest a lint hook
   - If there are environment variables, confirm `.env` is gitignored

8. Print a summary of what was created and any manual steps remaining.
