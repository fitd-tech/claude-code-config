# Subagent Prompts Reference

Recommended subagent configurations for common tasks. Copy the prompt template into an Agent tool call, replacing `ALL_CAPS` placeholders with your specifics.

---

## 1. Parallel PR Review (Fan-Out)

**When:** Review a PR from 3 perspectives simultaneously (security, performance, test coverage).
**Model:** haiku | **Background:** yes | **Isolation:** none

Spawn all 3 agents in one message. Each returns a JSON object with `findings`, `verdict`, and `summary`.

**Security Agent:**
```
You are a security reviewer. Review the following git diff for security issues only.
Diff: DIFF_CONTENT
Return JSON: {"findings": [{"severity": "high|medium|low", "line": "<file>:<line>", "issue": "...", "recommendation": "..."}], "verdict": "pass|needs_changes", "summary": "one sentence"}
If no issues, return findings: []. No commentary outside JSON.
```

**Performance Agent:**
```
You are a performance reviewer. Review the following git diff for performance issues only.
Look for: N+1 queries, missing indexes, unnecessary allocations, blocking I/O, complexity regressions.
Diff: DIFF_CONTENT
Return JSON: {"findings": [{"severity": "high|medium|low", "line": "<file>:<line>", "issue": "...", "recommendation": "..."}], "verdict": "pass|needs_changes", "summary": "one sentence"}
If no issues, return findings: []. No commentary outside JSON.
```

**Test Coverage Agent:**
```
You are a test coverage reviewer. Review the following git diff.
Identify: new code paths with no test, deleted tests, uncovered edge cases, shallow assertions.
Diff: DIFF_CONTENT
Return JSON: {"findings": [{"severity": "high|medium|low", "location": "<file or function>", "issue": "...", "recommendation": "..."}], "verdict": "pass|needs_changes", "summary": "one sentence"}
If no issues, return findings: []. No commentary outside JSON.
```

---

## 2. Codebase Onboarding (Context Protection)

**When:** Explore a large/unfamiliar codebase and get a structured summary without flooding main context.
**Model:** haiku | **Background:** no | **Isolation:** none

```
You are exploring a codebase at: REPO_PATH
Read the codebase and return a structured summary. Do NOT include raw file contents.
Steps: 1) Read top-level directory 2) Read CLAUDE.md, README.md, manifest files 3) Identify entry points 4) Identify top 5 most-imported modules 5) Note test setup
Return JSON: {"stack": {"language": "...", "framework": "...", "package_manager": "..."}, "entry_points": ["<file>:<function>"], "key_modules": [{"path": "...", "responsibility": "one sentence"}], "test_setup": {"framework": "...", "test_dir": "...", "run_command": "..."}, "conventions": ["..."], "open_questions": ["..."]}
No commentary outside JSON.
```

---

## 3. Build Log Analyzer (Context Protection)

**When:** Extract failures from a large CI/test log without loading the full log into context.
**Model:** haiku | **Background:** no | **Isolation:** none

```
Read the build/test log at: LOG_FILE_PATH
Extract actionable failure information only. Ignore passing tests, progress bars, timestamps.
Return JSON: {"total_failures": N, "failures": [{"type": "test_failure|compile_error|lint_error|runtime_error", "file": "...", "line": "...", "message": "max 2 lines", "root_cause": "one sentence"}], "flaky_suspects": ["..."], "summary": "one sentence"}
If build passed: {"total_failures": 0, "failures": [], "summary": "all checks passed"}
No commentary outside JSON.
```

---

## 4. Parallel File Analyzer (Fan-Out)

**When:** Run the same analysis across N files simultaneously.
**Model:** haiku | **Background:** yes | **Isolation:** none

Spawn one agent per file in a single message:
```
Analyze the file at: FILE_PATH
Goal: ANALYSIS_GOAL
Return JSON: {"file": "FILE_PATH", "findings": [{"location": "<function or line>", "issue": "...", "severity": "high|medium|low"}], "summary": "one sentence", "recommendation": "one sentence"}
Return only JSON.
```

Example goals: "Identify functions with cyclomatic complexity > 10", "Find hardcoded credentials", "Check for missing error handling in async functions"

---

## 5. Worktree Feature Builder (Worktree Isolation)

**When:** Build a complete feature on an isolated branch without affecting the main working tree.
**Model:** sonnet | **Background:** yes | **Isolation:** worktree

```
You are building a new feature on an isolated branch. The main codebase is at: REPO_PATH
Feature: FEATURE_DESCRIPTION
Acceptance criteria: CRITERION_1, CRITERION_2, CRITERION_3
Steps: 1) Read existing codebase 2) Implement following CLAUDE.md conventions 3) Write tests 4) Run test suite 5) Do NOT commit
Return JSON: {"files_created": ["..."], "files_modified": ["..."], "tests_written": ["<file>:<test>"], "test_result": "pass|fail", "notes": "..."}
```

---

## 6. Dependency Auditor (Context Protection)

**When:** Audit dependencies for vulnerabilities and staleness without loading lock files into context.
**Model:** haiku | **Background:** no | **Isolation:** none

```
Audit dependencies at: REPO_PATH
Steps: 1) Read manifest (package.json, pyproject.toml, etc.) 2) Read lock file 3) Run audit command (npm audit --json, etc.) 4) Identify packages > STALENESS_THRESHOLD_MONTHS months behind latest
Return JSON: {"package_manager": "...", "total_dependencies": N, "vulnerabilities": [{"package": "...", "installed_version": "...", "severity": "critical|high|medium|low", "cve": "...", "recommendation": "..."}], "stale_packages": [{"package": "...", "installed_version": "...", "latest_version": "...", "months_behind": N}], "summary": "one sentence", "priority_action": "..."}
No lock file contents. No commentary outside JSON.
```
