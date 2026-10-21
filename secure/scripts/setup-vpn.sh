#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
HQ=clab-secure-enterprise-hq-rtr
BR=clab-secure-enterprise-branch-rtr
for node in "$HQ" "$BR"; do docker inspect "$node" >/dev/null; done
# The keys are generated at runtime and never hard-coded into the repository.
umask 077
mkdir -p .secrets
if [[ ! -f .secrets/hq.key ]]; then docker exec "$HQ" wg genkey > .secrets/hq.key; fi
if [[ ! -f .secrets/branch.key ]]; then docker exec "$BR" wg genkey > .secrets/branch.key; fi
HQ_PUB=$(docker exec -i "$HQ" wg pubkey < .secrets/hq.key)
BR_PUB=$(docker exec -i "$BR" wg pubkey < .secrets/branch.key)
cat .secrets/hq.key | docker exec -i "$HQ" sh -c 'umask 077; cat > /run/lab-wg.key'
cat .secrets/branch.key | docker exec -i "$BR" sh -c 'umask 077; cat > /run/lab-wg.key'
# Kernel WireGuard support is required on the Linux VM host.
docker exec "$HQ" ip link add wg0 type wireguard
docker exec "$BR" ip link add wg0 type wireguard
docker exec "$HQ" ip addr add 10.254.0.1/30 dev wg0
docker exec "$BR" ip addr add 10.254.0.2/30 dev wg0
docker exec "$HQ" wg set wg0 listen-port 51820 private-key /run/lab-wg.key peer "$BR_PUB" allowed-ips 10.254.0.2/32,10.20.30.0/24 endpoint 172.16.255.2:51820 persistent-keepalive 25
docker exec "$BR" wg set wg0 listen-port 51820 private-key /run/lab-wg.key peer "$HQ_PUB" allowed-ips 10.254.0.1/32,10.10.10.0/24,10.10.20.0/24 endpoint 172.16.255.1:51820 persistent-keepalive 25
docker exec "$HQ" ip link set wg0 up
docker exec "$BR" ip link set wg0 up
# Install preferred connected VPN routes. The WAN firewall denies any cleartext fallback.
docker exec "$HQ" ip route replace 10.20.30.0/24 dev wg0 metric 1
docker exec "$BR" ip route replace 10.10.10.0/24 dev wg0 metric 1
docker exec "$BR" ip route replace 10.10.20.0/24 dev wg0 metric 1
printf 'Encrypted point-to-point tunnel configured; run verify.sh to prove operation.
'
