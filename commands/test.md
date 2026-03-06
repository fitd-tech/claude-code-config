Run the project's test suite and report results.

Arguments (optional): $ARGUMENTS

Instructions:
1. Detect the test runner:
   - If `package.json` exists, check for `test` script and runner (vitest, jest, mocha)
   - If `pyproject.toml` or `setup.cfg` exists, check for pytest
   - If `Cargo.toml` exists, use `cargo test`
   - If `go.mod` exists, use `go test ./...`
   - If arguments specify a runner or path, use those instead
2. Run the test suite. If $ARGUMENTS contains a file path or pattern, run only those tests.
3. Report results in this format:

```
## Test Results

- **Passed:** N
- **Failed:** N
- **Skipped:** N

### Failures (if any)
- `test_name` — brief description of failure and relevant line
```

4. If tests fail, suggest fixes but do not apply them unless asked.
