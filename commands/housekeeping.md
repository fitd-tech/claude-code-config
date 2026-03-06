# Housekeeping

Trim `CLAUDE.md` and `memory/MEMORY.md` to stay within their size limits.

Optional arguments (`$ARGUMENTS`): hints about which file to focus on or what to prioritize cutting (e.g., "trim memory only", "focus on CLAUDE.md").

## Step 1: Gate on plan mode

Check whether plan mode is currently active. If it is NOT active, stop immediately and tell the user:

> "This command requires plan mode to prevent accidental edits. Run `/plan` first, then run `/housekeeping` again."

Do not proceed past this step unless plan mode is active.

## Step 2: Read both files

Read:
- `CLAUDE.md` (project root)
- `memory/MEMORY.md` (auto-memory file)

Count the lines in each file.

## Step 3: Evaluate CLAUDE.md

Target: ≤ 150 lines, high signal only.

Flag content to cut or condense:
- Verbose explanations that duplicate what is already documented in `experiments/` READMEs
- The Learning Order section — all 13 topics are complete; this is now stale scaffolding
- Anything that is already captured in `memory/MEMORY.md` and adds no value here

Preserve:
- Project purpose and scope
- Project structure (directory layout)
- Working style preferences
- Conventions section
- Memory policy (the final section)

If `$ARGUMENTS` says to skip CLAUDE.md, note the skip and move on.

## Step 4: Evaluate MEMORY.md

Target: ≤ 200 lines to avoid auto-truncation at context load time.

Flag content to cut or condense:
- The "Topic Status" checklist near the bottom — it duplicates the ✅ markers already present in each section header; remove it entirely
- Verbose per-experiment "Key lesson" bullet dumps where the lessons are now common knowledge (e.g., basic git diff flags, obvious Python None checks)
- Redundant phrasing within sections that can be collapsed to one bullet

Preserve:
- All ✅ topic completion markers in section headers
- High-value gotchas that are specific to this project (e.g., the commit-normalizer heredoc trap, the `printf` vs `echo` JSON issue, the CLAUDECODE env var blocking nested sessions)
- Key architectural decisions and config locations
- Any lesson that would be confusing to reconstruct cold

If `$ARGUMENTS` says to skip MEMORY.md, note the skip and move on.

## Step 5: Write a plan and exit plan mode

Write a plain-text plan to `.claude/housekeeping-plan.md` listing:
- Current line count for each file
- Projected line count after edits
- Each proposed change as a short bullet: what section or lines will be cut/condensed and why

Then call `ExitPlanMode` so the user can review the plan and decide whether to approve.

Do NOT edit `CLAUDE.md` or `memory/MEMORY.md` before the user approves.

## Step 6: Apply edits after approval

Once the user approves:
1. Apply the minimal edits needed to bring each file within its size limit
2. Verify the final line counts
3. Delete `.claude/housekeeping-plan.md` (it served its purpose)
4. Report the before/after line counts to the user
