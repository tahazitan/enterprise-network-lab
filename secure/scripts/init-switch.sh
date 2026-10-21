#!/bin/sh
set -eu
ROLE="${1:?specify hq or branch}"
# Linux bridge with explicit VLAN membership, empty default PVID.
ip link add br0 type bridge vlan_filtering 1 vlan_default_pvid 0
ip link set br0 up
ip link set eth1 master br0
ip link set eth1 up
ip link set eth2 master br0
ip link set eth2 up
if [ "$ROLE" = hq ]; then
  ip link set eth3 master br0
  ip link set eth3 up
  bridge vlan add dev eth1 vid 10
  bridge vlan add dev eth1 vid 20
  bridge vlan add dev eth2 vid 10 pvid untagged
  bridge vlan add dev eth3 vid 20 pvid untagged
elif [ "$ROLE" = branch ]; then
  bridge vlan add dev eth1 vid 30
  bridge vlan add dev eth2 vid 30 pvid untagged
else echo "Unknown role" >&2; exit 2; fi
