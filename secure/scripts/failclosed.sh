#!/usr/bin/env bash
set -euo pipefail
HQ=clab-secure-enterprise-hq-rtr
IT=clab-secure-enterprise-hq-it
restore() { docker exec "$HQ" ip link set wg0 up; }
trap restore EXIT
docker exec "$HQ" ip link set wg0 down
sleep 3
if docker exec "$IT" ping -c 2 -W 2 10.20.30.10 >/dev/null 2>&1; then
  echo 'FAIL: Inter-site traffic passed in clear after VPN failure!' >&2; exit 1
fi
echo 'PASS: Inter-site traffic interrupted rather than falling back to cleartext WAN.'
