#!/usr/bin/env python3
"""Rebuild a Redis AOF from a verified archive, preserving validated RESP frames."""
from __future__ import annotations

import hashlib
import os
from pathlib import Path
import re
import sys
import tarfile

ARCHIVE = Path("/home/agent/.local/share/odotrack-redis-recovery/41203796895/redis-volume.before.tar")
MEMBER = "./appendonlydir/appendonly.aof.3.incr.aof"
PREFIX_END = 12_439_235
SUFFIX_START = 12_440_064
EXPECTED_SIZE = 52_957_676
EXPECTED_PREFIX_COMMANDS = 97_149
EXPECTED_SUFFIX_COMMANDS = 316_463
MAX_SKIP_BYTES = 4096

def frame(data: bytes, at: int) -> tuple[int, bytes]:
    if at >= len(data) or data[at] != 42:
        raise ValueError("missing_array")
    def decimal(at: int):
        end = data.find(b"\r\n",at,at+24)
        if end < 0 or not re.fullmatch(rb"[0-9]+",data[at:end]):
            raise ValueError("bad_integer")
        return int(data[at:end]),end+2
    argc,at=decimal(at+1)
    if not 1<=argc<=10000:
        raise ValueError("bad_arg_count")
    command=b""
    for i in range(argc):
        if at>=len(data) or data[at]!=36:
            raise ValueError("missing_bulk")
        n,at=decimal(at+1)
        if n>50_000_000 or at+n+2>len(data):
            raise ValueError("bad_bulk_length")
        if i==0:
            command=data[at:at+n].upper()
            if not (1<=len(command)<=80 and re.fullmatch(rb"[A-Z0-9_.-]+",command)):
                raise ValueError("bad_command")
        at+=n
        if data[at:at+2]!=b"\r\n":
            raise ValueError("bad_bulk_end")
        at+=2
    return at,command

def verify(data: bytes, start: int, end: int) -> int:
    at=start
    count=0
    txn=False
    while at<end:
        at,cmd=frame(data,at)
        if at>end:
            raise ValueError("boundary_crossing")
        if cmd==b"MULTI":
            if txn:
                raise ValueError("nested_multi")
            txn=True
        elif cmd in (b"EXEC",b"DISCARD"):
            if not txn:
                raise ValueError("orphan_exec")
            txn=False
        count+=1
    if at!=end or txn:
        raise ValueError("unbalanced_or_incomplete")
    return count

def main() -> None:
    if len(sys.argv)!=2:
        raise ValueError("usage: rebuild_redis_aof.py <private-work-dir>")
    out=Path(sys.argv[1]).resolve(strict=True)
    if out.parent!=Path("/home/agent/.local/share/odotrack-redis-recovery"):
        raise ValueError("unexpected_work_dir")
    with tarfile.open(ARCHIVE,"r") as tar:
        f=tar.extractfile(MEMBER)
        if f is None:
            raise ValueError("missing_incremental_file")
        original=f.read()
    if len(original)!=EXPECTED_SIZE:
        raise ValueError("source_changed")
    if not (0<PREFIX_END<SUFFIX_START<len(original)):
        raise ValueError("bad_offsets")
    if SUFFIX_START-PREFIX_END>MAX_SKIP_BYTES:
        raise ValueError("too_many_skipped_bytes")
    a=verify(original,0,PREFIX_END)
    b=verify(original,SUFFIX_START,len(original))
    if a!=EXPECTED_PREFIX_COMMANDS or b!=EXPECTED_SUFFIX_COMMANDS:
        raise ValueError("command_count_mismatch")
    rebuilt=original[:PREFIX_END]+original[SUFFIX_START:]
    if verify(rebuilt,0,len(rebuilt))!=a+b:
        raise ValueError("rebuilt_aof_invalid")
    source_hash=hashlib.sha256(original).hexdigest()
    fixed_hash=hashlib.sha256(rebuilt).hexdigest()
    for name,content in (
        ("source.sha256", (source_hash+"\n").encode()),
        ("repaired.sha256", (fixed_hash+"\n").encode()),
        ("repaired.incr.aof",rebuilt)
    ):
        fd=os.open(out/name,os.O_CREAT|os.O_EXCL|os.O_WRONLY|os.O_NOFOLLOW,0o600)
        with os.fdopen(fd,"wb") as f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())
    print("repair_ready=true")
    print(f"preserved_commands={a+b}")
    print(f"removed_corrupt_bytes={SUFFIX_START-PREFIX_END}")
    print(f"repaired_bytes={len(rebuilt)}")

if __name__=="__main__":
    main()
