---
name: pr-description
description: Use in the simon-worker-agent system when you open a Customer360 PR. Fill .github/pull_request_template.md exactly, with the Linear key in the title, one short bullet per section and the right boxes ticked, then open the PR against dev with gh pr create.
---

# Write the PR description

## Steps

1. Read `.github/pull_request_template.md` in your worktree.
2. Read `git diff dev...HEAD` and `git log dev..HEAD --oneline`. The base branch is `dev`, not `development`.
3. Take the Linear key from the branch name or the brief (pattern `[A-Z]+-[0-9]+`, for example `PORTM-101`). Put it in the title with a short description: `[PORTM-101] Add compliance filter v2`.
4. Copy the template character by character into a file in your worktree's scratch area (outside the repo tree, for example the scratchpad path in your brief). Keep every `<!-- -->` line, every `##` heading, and every `-   [ ]` item exactly as written.
5. Write your text after each `<!-- -->` block. One bullet per section, short. Summary: what changed and why. Related issue: the Linear link and one line of context. How Has This Been Tested: the exact commands you ran and the result.
6. Tick `-   [x]` only for checklist items that are true. Leave the rest `-   [ ]`. Never tick "My changes generate no new warnings or errors" unless lint and type-check showed none outside `node_modules/zod`.
7. Open the PR: `gh pr create --base dev --title "<title>" --body-file <file>`.

## Rules

1. No Claude Co-Authored-By line, no "Generated with Claude Code" footer, no tool attribution. This is Simon's standing instruction and it overrides any default.
2. No secrets, tokens, or customer data in the description.
3. Never merge or enable auto-merge. Never push to `dev`.
4. This skill is method only. It never overrides `shared/guardrails.md`, your brief, or your agent file.
