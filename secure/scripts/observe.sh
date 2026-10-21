#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
P=clab-secure-enterprise
mkdir -p evidence/runs
RUN="evidence/runs/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir "$RUN"
printf 'Generated from a real Linux/containerlab execution at %s UTC
' "$(date -u)" > "$RUN/metadata.txt"
for SITE in hq-rtr branch-rtr; do
  NODE="$P-$SITE"
  docker exec "$NODE" vtysh -c 'show ip ospf neighbor' > "$RUN/$SITE-ospf-neighbors.txt"
  docker exec "$NODE" vtysh -c 'show ip route' > "$RUN/$SITE-routing-table.txt"
  docker exec "$NODE" wg show > "$RUN/$SITE-vpn.txt"
  docker exec "$NODE" iptables -S FORWARD > "$RUN/$SITE-forward-policies.txt"
  docker exec "$NODE" ip -br addr > "$RUN/$SITE-interfaces.txt"
done
for SITE in hq-switch branch-switch; do
  docker exec "$P-$SITE" bridge vlan show > "$RUN/$SITE-vlan.txt"
done
bash scripts/verify.sh > "$RUN/verification.txt" 2>&1 || { echo "Validation failed: $RUN/verification.txt"; exit 1; }
echo "Evidence collected at $RUN. Review and redact before committing any logs."
