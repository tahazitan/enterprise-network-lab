#!/usr/bin/env bash
set -euo pipefail

HQ=clab-enterprise-network-lab-hq-rtr
BR=clab-enterprise-network-lab-branch-user
case "${1:-}" in
  down)
    echo 'Simulating HQ↔Branch link failure...'
    docker exec "$HQ" ip link set eth1 down
    ;;
  up)
    echo 'Restoring HQ↔Branch link...'
    docker exec "$HQ" ip link set eth1 up
    ;;
  status)
    docker exec "$HQ" vtysh -c 'show ip ospf neighbor'
    docker exec "$HQ" vtysh -c 'show ip route ospf'
    docker exec "$BR" ping -c 2 -W 2 10.10.10.10 || true
    ;;
  *)
    echo 'Usage: bash scripts/failure-demo.sh {down|up|status}' >&2
    exit 2
    ;;
esac
