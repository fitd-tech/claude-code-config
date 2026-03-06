Review the code or file specified in the arguments for quality, correctness, and security.

Target: $ARGUMENTS

Instructions:
1. If $ARGUMENTS is a file path, read that file. If it is a glob pattern or directory, read the relevant files. If no argument was given, review the most recently edited file (check `git diff --name-only HEAD`).
2. Analyze the code across four dimensions:
   - **Correctness** — logic errors, edge cases, off-by-one errors, unhandled inputs
   - **Security** — injection risks, insecure defaults, exposed secrets, OWASP top 10
   - **Clarity** — naming, structure, obvious vs non-obvious logic
   - **Simplicity** — over-engineering, dead code, premature abstractions
3. Output a concise review in this format:

```
## Review: <filename>

### Issues (must fix)
- <issue and line reference if applicable>

### Suggestions (nice to have)
- <suggestion>

### Looks good
- <what is working well>
```

4. If there are no issues, say so clearly — do not invent problems.
5. Do not make any edits unless the user explicitly asks you to fix something after the review.
