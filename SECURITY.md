# Lab security and responsible disclosure

This is an isolated educational topology. Never paste production credentials,
VPN private keys, real employee data or customer configuration into GitHub.

- `secure/.secrets` contains runtime-generated WireGuard keys. **Never commit.**
- Evidence capture under `secure/evidence/runs/` is gitignored; review/anonymize logs.
- Do not open Router management interfaces or UDP 51820 on a public machine by accident.
- No IPv6 filtering in the demonstration; do not deploy as a perimeter firewall.
- On suspected credential exposure, delete published files, revoke keys and rotate them.
- FRR over untrusted WAN without route authentication is not a production-grade design.
