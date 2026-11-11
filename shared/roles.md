# Role agents

One file per role. The Lead spawns them by name (`frontend-dev`, `backend-dev`, `qa`, `product`, `designer`, `ops-mail`, `maintainer`). Each file has the role's boundaries, its tools, its skills, and the JSON report it returns. `shared/guardrails.md` overrides all of them.

| Role (tag) | File | Tools beyond Read/Grep/Glob | Role skills | Baseline skills* |
|---|---|---|---|---|
| Frontend Dev `[FE]` | `frontend-dev.md` | Edit, Write, Bash, Skill, Linear (read, comment), Figma (read only) | `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `receiving-code-review`, `impeccable`, `c360-conventions`, `pr-description` | yes |
| Backend Dev `[BE]` | `backend-dev.md` | Edit, Write, Bash, Skill, Linear (read, comment) | `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `receiving-code-review`, `c360-conventions`, `pr-description` | yes |
| QA `[QA]` | `qa.md` | Edit, Write, Bash, Skill, Linear (read, comment) | `verification-before-completion`, `run`, `systematic-debugging`, `webapp-testing` (needs Python Playwright, not installed), `c360-conventions` | yes |
| Designer `[DESIGN]` | `designer.md` | Bash, Skill, Linear (read), Figma (read only) | `impeccable` (audit and polish, as critique only), `cial-dnb-design` (company design system, review reference only) | yes |
| Product `[PRODUCT]` | `product.md` | Linear and Atlassian (read only) | none | no |
| Maintainer `[META]` | `maintainer.md` | Edit, Write, Bash, Skill | `writing-skills`, `verification-before-completion`, `claude-md-management:claude-md-improver` | yes |
| Ops / Mail `[OPS]` | `ops-mail.md` | none (disabled until Phase 8) | none | no |

*Baseline skills are the two project skills in `.claude/skills/`: `write-ticket-notes` and `self-check-report`. Product and ops-mail have no Skill tool or no Bash, so they cannot run the report validator; the Lead validates their reports.

## How skills work here

- A skill is invoked with the Skill tool. Each agent file has a "Skills" section naming the ones that role uses and when.
- The list is a rule the agent follows. An agent with the Skill tool could technically call any available skill. Whether permission rules can restrict that per skill (`Skill(name)`) is to be verified in the Phase 4 dry run.
- Skill text is about method only. It never overrides the guardrails, the brief, or the agent file. Each agent file says so.
- Keep each list short (a few role skills plus the two baseline ones), because every invoked skill is loaded into the agent's context.

## Third-party skills and plugins: where each comes from

| Item | Source | How it is here | Used by |
|---|---|---|---|
| `receiving-code-review`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `writing-skills` | superpowers (already in `~/.claude/skills`) | global, already installed | dev roles, QA, maintainer |
| `impeccable`, `cial-dnb-design` | your global and company skills | global, synced | designer, frontend dev |
| `claude-md-management` plugin (skill `claude-md-improver`, command `/revise-claude-md`) | official Anthropic marketplace, v1.0.0 | installed for this folder only (`--scope local`) | maintainer |
| `pr-review-toolkit` plugin (review agents and the `review-pr` command) | official Anthropic marketplace, v1.0.1 | installed for this folder only (`--scope local`) | available to the Lead and to Simon. Not wired into any role: subagents cannot spawn other agents or run slash commands, so QA cannot use it. Wiring it in means a decision in the Lead's `CLAUDE.md` about when to spawn review agents next to QA, and what that costs. |
| `c360-conventions`, `pr-description` | written for this repo (2026-11-11) from Customer360 `CLAUDE.md` and the PR template | project skills in `.claude/skills/`, each with a README | FE, BE (QA uses `c360-conventions`) |
| `webapp-testing` | official `anthropics/skills` repo, commit `2c5958e` | vendored in `.claude/skills/webapp-testing/` with a provenance README | QA |

To reproduce the two plugin installs on another machine, run from the repo folder:

```
claude plugin install pr-review-toolkit@claude-plugins-official --scope local
claude plugin install claude-md-management@claude-plugins-official --scope local
```

## Considered and not used

- `security-guidance` plugin (official): not installed. Its session-start hook runs a script that installs a package, it hooks every prompt and every edit, and it reviews commits and pushes in the background and wakes the agent with the findings. That conflicts with the no-installs rule and would add cost and noise to an unattended loop. Reasonable to use in a session you run yourself in Customer360, not in these agent sessions.
- `commit-commands` plugin: gives dev agents a commit, push, and PR shortcut around our git flow.
- `requesting-code-review`: it is about dispatching a reviewer agent, which a role agent (a subagent) cannot do.
- Community collections (VoltAgent, awesome-claude-code, wshobson/agents): unvetted and overlapping with the roles here. Reference material only.
- `web-design-guidelines` and the Vercel/Next.js skills: installed per repo in Customer360, so they load only in a session started there, not in the Lead's session.
- `verify`: not in the skill list available here. QA uses `run`.

Re-check these when the Lead's working setup changes.

## Vetting checklist for any new skill or plugin

1. Official Anthropic, your company, or a source Simon names. Never a random marketplace entry.
2. Read `SKILL.md` and every script. Look for downloads (`curl`, `wget`), obfuscation (`base64`, `eval`), `!` shell-command syntax in skill text, `sudo`, `rm -rf`, installs, and hooks (check `hooks/hooks.json` and what each hook runs).
3. Check what a plugin's hooks and scripts send elsewhere (network calls, API calls with diffs or file contents).
4. Pin it: a version for a plugin, a commit for a copied skill. Record the source, pin, and date in a README next to it.
5. Install by Simon or with his approval, never by an agent on its own (see `shared/guardrails.md`).
6. Prefer the narrowest scope (`--scope local`) so other projects' sessions are not affected.

## Adding or changing a role

Use `meta, <instruction>` in Slack. The maintainer edits the agent file, keeps `shared/schemas/report.schema.json` and `scripts/validate-state.sh` in sync if the report changes, and updates this table and the main README. Changes to `maintainer.md` are high-risk and need your approval.
