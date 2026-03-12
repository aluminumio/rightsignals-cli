## Workflow

- Every change goes through a pull request — never push directly to main.
- Every PR must bump the version number in both `shard.yml` and `src/main.cr` (VERSION constant). Use semver: patch for fixes, minor for features, major for breaking changes.
- Run `crystal spec` before pushing. After pushing, monitor GitHub Actions.
- Don't mention Claude in commits, PRs, or code.
