#!/usr/bin/env bash
set -euo pipefail
ROLE="${1:?specify hq or branch}"
# Containerlab creates eth1/eth2 before executing these commands.
ip link set eth1 up
ip link set eth2 up
sysctl -w net.ipv4.ip_forward=1 >/dev/null
sysctl -w net.ipv4.conf.all.rp_filter=0 >/dev/null
if [[ "$ROLE" == hq ]]; then
  ip link add link eth2 name eth2.10 type vlan id 10
  ip link add link eth2 name eth2.20 type vlan id 20
  ip link set eth2.10 up
  ip link set eth2.20 up
elif [[ "$ROLE" == branch ]]; then
  ip link add link eth2 name eth2.30 type vlan id 30
  ip link set eth2.30 up
else echo "Unknown router role" >&2; exit 2; fi
# Start FRR after VLAN sub-interfaces exist; Zebra applies addresses in frr.conf.
/usr/lib/frr/frrinit.sh start
# Educational filtering with default forwarding allowed plus explicit denies.
# Never route corporate user traffic in clear over the WAN if VPN is unavailable.
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
if [[ "$ROLE" == hq ]]; then
  iptables -A FORWARD -s 10.10.20.0/24 -d 10.10.10.0/24 -j REJECT
  iptables -A FORWARD -s 10.20.30.0/24 -d 10.10.10.0/24 -j REJECT
  iptables -A FORWARD -o eth1 -s 10.10.0.0/16 -d 10.20.30.0/24 -j REJECT
else
  iptables -A FORWARD -o eth1 -s 10.20.30.0/24 -d 10.10.0.0/16 -j REJECT
fi
