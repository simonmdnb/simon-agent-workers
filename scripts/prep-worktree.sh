#!/usr/bin/env bash
# Give a Customer360 worktree its dependencies WITHOUT installing anything.
# Links the main checkout's node_modules (root and client/) into the worktree.
#
#   scripts/prep-worktree.sh <worktree>         link node_modules into the worktree
#   scripts/prep-worktree.sh --undo <worktree>  remove the two links (only if they are links)
#
# Safety rules (pinned, do not loosen without Simon's approval):
#   - the target must be /Users/simonmor/dnb/wt-<name> and a registered worktree of customer360
#   - package-lock.json (root and client/) must be identical to the main checkout's. If not, the main
#     install is stale for this branch: Simon runs `npm install` himself. This script never does.
#   - no npm, no rm. It only creates or unlinks symlinks.
#   - if git would show the links as untracked changes, it unlinks them again and fails
#
# Exit 0 ok, 1 refused, 2 usage.

set -uo pipefail

REPO="/Users/simonmor/dnb/customer360"
PREFIX="/Users/simonmor/dnb/wt-"

undo=0
if [ "${1:-}" = "--undo" ]; then undo=1; shift; fi
wt="${1:-}"
[ -n "$wt" ] || { echo "usage: $0 [--undo] <worktree>" >&2; exit 2; }

case "$wt" in
  "$PREFIX"*) ;;
  *) echo "refused: $wt is not under ${PREFIX}*" >&2; exit 1 ;;
esac
case "$wt" in *..*|*" "*) echo "refused: bad path" >&2; exit 1 ;; esac
[ -d "$wt" ] || { echo "refused: $wt is not a directory" >&2; exit 1; }

if ! git -C "$REPO" worktree list --porcelain | grep -Fxq "worktree $wt"; then
  echo "refused: $wt is not a registered worktree of $REPO" >&2
  exit 1
fi

links=("node_modules" "client/node_modules")

if [ "$undo" -eq 1 ]; then
  for l in "${links[@]}"; do
    if [ -L "$wt/$l" ]; then unlink "$wt/$l" && echo "unlinked $l"; fi
  done
  exit 0
fi

for l in "${links[@]}"; do
  [ -d "$REPO/$l" ] || { echo "refused: main checkout has no $l. Simon: run npm install in $REPO" >&2; exit 1; }
done

for lock in package-lock.json client/package-lock.json; do
  if ! cmp -s "$REPO/$lock" "$wt/$lock"; then
    echo "refused: $lock differs between $REPO and $wt. The main install does not match this branch." >&2
    echo "needs Simon: run npm install for this branch himself, or rebase the branch onto the main checkout's commit." >&2
    exit 1
  fi
done

for l in "${links[@]}"; do
  if [ -L "$wt/$l" ]; then
    [ "$(readlink "$wt/$l")" = "$REPO/$l" ] || { echo "refused: $wt/$l links somewhere else" >&2; exit 1; }
  elif [ -e "$wt/$l" ]; then
    echo "refused: $wt/$l already exists and is not a link" >&2
    exit 1
  else
    ln -s "$REPO/$l" "$wt/$l" || { echo "refused: could not link $l" >&2; exit 1; }
  fi
done

if git -C "$wt" status --porcelain | grep -q 'node_modules'; then
  for l in "${links[@]}"; do [ -L "$wt/$l" ] && unlink "$wt/$l"; done
  echo "refused: git shows node_modules as untracked in $wt (ignore rule does not match a link). Links removed." >&2
  exit 1
fi

echo "prepared $wt (node_modules linked from $REPO)"
