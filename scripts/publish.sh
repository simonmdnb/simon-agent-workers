#!/usr/bin/env bash
# Publish a meta/* branch of THIS repo to main, then push. Used only by the maintainer role.
#
#   /Users/simonmor/dnb/simon-worker-agent/scripts/publish.sh meta/<slug> [--approved-high-risk] [--dry-run]
#
# Pinned on purpose: it only works for simonmdnb/simon-agent-workers, only fast-forwards main
# from a meta/* branch, never forces, and refuses to run from any copy other than the one in the
# main checkout (so an edited copy in a worktree cannot be used to weaken its own checks).
#
# Exit codes: 0 ok, 2 refused (precondition), 3 high-risk files need --approved-high-risk,
# 4 content check failed.

set -euo pipefail

EXPECTED_REMOTE_RE='simonmdnb/simon-agent-workers(\.git)?$'
HIGH_RISK_RE='^(\.claude/settings(\.local)?\.json|shared/guardrails\.md|CLAUDE\.md|scripts/publish\.sh|\.claude/agents/maintainer\.md)$'
SECRET_RE='xox[bpoas]-[A-Za-z0-9-]{10,}|xapp-[A-Za-z0-9-]{10,}|gh[pousr]_[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9_-]{10,}|AKIA[0-9A-Z]{12,}|-----BEGIN [A-Z ]*PRIVATE KEY'

die() { echo "refused: $1" >&2; exit "${2:-2}"; }

BRANCH="${1:-}"
shift || true
APPROVED=0
DRY=0
for a in "$@"; do
  case "$a" in
    --approved-high-risk) APPROVED=1 ;;
    --dry-run) DRY=1 ;;
    *) die "unknown option: $a" ;;
  esac
done

[[ "$BRANCH" =~ ^meta/[a-z0-9][a-z0-9._-]*$ ]] || die "branch must look like meta/<slug>"

COMMON="$(git rev-parse --git-common-dir)"
MAIN_DIR="$(cd "$COMMON/.." && pwd)"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
[ "$SELF" = "$MAIN_DIR/scripts/publish.sh" ] || die "run the copy in the main checkout: $MAIN_DIR/scripts/publish.sh"

g() { git -C "$MAIN_DIR" "$@"; }

[[ "$(g remote get-url origin)" =~ $EXPECTED_REMOTE_RE ]] || die "origin is not simonmdnb/simon-agent-workers"
[ "$(g rev-parse --abbrev-ref HEAD)" = "main" ] || die "main checkout is not on branch main"
[ -z "$(g status --porcelain)" ] || die "main checkout has uncommitted changes"

g fetch --quiet origin main
[ "$(g rev-parse main)" = "$(g rev-parse origin/main)" ] || die "local main and origin/main differ, resolve first"

g rev-parse --verify --quiet "refs/heads/$BRANCH" >/dev/null || die "branch $BRANCH does not exist"
g merge-base --is-ancestor main "$BRANCH" || die "main moved since $BRANCH was created, the branch needs a rebase"

CHANGED="$(g diff --name-only main.."$BRANCH")"
[ -n "$CHANGED" ] || die "no changes between main and $BRANCH"

if grep -q '^state/' <<<"$CHANGED"; then
  die "branch changes files under state/, which must stay out of git" 4
fi

HIGH="$(grep -E "$HIGH_RISK_RE" <<<"$CHANGED" || true)"
if [ -n "$HIGH" ] && [ "$APPROVED" -ne 1 ]; then
  echo "high-risk files changed, needs Simon's approval and --approved-high-risk:" >&2
  echo "$HIGH" >&2
  exit 3
fi

if g diff main.."$BRANCH" | grep -E '^\+' | grep -Eq "$SECRET_RE"; then
  die "added lines look like they contain a secret or token" 4
fi

while IFS= read -r f; do
  g cat-file -e "$BRANCH:$f" 2>/dev/null || continue
  case "$f" in
    *.json) g show "$BRANCH:$f" | jq -e . >/dev/null 2>&1 || die "$f is not valid JSON" 4 ;;
    *.sh)   g show "$BRANCH:$f" | bash -n 2>/dev/null || die "$f has a shell syntax error" 4 ;;
  esac
done <<<"$CHANGED"

echo "will fast-forward main to $(g rev-parse --short "$BRANCH") and push. changed files:"
echo "$CHANGED"

if [ "$DRY" -eq 1 ]; then
  echo "dry run: nothing changed"
  exit 0
fi

g merge --ff-only "$BRANCH"
g push origin main
echo "pushed $(g rev-parse --short HEAD) to main"
