Stage files, create a conventional commit, and push to the remote.

Arguments (optional): $ARGUMENTS

Instructions:
1. Run `git status` and `git diff` to review what has changed.
2. Assess whether the changes represent one logical unit of work or multiple. If the diff spans unrelated concerns, split into separate commits — one per concern — before pushing.
3. Stage only the files relevant to the first commit with `git add`.
4. Write a conventional commit message:
   - Format: `type(scope): description`
   - Valid types: feat, fix, chore, docs, style, refactor, test, perf, ci, build, revert
   - If arguments were provided, use them as guidance for the scope or message — otherwise infer from the diff.
5. Commit, then repeat steps 3-4 for any remaining changes.
6. Push all commits to the current branch.
