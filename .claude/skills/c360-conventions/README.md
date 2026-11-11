# c360-conventions

Project skill for the simon-worker-agent system. Loaded by Claude from `SKILL.md`; this README is for humans.

**Purpose:** give dev agents a short checklist of the Customer360 rules that are most often missed, so they do not have to re-derive them from a long `CLAUDE.md` on every ticket.

**Used by:** frontend dev, backend dev (gateway work). QA may use it to check a PR against the same list.

**How it fits:**
- It points at the repo `CLAUDE.md` instead of copying it, so it does not go stale. The repo file wins on any conflict.
- Base branch for new work is `dev` (the only long-lived remote branch). Branch name pattern `{issue-number}-{flag_key}`.
- It cannot run `/speckit-linear`; it tells the agent to flag spec edits to the Lead instead.

**Source:** written for this repo from Customer360 `CLAUDE.md` (sections 3, 4.3, 7.2.1, 14, 15.1). Re-check the checklist when that file changes. Last checked 2026-11-11.

**Change it through:** the `[META]` maintainer.

**Test it:** give a dev agent a tiny ticket and check that the PR has the flag constant, the `false` fallback, the gate, and a `data-testid` on new controls.
