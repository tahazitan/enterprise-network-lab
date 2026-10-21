# Implementation guide

## 1. Design and addressing

The case study is a two-site company, with HQ having an IT subnet `10.10.10.0/24` and a Users subnet `10.10.20.0/24`. Branch contains `10.20.30.0/24`. The point-to-point transport network between routers is `10.255.0.0/30`. This lab deliberately uses separate interfaces for the two HQ LANs; do not refer to them as VLANs until 802.1Q is added.

## 2. Deploy

From an Ubuntu (or similar) Linux VM:

```bash
sudo containerlab deploy -t topology.clab.yml
containerlab inspect -t topology.clab.yml
```

Containerlab automatically creates veth interfaces listed under `links`, starts FRRouting routers and netshoot hosts, and runs client `exec` commands to set IPs and static routes.

## 3. Confirm underlay

```bash
docker exec clab-enterprise-network-lab-hq-rtr ip -br a
docker exec clab-enterprise-network-lab-branch-rtr ip -br a
docker exec clab-enterprise-network-lab-hq-it ip route
```

The routers should have their configured addresses on `eth1` / `eth2` / `eth3`. Note that `eth0` is generally Containerlab's management network, not part of the enterprise design.

## 4. Validate OSPF

```bash
docker exec clab-enterprise-network-lab-hq-rtr vtysh -c 'show ip ospf neighbor'
docker exec clab-enterprise-network-lab-branch-rtr vtysh -c 'show ip ospf neighbor'
docker exec clab-enterprise-network-lab-hq-rtr vtysh -c 'show ip route ospf'
docker exec clab-enterprise-network-lab-branch-rtr vtysh -c 'show ip route ospf'
```

The single adjacency should move to `Full`; check route prefixes exactly. OSPF only establishes neighbors on the transit interface because LAN ports are passive.

## 5. Verify data plane

```bash
bash scripts/verify.sh
```

Document the **date, command, output, screenshot and analysis**. If it fails, investigate routing, IP addressing, interface state and OSPF adjacency before changing multiple variables at once.

## 6. Simulate an outage and recovery

```bash
bash scripts/failure-demo.sh down
bash scripts/failure-demo.sh status
bash scripts/failure-demo.sh up
bash scripts/failure-demo.sh status
```

After a link-down event there is **no backup path**. The purpose is learning how OSPF routes disappear and later reappear. Never describe this as automatic failover.

## 7. Secure and extend incrementally

For an enterprise-grade portfolio, add actual VLAN tags and a firewall (nftables/OPNsense), then optional site-to-site IPsec, logs and monitoring. Run separate evidence-based tests for each feature and update the README roadmap only when verified.
