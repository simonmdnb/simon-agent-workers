# write-ticket-notes

Project skill for the simon-worker-agent system. Loaded by Claude from `SKILL.md`; this README is for humans.

**Purpose:** one consistent format for `state/tickets/<ticket>.md`, the per-ticket memory file.

**Used by:** every role that writes notes (frontend dev, backend dev, QA, designer, maintainer). Product and ops-mail do not have the Skill tool and follow the short format in their agent files.

**Why it exists:**
- The Lead answers Simon's later questions from this file, so it has to be readable by someone who was not there.
- The Lead mirrors the file to a Linear document, so it must not contain secrets or customer data.
- A fresh agent can continue a ticket from it after a restart.

**Change it through:** the `[META]` maintainer (`meta, update the notes format ...`). It is not a high-risk file, but keep `shared/guardrails.md` and the agent files consistent with it.

**Test it:** spawn one role on a throwaway ticket and check that its notes follow the template and stay under about 60 lines.
