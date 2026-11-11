# Lessons

Curated by the maintainer from `state/lessons.log` and the weekly retro (`retro` command). At most 30 lines, one lesson per line, written as "When X, do Y". No customer data, no secrets. Every role reads this file; `shared/guardrails.md` still overrides it.

- When you run Customer360 tests in a worktree or the main checkout, use `scripts/c360.sh`: a bare `npm run test:client` fails with "Cannot find module 'typescript'".
- When `scripts/prep-worktree.sh` refuses because a lockfile differs, return `BLOCKED`: the install is Simon's to run.
