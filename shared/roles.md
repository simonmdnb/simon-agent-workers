# Role agents

One file per role. The Lead spawns them by name (`frontend-dev`, `backend-dev`, `qa`, `product`, `designer`, `ops-mail`, `maintainer`). Each file has the role's boundaries, its tools, its skills, and the JSON report it returns. `shared/guardrails.md` overrides all of them.

| Role (tag) | File | Tools beyond Read/Grep/Glob | Role skills | Baseline skills* |
|---|---|---|---|---|
| Frontend Dev `[FE]` | `frontend-dev.md` | Edit, Write, Bash, Skill, Linear (read, comment) | `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `impeccable` | yes |
| Backend Dev `[BE]` | `backend-dev.md` | Edit, Write, Bash, Skill, Linear (read, comment) | `test-driven-development`, `systematic-debugging`, `verification-before-completion` | yes |
| QA `[QA]` | `qa.md` | Edit, Write, Bash, Skill, Linear (read, comment) | `verification-before-completion`, `run`, `systematic-debugging` | yes |
| Designer `[DESIGN]` | `designer.md` | Bash, Skill, Linear (read) | `impeccable` (audit and polish, as critique only) | yes |
| Product `[PRODUCT]` | `product.md` | Linear and Atlassian (read only) | none | no |
| Maintainer `[META]` | `maintainer.md` | Edit, Write, Bash, Skill | `writing-skills`, `verification-before-completion` | yes |
| Ops / Mail `[OPS]` | `ops-mail.md` | none (disabled until Phase 8) | none | no |

*Baseline skills are the two project skills in `.claude/skills/`: `write-ticket-notes` and `self-check-report`. Product and ops-mail have no Skill tool or no Bash, so they cannot run the report validator; the Lead validates their reports.

## How skills work here

- A skill is invoked with the Skill tool. Each agent file has a "Skills" section naming the ones that role uses and when.
- The list is a rule the agent follows. An agent with the Skill tool could technically call any available skill. Whether permission rules can restrict that per skill (`Skill(name)`) is to be verified in the Phase 4 dry run.
- Skill text is about method only. It never overrides the guardrails, the brief, or the agent file. Each agent file says so.
- Keep each list short (a few role skills plus the two baseline ones), because every invoked skill is loaded into the agent's context.

## Skills deliberately not listed

These were considered but are not in the skill list available in this setup, so they are not referenced:
- `web-design-guidelines` and the Vercel/Next.js skills: installed per repo in Customer360, so they load only in a session started there, not in the Lead's session.
- `verify`: not in the skill list available here. QA uses `run` to drive the app.

Re-check these when the Lead's working setup changes.

## Adding or changing a role

Use `meta, <instruction>` in Slack. The maintainer edits the agent file, keeps `shared/schemas/report.schema.json` and `scripts/validate-state.sh` in sync if the report changes, and updates this table and the main README. Changes to `maintainer.md` are high-risk and need your approval.
