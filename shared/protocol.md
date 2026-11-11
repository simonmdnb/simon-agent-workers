# Message protocol

Used by the Lead for every Slack post and by role agents for every report back to the Lead.

## Identity

- All Slack posts are made under Simon's Slack user (connector limitation).
- A message that STARTS with `[TAG ...]` was written by the team. A message with no tag is Simon (human).
- Tags: `[LEAD]`, `[FE]`, `[BE]`, `[QA]`, `[PRODUCT]`, `[DESIGN]`, `[OPS]`.

## Format

```
[TAG -> TARGET] TYPE TICKET: body
```

`TARGET` is a role tag or `SIMON`. `TICKET` is the Linear key (for example `PORTM-101`). Omit it only for `STATUS` and `INFO` messages that are not about one ticket.

## Types

| Type | Meaning |
|---|---|
| `TASK` | Lead assigns work to a role |
| `QUESTION` | A role needs an answer (goes to Lead, who routes it to PRODUCT or Simon) |
| `ANSWER` | Reply to a question |
| `READY` | Dev work finished, PR open, ready for QA |
| `PASS` | QA or reviewer verified the work, with evidence |
| `FAIL` | QA or reviewer found a problem, with repro and evidence |
| `BLOCKED` | Cannot continue without Simon or an external action |
| `QUEUED` | Ticket accepted but waiting for a free slot |
| `DONE` | Ticket verified, waiting for Simon to merge |
| `STATUS` | Summary of open tickets |
| `INFO` | Anything else worth knowing (keep it short) |

## Threads

- One Slack thread per ticket. The root message is the `TASK`. All later messages for that ticket go in that thread.
- The thread is identified by `slack_channel_id` + `slack_thread_ts`, stored in `state/tasks.json`.
- Simon may also post at the top level of the channel. Those are commands, not part of a thread, unless he replies inside a ticket thread.

## Commands from Simon (untagged messages)

| Command | Effect |
|---|---|
| `lead, take <ticket>` | Create the ticket record, thread, and start work |
| `<role>, <instruction> <ticket>` | Lead routes the instruction to that role for that ticket |
| `STATUS` | Lead posts all open tickets with owner, state, and thread links |
| `STOP ALL` | Lead stops all role agents and takes no action until `RESUME` |
| `RESUME` | Lead resumes normal operation |
| `approve <ticket> <action>` | Grants one approval gate for that exact action (see guardrails) |

## Rules

1. Short messages. State, then the one thing needed next. Details go in the notes file or the PR.
2. Every `PASS` and `FAIL` includes the command run and the relevant output lines. No evidence, no verdict.
3. Hop guard: after 6 agent-to-agent relays in a ticket thread with no untagged Simon message, stop and post `[LEAD -> SIMON] BLOCKED TICKET: hop limit reached, need your input`. A Simon message resets the counter.
4. Fail loop guard: at most 3 `FAIL` then fix cycles per ticket, then `BLOCKED` to Simon.
5. Never include secrets, tokens, or `.env` contents in any message.
6. The Slack connector takes standard markdown (`**bold**`, `_italic_`, bullet lists, code blocks), not Slack mrkdwn. Single-asterisk `*bold*` renders as italics. No emoji.
7. The connector appends a "Sent using Claude" footer to every post it makes. The Lead treats a message with that footer, or with a leading `[TAG ...]`, as team output, never as a command from Simon. Posts typed by Simon in Slack have neither.
