# frozen_string_literal: true
# This Python unittest intentionally avoids echoing secrets.
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[2] / "scripts/ensure_demo_credentials.py"

class TestDemoEnvBootstrap(unittest.TestCase):
    def run_tool(self, path):
        return subprocess.run([sys.executable, str(SCRIPT), str(path)], text=True, capture_output=True)

    def test_creates_distinct_values_without_logging_them(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / ".env.production"
            path.write_text("POSTGRES_DB=sample\n", encoding="utf-8")
            result = self.run_tool(path)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertIn("created=2",result.stdout)
            content = path.read_text()
            values = re.findall(r"^DEMO_(?:USER|ADMIN)_PASSWORD=([a-f0-9]{32})$",content,re.M)
            self.assertEqual(len(values),2)
            self.assertNotEqual(values[0],values[1])
            for value in values:
                self.assertNotIn(value,result.stdout)
            self.assertEqual(path.stat().st_mode & 0o777,0o600)
            again = self.run_tool(path)
            self.assertEqual(again.returncode,0,again.stderr)
            self.assertIn("created=0",again.stdout)
            self.assertEqual(content,path.read_text())

    def test_keeps_existing_admin_password(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / ".env.production"
            path.write_text("DEMO_ADMIN_PASSWORD=already-set-for-demo\nDEMO_USER_PASSWORD=\n",encoding="utf-8")
            result = self.run_tool(path)
            self.assertEqual(result.returncode,0,result.stderr)
            content = path.read_text()
            self.assertIn("DEMO_ADMIN_PASSWORD=already-set-for-demo",content)
            self.assertRegex(content,r"DEMO_USER_PASSWORD=[a-f0-9]{32}")

    def test_rejects_duplicates_without_mutating_file(self):
        with tempfile.TemporaryDirectory() as td:
            path=Path(td)/".env.production"
            original="DEMO_USER_PASSWORD=a\nDEMO_USER_PASSWORD=b\n"
            path.write_text(original,encoding="utf-8")
            result=self.run_tool(path)
            self.assertNotEqual(result.returncode,0)
            self.assertEqual(path.read_text(),original)

    def test_rejects_symlink(self):
        with tempfile.TemporaryDirectory() as td:
            real=Path(td)/"real"
            real.write_text("A=1\n")
            linked=Path(td)/".env.production"
            linked.symlink_to(real)
            result=self.run_tool(linked)
            self.assertNotEqual(result.returncode,0)
            self.assertEqual(real.read_text(),"A=1\n")

if __name__=="__main__":
    unittest.main()
