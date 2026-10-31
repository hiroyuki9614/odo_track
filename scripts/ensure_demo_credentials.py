#!/usr/bin/env python3
"""Initialize public portfolio demo credentials in the VPS-local env file.

Credentials are intentionally shown to visitors by the app and must NOT be
reused for real accounts. This utility never prints or commits credential values.
"""
from __future__ import annotations

import os
from pathlib import Path
import re
import secrets
import stat
import sys
import tempfile

DEMO_KEYS = ("DEMO_ADMIN_PASSWORD", "DEMO_USER_PASSWORD")
ENTRY = re.compile(r"^\s*(?:export\s+)?(?P<key>DEMO_(?:ADMIN|USER)_PASSWORD)\s*=(?P<value>.*)$")

def ensure_credentials(filename: str) -> tuple[int, int]:
    path = Path(filename)
    st = path.lstat()
    if not stat.S_ISREG(st.st_mode) or st.st_nlink != 1:
        raise ValueError("env_file_must_be_regular_unlinked")
    if st.st_uid != os.geteuid():
        raise ValueError("env_file_owner_mismatch")
    raw = path.read_text(encoding="utf-8")
    if "\x00" in raw:
        raise ValueError("invalid_env_file")
    found: set[str] = set()
    created = 0
    fixed_lines: list[str] = []
    for line in raw.splitlines(keepends=True):
        match = ENTRY.match(line.rstrip("\r\n"))
        if match is None:
            fixed_lines.append(line)
            continue
        key = match.group("key")
        if key in found:
            raise ValueError("duplicate_demo_password_key")
        found.add(key)
        value = match.group("value").strip()
        if value not in ("", "''", '""'):
            fixed_lines.append(line)
            continue
        fixed_lines.append(f"{key}={secrets.token_hex(16)}\n")
        created += 1
    for key in DEMO_KEYS:
        if key not in found:
            if fixed_lines and not fixed_lines[-1].endswith("\n"):
                fixed_lines.append("\n")
            fixed_lines.append(f"{key}={secrets.token_hex(16)}\n")
            created += 1
    updated = "".join(fixed_lines)
    if updated != raw:
        fd, temp_path = tempfile.mkstemp(prefix=".demo-env-",dir=str(path.parent))
        try:
            os.fchmod(fd,0o600)
            with os.fdopen(fd,"w",encoding="utf-8",newline="") as stream:
                stream.write(updated)
                stream.flush()
                os.fsync(stream.fileno())
            # Don't overwrite an env file that was switched during this invocation.
            current = path.lstat()
            if (current.st_dev,current.st_ino,current.st_mtime_ns,current.st_size) != (st.st_dev,st.st_ino,st.st_mtime_ns,st.st_size):
                raise ValueError("env_file_changed_concurrently")
            os.replace(temp_path,path)
            dirfd = os.open(str(path.parent),os.O_RDONLY|os.O_DIRECTORY)
            try: os.fsync(dirfd)
            finally: os.close(dirfd)
        finally:
            if os.path.exists(temp_path):
                os.unlink(temp_path)
    elif (st.st_mode & 0o077):
        os.chmod(path,0o600)
    return created, len(DEMO_KEYS)-created

def main():
    if len(sys.argv)!=2:
        raise SystemExit("usage: ensure_demo_credentials.py <local-production-env-file>")
    created,reused = ensure_credentials(sys.argv[1])
    print(f"portfolio_demo_credentials_ready=true created={created} reused={reused}")

if __name__=="__main__":
    main()
