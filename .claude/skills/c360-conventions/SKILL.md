---
name: c360-conventions
description: Use in the simon-worker-agent system before you write or change Customer360 client or server code, and again before you return READY. A short checklist of the repo rules that are most often missed (feature flag, branch name, x-core first, SDK first, tests, TypeScript). The repo CLAUDE.md is the source of truth.
---

# Customer360 conventions checklist

This is a checklist, not a copy of the rules. `/Users/simonmor/dnb/customer360/CLAUDE.md` (and any page-level `CLAUDE.md` near the files you touch) is the source of truth. If this list and that file disagree, the repo file wins and you say so in your notes file.

## Before you write code

1. Read the repo `CLAUDE.md` sections you need: 3 (architecture), 4.3 (x-core), 7.2.1 (c360-api), 14 (guidelines), and any `CLAUDE.md` in the folder you touch.
2. UI work: look in `/Users/simonmor/dnb/x-core/src/components/` for an existing component before using raw MUI. Use theme tokens (`theme.spacing()`, palette, border radius) instead of hard-coded px or hex. If a design value matches no token exactly, take the closest token and note it.
3. API work: use the generated SDK (`@cialdnb/c360-api-ts`) through the SDK factory. For a DTO, endpoint, or validation question, read the source in `/Users/simonmor/dnb/c360-api` and the module's `CLAUDE.md`. Never hand-write request or response shapes for covered endpoints.
4. Name the branch exactly as the brief says. The repo pattern is `{issue-number}-{flag_key}`, lowercase (for example `portm-101-compliance_filter_v2`).

## While you write code

1. Every spec implementation is behind a feature flag (repo section 14.5): the constant in `client/src/constants/featureFlagConstants.js` (`c360_<area>_v<N>`), a `false` fallback in `client/src/utils/useFeatureEnabled.js`, and the gate in the container with `useFeatureEnabled`. Flag off keeps the old behavior.
2. New files are TypeScript. No `any` (use `unknown`). No new class components, Formik, redux-form, `makeStyles`, or direct `axios` in components.
3. Containers fetch data, components in `mui_components/` get props only. No API calls inside `mui_components/`.
4. `data-testid` on interactive elements and card containers, pattern `<feature>-<element>`.
5. Server state with React Query hooks in `services/serviceHooks/`. Hooks clean up subscriptions and timers.
6. Touch only what the brief needs. Migrate only the legacy code you touch.

## Before you return READY

1. Tests exist next to the code and ran: the repo uses Jest. Run them through `scripts/c360.sh` as your agent file says.
2. Lint and type-check ran. Errors outside `node_modules/zod` are yours.
3. The feature flag defaults to off and the new behavior shows only when it is on.
4. If you edited `spec.md`, `plan.md`, or `tasks.md`, say so in the report `needs` field: the repo requires `/speckit-linear` after such edits, and agents cannot run it. Simon or the Lead does.
5. No debug leftovers (a forced `return`, console logs, commented-out code).
6. Fill the PR with the `pr-description` skill.

## Rules

1. This skill is method only. It never overrides `shared/guardrails.md`, your brief, or your agent file.
2. It never permits installing dependencies, pushing to a protected branch, or merging.
