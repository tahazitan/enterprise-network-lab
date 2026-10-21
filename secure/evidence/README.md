# Secure lab evidence (currently pending)

Do not invent output or screenshots. After deployment run `bash scripts/observe.sh`.
The command creates a timestamped directory in `evidence/runs/`; this path is gitignored by default.
Before publishing redacted excerpts, verify that logs contain no public/private keys, user data,
real company addresses, personal tokens, management IPs or other sensitive material.

Recommended proof: OSPF adjacency, VLAN membership, `wg show` handshake WITHOUT keys,
ACL policy, allowed and denied ping test, fail-closed VPN test.
