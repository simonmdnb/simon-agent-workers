# pr-description

Project skill for the simon-worker-agent system. Loaded by Claude from `SKILL.md`; this README is for humans.

**Purpose:** fill the Customer360 PR template the way the repo expects (template copied exactly, Linear key in the title, one bullet per section, honest checkboxes) and keep Simon's no-attribution rule.

**Used by:** frontend dev, backend dev.

**How it fits:**
- Derived from the "PR Description Generator" notes in Customer360 `CLAUDE.md`. That text diffs against `development`; this repo has only `origin/dev`, so the skill uses `dev`.
- The attribution rule matches `shared/guardrails.md` (Git rules).
- Output goes in through `gh pr create --body-file`, which is already allowed in `.claude/settings.json`.

**Source:** written for this repo, 2026-11-11. Re-check against `.github/pull_request_template.md` when the template changes.

**Change it through:** the `[META]` maintainer.

**Test it:** open a throwaway PR with a dev agent and diff the body against the template: headings and comments must be identical.
