Install the global `/init-config` command so it is available in any project.

Instructions:
1. This command must be run from within the `claude-code-config` repository.
2. Copy the `init-config.md` template to the global commands directory:
   ```bash
   mkdir -p ~/.claude/commands
   cp commands/init-config.md ~/.claude/commands/init-config.md
   ```
3. Confirm success:
   - Verify `~/.claude/commands/init-config.md` exists
   - Tell the user: `/init-config` is now available globally. Run it from any project to link shared configuration.
