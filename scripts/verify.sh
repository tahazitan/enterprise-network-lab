#!/usr/bin/env bash
set -euo pipefail

PREFIX="clab-enterprise-network-lab"
ROUTER_HQ="${PREFIX}-hq-rtr"
ROUTER_BRANCH="${PREFIX}-branch-rtr"
CLIENT_HQ_IT="${PREFIX}-hq-it"
CLIENT_HQ_USERS="${PREFIX}-hq-users"
CLIENT_BRANCH="${PREFIX}-branch-user"

exec_cmd() { docker exec "$1" "${@:2}"; }

if ! command -v docker >/dev/null 2>&1; then
  echo 'ERROR: Docker not found. Run this script inside the Ubuntu/Docker environment.' >&2
  exit 1
fi

# Routing convergence can take time after containers are created.
echo 'Waiting up to 60 seconds for OSPF adjacency to reach FULL...'
ready=0
for i in $(seq 1 30); do
  if exec_cmd "$ROUTER_HQ" vtysh -c 'show ip ospf neighbor' 2>/dev/null | grep -qi 'Full/'; then
    ready=1
    break
  fi
  sleep 2
done
if [[ "$ready" != 1 ]]; then
  echo 'FAIL: no FULL OSPF neighbor within 60 seconds. Check both FRR configs, daemons, and eth1.' >&2
  exit 1
fi

printf '\n=== OSPF neighbors ===\n'
exec_cmd "$ROUTER_HQ" vtysh -c 'show ip ospf neighbor'
exec_cmd "$ROUTER_BRANCH" vtysh -c 'show ip ospf neighbor'

printf '\n=== HQ OSPF-learned routes ===\n'
hq_routes=$(exec_cmd "$ROUTER_HQ" vtysh -c 'show ip route ospf')
echo "$hq_routes"
grep -q '10.20.30.0/24' <<< "$hq_routes" || { echo 'FAIL: HQ is missing Branch LAN route' >&2; exit 1; }

printf '\n=== Branch OSPF-learned routes ===\n'
branch_routes=$(exec_cmd "$ROUTER_BRANCH" vtysh -c 'show ip route ospf')
echo "$branch_routes"
grep -q '10.10.10.0/24' <<< "$branch_routes" || { echo 'FAIL: Branch is missing HQ IT route' >&2; exit 1; }
grep -q '10.10.20.0/24' <<< "$branch_routes" || { echo 'FAIL: Branch is missing HQ Users route' >&2; exit 1; }

printf '\n=== End-to-end data-plane tests ===\n'
exec_cmd "$CLIENT_HQ_IT" ping -c 3 -W 2 10.20.30.10
exec_cmd "$CLIENT_HQ_USERS" ping -c 3 -W 2 10.20.30.10
exec_cmd "$CLIENT_BRANCH" ping -c 3 -W 2 10.10.10.10
exec_cmd "$CLIENT_BRANCH" ping -c 3 -W 2 10.10.20.10

printf '\nPASS: OSPF adjacency, learned routes, and all ping tests passed in this run.\n'
