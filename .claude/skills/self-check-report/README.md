# self-check-report

Project skill for the simon-worker-agent system. Loaded by Claude from `SKILL.md`; this README is for humans.

**Purpose:** make a role agent validate its own JSON report with `scripts/validate-state.sh report` before returning it, so fewer invalid reports reach the Lead.

**Used by:** every role with the Skill tool and Bash (frontend dev, backend dev, QA, designer, maintainer). Product and ops-mail cannot run the validator, so the Lead validates their reports instead.

**How it fits:**
- The validator mirrors `shared/schemas/report.schema.json`. If the schema changes, the script and the examples in the agent files change with it.
- The Lead still validates every report again. This skill reduces retries, it does not replace the Lead's check.
- The validator checks shape, not truth. The skill says so, and forbids inventing evidence or editing the checker.

**Permissions:** the validator command is allowed in `.claude/settings.json` as `scripts/validate-state.sh report *`. The skill uses the form `cd <repo> && scripts/validate-state.sh report <file>` so it matches that rule from any working directory.

**Change it through:** the `[META]` maintainer.

**Test it:** spawn a role on a throwaway ticket, check that a `.report-<role>-<ticket>.json` file appears under `state/tickets/`, and that the final message is bare JSON.
