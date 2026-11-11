#!/usr/bin/env bash
# Run a Customer360 check inside a prepared worktree.
#
#   scripts/c360.sh <worktree> test:client [jest args]
#   scripts/c360.sh <worktree> test:server [jest args]
#   scripts/c360.sh <worktree> lint
#   scripts/c360.sh <worktree> type-check
#
# Why: a worktree gets its dependencies by link (scripts/prep-worktree.sh). The root install has no
# `typescript`, so ts-jest only works when NODE_PATH points at client/node_modules (this also fails
# in the main checkout without it). This wrapper sets it and runs the repo's own npm scripts. It
# runs nothing else and installs nothing.
#
# Exit code is the npm script's. 2 = usage, 1 = refused.

set -uo pipefail

REPO="/Users/simonmor/dnb/customer360"
PREFIX="/Users/simonmor/dnb/wt-"

wt="${1:-}"; cmd="${2:-}"
[ -n "$wt" ] && [ -n "$cmd" ] || { echo "usage: $0 <worktree> test:client|test:server|lint|type-check [args]" >&2; exit 2; }
shift 2

case "$wt" in "$PREFIX"*) ;; *) echo "refused: $wt is not under ${PREFIX}*" >&2; exit 1 ;; esac
case "$wt" in *..*|*" "*) echo "refused: bad path" >&2; exit 1 ;; esac
git -C "$REPO" worktree list --porcelain | grep -Fxq "worktree $wt" \
  || { echo "refused: $wt is not a registered worktree of $REPO" >&2; exit 1; }
[ -e "$wt/node_modules" ] && [ -e "$wt/client/node_modules" ] \
  || { echo "refused: run scripts/prep-worktree.sh $wt first" >&2; exit 1; }

export NODE_PATH="$REPO/client/node_modules"
cd "$wt" || exit 1
case "$cmd" in
  test:client) exec npm run test:client -- "$@" ;;
  test:server) exec npm run test:server -- "$@" ;;
  lint)        exec npm run lint ;;
  type-check)  cd client && exec npm run type-check ;;
  *) echo "refused: unknown command $cmd" >&2; exit 2 ;;
esac
