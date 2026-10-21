#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v containerlab >/dev/null 2>&1; then
  echo "ERROR: containerlab is required. See README.md." >&2
  exit 1
fi
containerlab deploy -t topology.clab.yml
printf '\nLab started. Run: bash scripts/verify.sh\n'
