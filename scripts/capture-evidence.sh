#!/usr/bin/env bash
# Collect read-only, time-stamped evidence from the BASE Containerlab profile.
# This script does not deploy containers, change configuration, or claim a PASS.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v docker >/dev/null 2>&1 || { echo "Docker is required." >&2; exit 1; }
command -v date >/dev/null 2>&1 || { echo "date is required." >&2; exit 1; }

STAMP="$(date -u '+%Y%m%dT%H%M%SZ')"
DIR="${1:-$ROOT/evidence/runs/$STAMP}"
if [[ -e "$DIR" ]]; then
  echo "Refusing to overwrite existing evidence directory: $DIR" >&2
  exit 1
fi
umask 077
mkdir -p "$DIR"

PREFIX="clab-enterprise-network-lab"
HQ="$PREFIX-hq-rtr"
BR="$PREFIX-branch-rtr"
IT="$PREFIX-hq-it"
BU="$PREFIX-branch-user"

# A failed observation must remain visible without stopping later captures.
capture() {
  local filename="$1"; shift
  {
    printf 'COMMAND: '
    printf '%q ' "$@"
    printf '\n'
    "$@"
  } >"$DIR/$filename.log" 2>&1 || {
    printf 'WARN: %s failed; inspect the log.\n' "$filename" >&2
    return 0
  }
}
capture "01-hq-ospf-neighbors" docker exec "$HQ" vtysh -c 'show ip ospf neighbor'
capture "02-branch-ospf-neighbors" docker exec "$BR" vtysh -c 'show ip ospf neighbor'
capture "03-hq-ospf-routes" docker exec "$HQ" vtysh -c 'show ip route ospf'
capture "04-branch-ospf-routes" docker exec "$BR" vtysh -c 'show ip route ospf'
capture "05-hq-to-branch" docker exec "$IT" ping -c 3 -W 2 10.20.30.10
capture "06-branch-to-hq" docker exec "$BU" ping -c 3 -W 2 10.10.10.10

RESULT="FAIL"
if bash scripts/verify.sh >"$DIR/07-acceptance.log" 2>&1; then
  RESULT="PASS"
fi
COMMIT="$(git rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
{
  printf '# Network Lab — evidence capture\n\n'
  printf 'UTC: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'Git commit: %s\n' "$COMMIT"
  printf 'Base acceptance result: %s\n' "$RESULT"
  printf 'Environment: Containerlab / FRRouting base profile\n\n'
  printf 'Inspect all *.log files. They contain actual command output from this run, NOT sample results.\n'
  printf 'Review for sensitive data before sharing or publishing.\n'
} >"$DIR/REPORT.md"
printf 'Saved evidence to %s\n' "$DIR"
printf 'Acceptance result: %s\n' "$RESULT"
[[ "$RESULT" == "PASS" ]]
