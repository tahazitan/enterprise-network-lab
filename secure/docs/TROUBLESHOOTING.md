# Troubleshooting runbook

These checks help diagnose deployment failures; **they are not records of tests completed.**

## Containerlab node creation
- `sudo containerlab inspect -t topology.secure.clab.yml`
- `docker logs clab-secure-enterprise-hq-rtr`
- `docker exec clab-secure-enterprise-hq-rtr ip -br addr`

## FRR/OSPF not FULL
- `docker exec clab-secure-enterprise-hq-rtr vtysh -c 'show ip ospf neighbor'`
- `docker exec clab-secure-enterprise-hq-rtr vtysh -c 'show ip route ospf'`
- `docker exec clab-secure-enterprise-hq-rtr /usr/lib/frr/frrinit.sh status`
- Inspect `eth1` addresses on both routers and UDP? OSPF is IP protocol **89**, not a UDP port.

## VLAN not passing traffic
- `docker exec clab-secure-enterprise-hq-switch bridge vlan show`
- `docker exec clab-secure-enterprise-hq-rtr ip -d link show eth2.10`
- The tagged trunk (switch eth1) must carry VLANs 10 and 20; access ports must be untagged with correct PVID.

## VPN no handshake
- `docker exec clab-secure-enterprise-hq-rtr wg show`
- `docker exec clab-secure-enterprise-hq-rtr ip route get 10.20.30.10`
- `docker exec clab-secure-enterprise-hq-rtr ping -c 2 172.16.255.2`
- Verify kernel support and firewall rules. WireGuard listens on UDP port **51820** in this private simulation.
- If repeated deploy fails because `wg0` already exists, destroy and redeploy the topology; do not blindly overwrite secrets.

## Expected-deny ping succeeds
- Inspect `iptables -S FORWARD` and confirm the expected `REJECT` entries.
- No IPv6 policy is implemented. The lab defines IPv4 only.
- Do not disable fail-closed policies just to make a ping green.

## Full runtime test limits
A secure VPN, VLAN and firewall deployment depends on host kernel support, container privileges and package versions. Code is statically checked, but traffic behavior must be verified on the user's Linux VM. Capture actual output after fixing any errors; never fabricate reports.
