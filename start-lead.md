# Starting the Lead

Do these steps in order. Phases 2 and 3 of the README must be done first (Slack channel created and its id written into `CLAUDE.md` and `state/lead.json`; permission allowlist in place). Until then, do not start the loop.

## 1. Keep the Mac awake

In a separate terminal tab, with the Mac on power:

```bash
caffeinate -dimsu
```

Leave it running. Closing it lets the Mac sleep again.

## 2. Start the Lead session

```bash
cd ~/dnb/simon-worker-agent
claude
```

Running from this folder loads `CLAUDE.md` (the Lead's instructions) and the role agents in `.claude/agents/`.

## 3. Start the loop

Inside the Claude session:

```
/loop 1m Follow CLAUDE.md. Read #agents-team for messages newer than state/lead.json last_ts and the threads of open tickets. Handle STOP ALL, RESUME, STATUS, Simon's commands, and reports from running role agents. If nothing needs action, do nothing and post nothing. Update state/lead.json and state/tasks.json after acting.
```

Use `2m` to `5m` instead of `1m` when no tickets are open. To change the interval, stop the loop and run `/loop` again with the new one.

Optional self-paced variant (untested here): `/loop Follow CLAUDE.md. <same text>. After each tick, pick the next delay: 1 minute while any ticket is not done or Simon posted in the last 10 minutes, otherwise 5 minutes.` Claude Code then paces the loop between 1 minute and 1 hour with `ScheduleWakeup`. Check that it still answers `STATUS` within a few minutes before relying on it.

## 4. Check it works

From Slack on your phone or work Mac, post `STATUS` in `#agents-team`. The Lead should reply within about a minute.

## Stopping

- Soft stop: post `STOP ALL` in the channel. Post `RESUME` to continue.
- Hard stop: close the Claude session and stop `caffeinate` (Ctrl+C in its tab).

## Daily restart

The Lead posts `restart me` after 24 hours of uptime or 15 tickets (see `shared/lead-playbooks.md`). It cannot restart itself. Restart the Lead once a day, when it posts that, or when it feels slow: stop the session, start again from step 2. All state lives in `state/`, so nothing is lost. After a restart the Lead rebuilds from `state/tasks.json`, the ticket threads, and `state/tickets/*.md`.
