#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for cmd in docker containerlab; do command -v "$cmd" >/dev/null || { echo "Missing $cmd" >&2; exit 1; }; done
echo '[1/3] Building router image'
docker build -f Dockerfile.router -t enterprise-frr-router:local .
echo '[2/3] Deploying secure topology'
containerlab deploy -t topology.secure.clab.yml
echo '[3/3] Enabling WireGuard encrypted tunnel'
bash scripts/setup-vpn.sh
printf '
Ready for validation: bash scripts/verify.sh
'
