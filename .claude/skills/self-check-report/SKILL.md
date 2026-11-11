---
name: self-check-report
description: Use in the simon-worker-agent system right before you return your final report to the Lead. Build the JSON report, validate it with scripts/validate-state.sh, fix any errors, then return exactly one JSON object.
---

# Self-check the report

The Lead rejects invalid reports and sends them back. Catch the errors yourself first.

## Steps

1. Build the report as one JSON object that follows `shared/schemas/report.schema.json` and the example in your agent file.
2. Write it to `/Users/simonmor/dnb/simon-worker-agent/state/tickets/.report-<role>-<ticket>.json` (the file is gitignored).
3. Validate it, with this exact command form:

   ```bash
   cd /Users/simonmor/dnb/simon-worker-agent && scripts/validate-state.sh report state/tickets/.report-<role>-<ticket>.json
   ```

4. If it prints `report ok`, return the JSON as your final message.
5. If it prints errors, fix the report (not the checker) and run the validator again. Each error line says what is missing or wrong.
6. If it still fails after two fixes, return a `BLOCKED` report whose `needs` holds the first validator error, and say you could not produce a valid report.

## Rules

1. The final message is exactly one JSON object and nothing else: no prose before or after, no code fence.
2. Never invent evidence to satisfy the validator. `evidence` holds commands you actually ran and the relevant output. If you ran nothing, a `PASS`, `FAIL`, or `READY` is not allowed: do the work or return `BLOCKED`.
3. Never edit `shared/schemas/*`, `scripts/validate-state.sh`, or any rules file to make a report pass.
4. The validator checks shape, not truth. You are still responsible for every claim in the report.
5. This skill describes a check only. It never overrides `shared/guardrails.md` or your brief.
