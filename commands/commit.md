Stage files, create a conventional commit, and push to the remote.

Arguments (optional): $ARGUMENTS

Instructions:
1. Run `git status` and `git diff` to review what has changed.
2. Review all untracked files from `git status`. For each untracked file, decide whether it belongs with the current work — if yes, include it in the appropriate commit. Do not silently skip untracked files; every untracked file must be either staged or explicitly left out with a reason.
3. Assess whether the changes (modified + untracked) represent one logical unit of work or multiple. If the diff spans unrelated concerns (e.g. a bug fix and a new feature, or changes to two independent experiments), split into separate commits — one per concern — before pushing.
4. Stage only the files relevant to the first commit with `git add`.
5. Write a conventional commit message following the project's commit conventions (see `.claude/skills/conventional-commit.md`). If arguments were provided, use them as guidance for the scope or message — otherwise infer from the diff.
6. Commit, then repeat steps 4–6 for any remaining changes.
7. Push all commits to the current branch.
