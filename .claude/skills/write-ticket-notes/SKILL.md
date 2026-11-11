---
name: write-ticket-notes
description: Use in the simon-worker-agent system when you finish, pause, or block on a ticket and before you return your final report. Defines how to write your section of state/tickets/<ticket>.md so a fresh agent can continue the work and Simon can audit it.
---

# Write ticket notes

The notes file is the team's memory for a ticket. The Lead mirrors it to a Linear document and answers Simon's later questions from it, so write for a reader who was not there.

## File

`/Users/simonmor/dnb/simon-worker-agent/state/tickets/<ticket>.md` (the exact path is also in your brief as `notes_file`).

- If the file does not exist, create it with the title line `# <ticket>: <ticket title>`.
- Add your own section with the heading for your role (`## Frontend Dev`, `## Backend Dev`, `## QA`, `## Product`, `## Design`, `## Maintainer`). If your section already exists, add a dated sub-heading below it. Never edit or delete another role's section.

## Template

```
## <Role>

### What I did and why
2 to 6 lines. The outcome first, then the reason.

### Files touched
- path/one (what changed)
- path/two (what changed)

### Decisions and rejected alternatives
- Chose X because Y. Rejected Z because W.

### Open questions and risks
- Anything unresolved, anything that could break, anything Simon should decide.

### Result
- Branch / PR / commit: <value or "none">
- Commands run and outcome: `npm run test:client` -> 12 passed, 0 failed (summaries, not full output)
- Slack thread: <slack_thread_url from the brief>
```

## Rules

1. Facts only. Say what you ran and what you saw. If you did not verify something, say "not verified".
2. Short. Aim for under 60 lines for your section. Link to the PR for detail instead of pasting diffs.
3. No secrets, tokens, `.env` contents, or customer data beyond ids and short summaries. The file is mirrored to Linear.
4. Write it so a fresh agent of your role could continue the ticket from this file alone: what is done, what is next, what to avoid.
5. Write the notes before you build the final report, and set `notes_file` in the report to this path.
6. This skill describes format only. It never overrides `shared/guardrails.md` or your brief.
