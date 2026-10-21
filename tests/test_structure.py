"""Static source checks; they DO NOT execute a real network or prove reachability."""
import subprocess
import unittest
from pathlib import Path
R = Path(__file__).resolve().parents[1]

class RepoIntegrity(unittest.TestCase):
    def test_critical_files_exist(self):
        for rel in (
            'topology.clab.yml','README.md','configs/hq-rtr/frr.conf',
            'secure/topology.secure.clab.yml','secure/Dockerfile.router',
            'secure/configs/hq/frr.conf','secure/configs/branch/frr.conf',
            'secure/scripts/deploy.sh','secure/scripts/verify.sh','secure/scripts/failclosed.sh',
            'secure/scripts/setup-vpn.sh','site/project-card.html','site/portfolio-project-page.html'
        ):
            with self.subTest(rel=rel): self.assertTrue((R/rel).is_file(),rel)
    def test_shell_syntax(self):
        for script in sorted(R.rglob('*.sh')):
            with self.subTest(script=script.name):
                subprocess.run(['bash','-n',str(script)],check=True)
    def test_expected_network_design_strings(self):
        topo=(R/'secure/topology.secure.clab.yml').read_text()
        self.assertIn('hq-switch',topo)
        self.assertIn('branch-switch',topo)
        switch=(R/'secure/scripts/init-switch.sh').read_text()
        for v in (10,20,30):self.assertIn(f'vid {v}',switch)
        vpn=(R/'secure/scripts/setup-vpn.sh').read_text()
        self.assertIn('wg genkey',vpn)
        self.assertIn('wg0',vpn)
        fw=(R/'secure/scripts/init-router.sh').read_text()
        self.assertIn('-o eth1',fw)
    def test_yaml_parse_if_dependency_installed(self):
        try: import yaml
        except ImportError: self.skipTest('PyYAML absent; install for YAML checks')
        for rel in ('topology.clab.yml','secure/topology.secure.clab.yml'):
            with self.subTest(rel=rel):
                d=yaml.safe_load((R/rel).read_text())
                self.assertIsInstance(d.get('topology',{}).get('nodes'),dict)
                self.assertGreaterEqual(len(d['topology']['nodes']),5)

if __name__=='__main__':unittest.main()
