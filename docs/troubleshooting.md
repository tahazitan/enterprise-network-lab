# Troubleshooting playbook

## OSPF neighbor not reaching Full

1. Check whether both link endpoints exist: `docker exec clab-enterprise-network-lab-hq-rtr ip -br link`.
2. Confirm HQ `10.255.0.1/30` and Branch `10.255.0.2/30` on eth1.
3. Ensure `ospfd=yes` and `zebra=yes` in the mounted daemon files.
4. Run `docker exec clab-enterprise-network-lab-hq-rtr vtysh -c 'show running-config'`.
5. Make sure neither OSPF-facing eth1 is passive. Check `show ip ospf interface` and `show ip ospf neighbor`.
6. Allow a few seconds for adjacency formation and route programming. Re-check before concluding failure.

## Routes exist but ping fails

- Confirm per-host routes: `docker exec clab-enterprise-network-lab-hq-it ip route`.
- Confirm IPv4 forwarding on both routers: `docker exec clab-enterprise-network-lab-hq-rtr sysctl net.ipv4.ip_forward`.
- Verify that both hosts have assigned addresses on **eth1** and router gateways are directly connected.
- Check return routes (two-way path), not just the forward route.
- Run `traceroute -n 10.20.30.10` from `hq-it` to identify where forwarding stops.
- Ensure you are not accidentally testing over `eth0`, which is Containerlab's management network.

## Containerlab starts, FRR not configured

- Check router logs: `docker logs clab-enterprise-network-lab-hq-rtr`.
- Check mounted files are readable by the FRR daemons.
- Inspect `docker exec clab-enterprise-network-lab-hq-rtr vtysh -c 'show running-config'`.
- If your FRR version or image requires writable config files, adjust the bind policy **locally** and document why. Never silently claim the default is validated.

## `tcpdump: command not found`

The base FRR image may not provide tcpdump. Use Containerlab's packet capture functionality, capture on the Ubuntu host's veth interfaces, or attach a separate tool container. Do not claim packet-level verification without a real trace.

## Linux VM and Mac networking

Run the lab **inside** the Linux VM. Docker Desktop on macOS is not equivalent to a native Linux deployment for every Containerlab networking feature. Keep the topology isolated from production and avoid bridging it into external networks.

## Recovery

If interface eth1 is still down from a test, run `bash scripts/failure-demo.sh up`. If configurations get into an unknown state, destroy then re-deploy the lab and collect a fresh baseline.
