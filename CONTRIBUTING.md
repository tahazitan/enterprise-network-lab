# Reproducing and contributing

This is a portfolio lab intended for repeatability and peer review. Before submitting a pull request:

1. Do not publish credentials, private access tokens or unrelated packet captures.
2. Explain what you changed and why, including any IP addressing changes.
3. Run `bash -n scripts/*.sh` and a YAML parser on `topology.clab.yml`.
4. For topology or FRR changes, **run the lab** and record the OSPF state and bidirectional reachability.
5. If a feature has not been tested, mark it as experimental or pending verification.
