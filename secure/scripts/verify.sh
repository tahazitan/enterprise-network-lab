#!/usr/bin/env bash
set -euo pipefail
P=clab-secure-enterprise
HQ=$P-hq-rtr
BR=$P-branch-rtr
IT=$P-hq-it
US=$P-hq-users
BU=$P-branch-user
ok() { echo "PASS: $*"; }
no() { echo "FAIL: $*" >&2; exit 1; }
# A design/configuration repo does not claim passing results; this script does.
for n in "$HQ" "$BR" "$IT" "$US" "$BU"; do docker inspect "$n" >/dev/null || no "Missing container $n"; done
echo '[OSPF] Waiting up to 90 seconds for WAN adjacency'
ready=0
for _ in $(seq 1 45); do
  if docker exec "$HQ" vtysh -c 'show ip ospf neighbor' 2>/dev/null | grep -Eqi 'Full/'; then ready=1; break; fi
  sleep 2
done
[[ "$ready" == 1 ]] || no 'OSPF adjacency not FULL'
ok 'OSPF FULL adjacency'
docker exec "$HQ" vtysh -c 'show ip route ospf' | grep -q '10.20.30.0/24' || no 'HQ missing OSPF advertisement'
docker exec "$BR" vtysh -c 'show ip route ospf' | grep -q '10.10.10.0/24' || no 'Branch missing OSPF advertisement'
ok 'OSPF routing advertisements'
echo '[VLAN] Checking 802.1Q trunks and access membership'
docker exec "$P-hq-switch" bridge vlan show
docker exec "$P-hq-switch" bridge vlan show | grep -qE '10|20' || no 'HQ VLAN membership missing'
docker exec "$P-branch-switch" bridge vlan show | grep -q '30' || no 'Branch VLAN 30 missing'
ok 'VLAN membership present'
echo '[VPN] Checking selected data-plane routes'
docker exec "$HQ" ip route get 10.20.30.10 | grep -q 'dev wg0' || no 'HQ-to-branch route does not use VPN'
docker exec "$BR" ip route get 10.10.10.10 | grep -q 'dev wg0' || no 'Branch-to-HQ route does not use VPN'
ok 'Inter-site routing through WireGuard wg0'
echo '[Policy] Allowed traffic'
docker exec "$IT" ping -c 3 -W 2 10.20.30.10 || no 'HQ IT -> Branch unreachable'
docker exec "$BU" ping -c 3 -W 2 10.10.20.10 || no 'Branch -> HQ Users unreachable'
ok 'Allowed traffic forwarded'
echo '[Policy] Denied traffic'
if docker exec "$BU" ping -c 2 -W 2 10.10.10.10 >/dev/null 2>&1; then no 'Branch -> HQ IT unexpectedly allowed'; fi
if docker exec "$US" ping -c 2 -W 2 10.10.10.10 >/dev/null 2>&1; then no 'HQ Users -> IT unexpectedly allowed'; fi
ok 'Cross-zone ACL denies tested'
docker exec "$HQ" wg show wg0 | grep -q 'latest handshake' || no 'Missing WireGuard handshake'
ok 'WireGuard handshake observed'
printf '
PASS: All automated secure topology checks passed on THIS machine. Capture evidence before publishing results.
'
