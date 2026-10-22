# Capturing real network evidence

After deploying the **base topology** in Linux and confirming Docker is running:

```bash
make base-up
make base-evidence
```

Or run `bash scripts/capture-evidence.sh` directly. It writes a timestamped folder under `evidence/runs/` containing actual OSPF-neighbor, route, ping and full acceptance-check logs, plus a `REPORT.md` summary. The script performs read-only observations and **returns a failing exit status if the acceptance suite fails**.

`evidence/runs/` is excluded from Git because raw captures may contain environment details. Review and sanitize selected logs before any public release. A checked-in script or CI source test is **not** evidence of a successful live topology.

# Evidence checklist — add REAL output only

- [ ] `01-topology.png`: live Containerlab topology / inspect output.
- [ ] `02-hq-ip-interfaces.png`: HQ interface addresses.
- [ ] `03-ospf-full.png`: OSPF adjacency in Full state.
- [ ] `04-ospf-routes.png`: learned HQ and Branch routes.
- [ ] `05-bidirectional-ping.png`: successful client reachability.
- [ ] `06-link-down.png`: interface-down test and lost route.
- [ ] `07-link-restored.png`: adjacency and restored connectivity.
- [ ] `08-ospf-packets.pcapng`: optional OSPF capture; sanitize before upload.

Never generate fake terminal outputs/screenshots or upload real credentials, API tokens, customer networks or unrelated packet traffic.

## Test report template

| Test | Date | Expected | Observed | Pass/Fail | Evidence file |
|---|---|---|---|---|---|
| OSPF adjacency | TBD | FULL | TBD | TBD | TBD |
| Branch network learned at HQ | TBD | 10.20.30.0/24 | TBD | TBD | TBD |
| HQ networks learned at branch | TBD | 10.10.10.0/24 and 10.10.20.0/24 | TBD | TBD | TBD |
| HQ IT to Branch ping | TBD | Success | TBD | TBD | TBD |
| Link failure | TBD | Loss of branch reachability | TBD | TBD | TBD |
| Link recovery | TBD | Reachability restored | TBD | TBD | TBD |
