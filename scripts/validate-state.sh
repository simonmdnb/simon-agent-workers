#!/usr/bin/env bash
# Structural checks for the Lead's state files and role agent reports.
# jq only (no npm). Mirrors shared/schemas/*.json: change both together.
#
#   scripts/validate-state.sh state                 check state/tasks.json and state/lead.json
#   scripts/validate-state.sh report <file>         check one role agent report (JSON file)
#   scripts/validate-state.sh report -              same, JSON read from stdin
#
# Exit 0 = valid. Exit 1 = invalid (one error per line on stdout). Exit 2 = usage or environment error.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found" >&2
  exit 2
fi

COMMON='
def isint: type == "number" and . == floor;
def nes: type == "string" and length > 0;
def states: ["queued","in_progress","waiting_qa","waiting_simon","blocked","done"];
def roles: ["frontend-dev","backend-dev","qa","product","designer","reviewer","ops-mail","maintainer"];
def types: ["READY","QUESTION","ANSWER","PASS","FAIL","BLOCKED","INFO"];
def allowed: {
  "frontend-dev": ["READY","QUESTION","BLOCKED"],
  "backend-dev":  ["READY","QUESTION","BLOCKED"],
  "qa":           ["PASS","FAIL","BLOCKED"],
  "designer":     ["PASS","FAIL","BLOCKED"],
  "reviewer":     ["PASS","FAIL","BLOCKED"],
  "product":      ["ANSWER","BLOCKED"],
  "ops-mail":     ["INFO","BLOCKED"],
  "maintainer":   ["READY","QUESTION","BLOCKED"]
};
def ticket_re: "^[A-Za-z][A-Za-z0-9]*-[0-9]+$";
def ts_re: "^[0-9]+\\.[0-9]+$";
'

TASKS_JQ="$COMMON"'
def terr($k):
  . as $t
  | if ($t | type) != "object" then ["\($k): entry must be an object"] else
    [
      (if ($k | test(ticket_re)) then empty else "\($k): key must look like PORTM-101" end),
      (["slack_channel_id","linear_issue","branch","worktree","notes_file"][] as $f
        | if ($t[$f] | nes) then empty else "\($k): \($f) must be a non-empty string" end),
      (if (($t.slack_thread_ts | type) == "string" and ($t.slack_thread_ts | test(ts_re)))
        then empty else "\($k): slack_thread_ts must look like 1731312345.000200" end),
      (if ($t.status | IN(states[])) then empty
        else "\($k): status must be one of \(states | join(", "))" end),
      (if ($t.assigned_agent | IN(roles[])) then empty
        else "\($k): assigned_agent must be one of \(roles | join(", "))" end),
      (if (($t.hop_count | isint) and $t.hop_count >= 0 and $t.hop_count <= 6) then empty
        else "\($k): hop_count must be an integer 0..6" end),
      (if (($t.fail_loops | isint) and $t.fail_loops >= 0 and $t.fail_loops <= 3) then empty
        else "\($k): fail_loops must be an integer 0..3" end),
      (if ($t.pr == null or ($t.pr | isint)) then empty
        else "\($k): pr must be an integer or null" end),
      (if ($t.queued_reason == null or ($t.queued_reason | IN("daily_limit","active_cap"))) then empty
        else "\($k): queued_reason must be daily_limit or active_cap" end),
      (if ($t.pr_outcome == null or ($t.pr_outcome | IN("open","merged","closed"))) then empty
        else "\($k): pr_outcome must be open, merged or closed" end),
      (if ($t.pr_comments_seen == null or (($t.pr_comments_seen | isint) and $t.pr_comments_seen >= 0)) then empty
        else "\($k): pr_comments_seen must be an integer >= 0" end),
      (if ($t.pr_checks == null or ($t.pr_checks | IN("pass","fail","pending"))) then empty
        else "\($k): pr_checks must be pass, fail or pending" end),
      (["started_at","ready_at","last_pr_check"][] as $f
        | if ($t[$f] == null or ($t[$f] | type) == "string") then empty
          else "\($k): \($f) must be a string" end),
      (if (($t.status | IN("waiting_qa","waiting_simon")) and ($t.assigned_agent != "maintainer") and (($t.pr | isint) | not))
        then "\($k): status \($t.status) requires a pr number" else empty end)
    ] end;
if type != "object" then ["tasks.json must be an object keyed by ticket id"]
else ([to_entries[] | . as $e | ($e.value | terr($e.key))] | add // [])
end | .[]
'

LEAD_JQ="$COMMON"'
if type != "object" then ["lead.json must be an object"] else
[
  (if (.last_ts == null or (.last_ts | type == "string" and test(ts_re))) then empty
    else "last_ts must be null or a Slack ts like 1731312345.000200" end),
  (if (.channel_id | nes) then empty else "channel_id must be a non-empty string" end),
  (if (.halted | type) == "boolean" then empty else "halted must be true or false" end),
  (if (.last_heartbeat == null or (.last_heartbeat | type) == "string") then empty
    else "last_heartbeat must be null or a string" end),
  (if (.max_tickets_per_day == null or ((.max_tickets_per_day | isint) and .max_tickets_per_day >= 0 and .max_tickets_per_day <= 50)) then empty
    else "max_tickets_per_day must be an integer 0..50" end),
  (if (.max_active == null or ((.max_active | isint) and .max_active >= 1 and .max_active <= 5)) then empty
    else "max_active must be an integer 1..5" end),
  (if (.review_min_lines == null or ((.review_min_lines | isint) and .review_min_lines >= 0 and .review_min_lines <= 5000)) then empty
    else "review_min_lines must be an integer 0..5000" end),
  (if (.started_today == null or ((.started_today | isint) and .started_today >= 0)) then empty
    else "started_today must be an integer >= 0" end),
  (if (.day == null or (.day | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$"))) then empty
    else "day must be null or YYYY-MM-DD" end),
  (if (.digest_enabled == null or (.digest_enabled | type) == "boolean") then empty
    else "digest_enabled must be true or false" end),
  (if (.digest_time == null or (.digest_time | type == "string" and test("^([01][0-9]|2[0-3]):[0-5][0-9]$"))) then empty
    else "digest_time must be HH:MM (24h)" end),
  (if (.simon_user_id == null or (.simon_user_id | type == "string" and test("^[UW][A-Z0-9]+$"))) then empty
    else "simon_user_id must look like U07KH2WCHKM" end),
  (if (.halt_reason == null or (.halt_reason | IN("stop_all","members"))) then empty
    else "halt_reason must be stop_all or members" end),
  (if (.started_at == null or (.started_at | type) == "string") then empty
    else "started_at must be a string" end),
  (if (.last_digest_day == null or (.last_digest_day | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$"))) then empty
    else "last_digest_day must be null or YYYY-MM-DD" end)
] end | .[]
'

METRICS_JQ="$COMMON"'
def outcomes: ["merged","closed","blocked","abandoned"];
. as $m
| if type != "object" then ["each metrics line must be a JSON object"] else
  [
    (if ($m.ticket | nes) then empty else "ticket must be a non-empty string" end),
    (if ($m.outcome | IN(outcomes[])) then empty else "outcome must be one of \(outcomes | join(", "))" end),
    (["started_at","ready_at","closed_at"][] as $f
      | if ($m[$f] == null or ($m[$f] | type) == "string") then empty else "\($f) must be a string" end),
    (["fail_loops","hop_count"][] as $f
      | if ($m[$f] == null or ($m[$f] | isint)) then empty else "\($f) must be an integer" end),
    (if ($m.pr == null or ($m.pr | isint)) then empty else "pr must be an integer or null" end)
  ] end | .[]
'

REPORT_JQ="$COMMON"'
. as $r
| if type != "object" then ["report must be a JSON object"] else
  [
    (if ($r.type | IN(types[])) then empty
      else "type must be one of \(types | join(", "))" end),
    (if (($r.ticket | type) == "string" and ($r.ticket | test(ticket_re))) then empty
      else "ticket must look like PORTM-101" end),
    (if ($r.role | IN(roles[])) then empty
      else "role must be one of \(roles | join(", "))" end),
    (if (($r.role | IN(roles[])) and ($r.type | IN(types[])) and (($r.type | IN(allowed[$r.role][])) | not))
      then "role \($r.role) may not return type \($r.type) (allowed: \(allowed[$r.role] | join(", ")))" else empty end),
    (if ($r.summary | nes) then empty else "summary must be a non-empty string" end),
    (if ($r.needs | type) == "string" then empty else "needs must be a string (empty if nothing)" end),
    (if ($r.pr == null or ($r.pr | isint)) then empty else "pr must be an integer or null" end),
    (if ($r.lesson == null or (($r.lesson | type) == "string" and ($r.lesson | length) <= 300)) then empty
      else "lesson must be a string of at most 300 characters" end),
    (if ($r.evidence | type) == "array" then
        ($r.evidence | to_entries[]
          | select((.value | type) != "object" or ((.value.command | nes) | not) or ((.value.output | nes) | not))
          | "evidence[\(.key)] needs a non-empty command and output")
      else "evidence must be an array (empty if none)" end),
    (if ($r.type == "READY" and $r.role != "maintainer" and (($r.pr | isint) | not)) then "READY needs a pr number" else empty end),
    (if ($r.type == "READY" and $r.role == "maintainer") then
        ((if (($r.commit | type) == "string" and ($r.commit | test("^[0-9a-f]{7,40}$"))) then empty
            else "maintainer READY needs commit (a git sha)" end),
         (if ($r.delivery | IN("direct","pr")) then empty
            else "maintainer READY needs delivery: direct or pr" end),
         (if ($r.delivery == "pr" and (($r.pr | isint) | not)) then "maintainer READY with delivery pr needs a pr number" else empty end),
         (if (($r.evidence | type) != "array" or ($r.evidence | length) == 0)
            then "maintainer READY needs at least one evidence entry" else empty end))
      else empty end),
    (if (($r.type | IN("PASS","FAIL")) and ((($r.evidence | type) != "array") or (($r.evidence | length) == 0)))
      then "\($r.type) needs at least one evidence entry (command and output)" else empty end),
    (if ($r.type == "FAIL" and (($r.repro | nes) | not)) then "FAIL needs a repro" else empty end),
    (if (($r.type | IN("QUESTION","BLOCKED")) and (($r.needs | nes) | not))
      then "\($r.type) needs a non-empty needs field" else empty end),
    (if ($r.type == "ANSWER" and (($r.sources | type) != "array")) then "ANSWER needs a sources array" else empty end)
  ] end | .[]
'

run() {
  local program="$1" file="$2" label="$3" out
  if [ ! -f "$file" ]; then
    echo "$label: file not found: $file"
    return 1
  fi
  if ! jq -e . "$file" >/dev/null 2>&1; then
    echo "$label: not valid JSON"
    return 1
  fi
  out="$(jq -r "$program" "$file" 2>&1)" || { echo "$label: validator error: $out"; return 1; }
  if [ -n "$out" ]; then
    printf '%s\n' "$out" | sed "s|^|$label: |"
    return 1
  fi
  return 0
}

case "${1:-}" in
  state)
    rc=0
    run "$TASKS_JQ" "$ROOT/state/tasks.json" "tasks.json" || rc=1
    run "$LEAD_JQ" "$ROOT/state/lead.json" "lead.json" || rc=1
    [ -f "$ROOT/state/metrics.jsonl" ] && { run "$METRICS_JQ" "$ROOT/state/metrics.jsonl" "metrics.jsonl" || rc=1; }
    [ "$rc" -eq 0 ] && echo "state ok"
    exit "$rc"
    ;;
  report)
    src="${2:-}"
    if [ -z "$src" ]; then
      echo "usage: $0 report <file|->" >&2
      exit 2
    fi
    if [ "$src" = "-" ]; then
      tmp="$(mktemp)"
      trap 'rm -f "$tmp"' EXIT
      cat > "$tmp"
      src="$tmp"
    fi
    if run "$REPORT_JQ" "$src" "report"; then
      echo "report ok"
      exit 0
    fi
    exit 1
    ;;
  *)
    echo "usage: $0 state | report <file|->" >&2
    exit 2
    ;;
esac
