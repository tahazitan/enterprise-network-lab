# Publishing to GitHub (first publication)

The connected GitHub integration does not support creating a new repository in this session.
**Never push the networking lab to the unrelated Bank-Pro-Developer repository.**

1. GitHub -> + -> New repository -> `enterprise-network-lab` -> Public -> **do not** initialize with README, .gitignore or license (already included here).
2. On Mac, unzip the finished ZIP and enter the resulting `enterprise-network-lab` folder.
3. Install Git, sign in to GitHub through `gh auth login` (or use SSH credentials).
4. Run:

```bash
git init
git add .
git commit -m "feat: publish enterprise multi-site lab source v1"
git branch -M main
git remote add origin https://github.com/zitanet44-commits/enterprise-network-lab.git
git push -u origin main
```

5. Open https://github.com/zitanet44-commits/enterprise-network-lab (only after push succeeds).
6. Verify no `.secrets`, private keys, logs, payment data or credentials were included.
7. Add GitHub topics: `network-engineering`, `frrouting`, `ospf`, `containerlab`, `wireguard`, `vlan`, `homelab`.
8. In your website Projects section, embed `site/project-card.html` or use `site/portfolio-project-page.html` for a standalone page. Replace the GitHub profile link with the repository URL **after** the repo exists.
9. Update your CV to link to the GitHub project after publication.

Do not describe this v1 as tested, deployed or production-ready until a real Linux lab verification is completed.
