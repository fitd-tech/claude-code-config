# Shared Conventions

These conventions are shared across all linked projects via symlink from the config repo.

## Commit Conventions

- Use conventional commits: `type(scope): description`
- Valid types: feat, fix, chore, docs, style, refactor, test, perf, ci, build, revert
- Keep the subject line under 72 characters
- Use imperative mood ("add", not "added" or "adds")
- Scope is optional but encouraged for multi-module projects

## Code Quality

- Write tests for new features and bug fixes
- Keep functions small and focused — one responsibility per function
- Prefer clarity over cleverness
- Avoid over-engineering: only build what is needed now
- Do not add comments for self-evident code

## Review Standards

- Every change should be reviewable in terms of:
  - **Correctness** — logic errors, edge cases, off-by-one
  - **Security** — injection risks, exposed secrets, insecure defaults
  - **Clarity** — naming, structure, readability
  - **Simplicity** — dead code, premature abstractions

## File Hygiene

- Keep `.claude/settings.local.json` gitignored (personal overrides)
- Keep `.claude/edit-log.jsonl` gitignored (session audit trail)
- Do not commit secrets, credentials, or API keys
