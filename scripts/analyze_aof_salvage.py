#!/usr/bin/env python3
"""Read-only Redis 7 incremental AOF frame salvage analysis. Never log payloads."""
from __future__ import annotations

from collections import deque
import re
import sys
import tarfile

ARCHIVE = "/home/agent/.local/share/odotrack-redis-recovery/41203796895/redis-volume.before.tar"
TARGET = "./appendonlydir/appendonly.aof.3.incr.aof"
MAX_SKIP_BYTES = 1_048_576
SEARCH_FORWARD_BYTES = 262_144

class InvalidFrame(Exception):
    pass

def number(data: bytes, at: int, limit: int = 24) -> tuple[int, int]:
    end = data.find(b"\r\n", at, at + limit)
    if end < 0:
        raise InvalidFrame("missing_CRLF")
    value = data[at:end]
    if not value or not re.fullmatch(rb"[0-9]+", value):
        raise InvalidFrame("invalid_decimal")
    return int(value), end + 2

def frame(data: bytes, at: int) -> tuple[int, bytes]:
    if at >= len(data) or data[at] != 42:
        raise InvalidFrame("missing_array")
    argc, at = number(data, at + 1)
    if not 1 <= argc <= 10000:
        raise InvalidFrame("bad_arg_count")
    cmd = b""
    for i in range(argc):
        if at >= len(data) or data[at] != 36:
            raise InvalidFrame("missing_bulk")
        length, at = number(data, at + 1)
        if length > 50_000_000 or at + length + 2 > len(data):
            raise InvalidFrame("bad_bulk_length")
        if i == 0:
            cmd = data[at:at + length].upper()
            if not (1 <= len(cmd) <= 80 and re.fullmatch(rb"[A-Z0-9_.-]+",cmd)):
                raise InvalidFrame("bad_command_name")
        at += length
        if data[at:at+2] != b"\r\n":
            raise InvalidFrame("bad_bulk_terminator")
        at += 2
    return at, cmd

def walk(data: bytes, at: int, max_commands: int | None = None):
    recent = deque(maxlen=8)
    count = 0
    open_multi = None
    while at < len(data):
        start = at
        at, cmd = frame(data, at)
        if cmd == b"MULTI":
            if open_multi is not None:
                raise InvalidFrame("nested_MULTI")
            open_multi = start
        elif cmd in (b"EXEC", b"DISCARD"):
            if open_multi is None:
                raise InvalidFrame("unmatched_transaction_end")
            open_multi = None
        recent.append(cmd.decode("ascii"))
        count += 1
        if max_commands is not None and count >= max_commands:
            break
    return at, count, tuple(recent), open_multi

def main() -> int:
    if len(sys.argv) != 1:
        raise SystemExit("unexpected arguments")
    with tarfile.open(ARCHIVE, "r") as tar:
        item = tar.extractfile(TARGET)
        if item is None:
            raise SystemExit("missing_incremental_aof")
        data = item.read()
    print(f"analyzed_incremental_bytes={len(data)}")
    try:
        end, count, recent, open_multi = walk(data, 0)
        print(f"entire_aof_frames_valid=true commands={count} bytes={end}")
        return 0
    except InvalidFrame as exc:
        print(f"entire_aof_frames_valid=false reason={exc}")
    # Determine the last valid protocol boundary and potential open transaction.
    pos = 0
    count = 0
    recent = deque(maxlen=8)
    open_multi = None
    while pos < len(data):
        start = pos
        try:
            pos, cmd = frame(data, pos)
        except InvalidFrame as exc:
            print(f"prefix_valid_bytes={pos} prefix_commands={count} error={exc}")
            break
        if cmd == b"MULTI":
            open_multi = start
        elif cmd in (b"EXEC", b"DISCARD"):
            open_multi = None
        recent.append(cmd.decode("ascii"))
        count += 1
    print(f"prefix_recent_commands={list(recent)}")
    print(f"prefix_transaction_open={open_multi is not None}")
    prefix_keep = pos if open_multi is None else open_multi
    end_search = min(len(data), pos + SEARCH_FORWARD_BYTES)
    cursor = pos
    candidate_count = 0
    valid_candidate = None
    while cursor < end_search:
        idx = data.find(b"\r\n*", cursor, end_search)
        if idx < 0:
            break
        cursor = idx + 2
        candidate_count += 1
        try:
            probe_end, probe_count, _, probe_open = walk(data, cursor, max_commands=80)
            if probe_count < 80 or probe_end < cursor + 1024 or probe_open is not None:
                continue
            suffix_end, suffix_count, recent_suffix, suffix_open = walk(data, cursor)
            if suffix_end == len(data) and suffix_open is None:
                valid_candidate = (cursor, suffix_count, recent_suffix)
                break
        except InvalidFrame:
            continue
    print(f"candidate_boundaries_examined={candidate_count}")
    if valid_candidate is None:
        print("salvage_suffix_valid=false")
        return 0
    start, suffix_count, suffix_recent = valid_candidate
    missing_bytes = start - prefix_keep
    print(f"salvage_suffix_valid=true begin_at={start} suffix_commands={suffix_count} skipped_bytes={missing_bytes}")
    print(f"suffix_recent_commands={list(suffix_recent)}")
    print(f"bounded_loss_approved={missing_bytes <= MAX_SKIP_BYTES}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
