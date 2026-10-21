# Engineering decisions (ADR-lite)

## Why Containerlab + Linux routers?
Repeatability, low-cost virtual infrastructure, readable configurations and remote recruiter review. FRR is a learning tool here, not a licensed FortiGate/Palo Alto appliance.

## Why use WireGuard rather than IPsec in this first secure profile?
Simpler end-to-end reproducibility on modest hardware. The author's previous firewall/VPN labs are separate experiences; this specific repo demonstrates WireGuard **only**. An IPsec profile using strongSwan or vendor VMs can be an optional later release.

## Why two profiles?
The root directory preserves an introductory, lightweight OSPF topology. `secure/` contains the full multi-site scenario with VLANs, firewall restrictions and VPN overlay. Deploy only one at a time.

## Risk: OSPF across WAN
This exercise uses unauthenticated OSPF underlay for pedagogy. Corporate data should traverse wg0 (enforced by WAN blocking rules). In real designs use an authenticated/isolated control plane, approved cryptographic standards, segmentation, change management and logging.

## Limitations
Not high availability, not Zabbix, no DHCP/DNS/AD, no performance SLA or business-grade resilience. Only an isolated demonstration.
