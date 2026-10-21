# V1 release notes — 2026-10-21

**Release type:** Source/design milestone (not a runtime-validated lab).

Included: base FRRouting/OSPF profile; secure extended profile with Linux VLAN
switching, router subinterfaces, WireGuard overlay, iptables security rules,
static CI checks, test scripts, fail-closed example, engineering guide, resume
and website text. No production network or real organization is involved.

**Static checks:** 4 Python unittest checks pass in the authoring container.
**Dynamic network tests:** Not run. No packet capture or success screenshots are supplied.
**Known limitations:** Ubuntu/Frr/Containerlab image or kernel differences may
require fixes on the target Linux VM; no SLA, HA, AD, SIEM or Zabbix in this release.
