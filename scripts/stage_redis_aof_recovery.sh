#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

log() { printf '[odo-redis-stage] %s\n' "$*"; }
fail() { log "STOP: $*"; exit 1; }

[[ "$(id -un)" == agent ]] || fail "not agent"
uid="$(id -u)"
export XDG_RUNTIME_DIR="/run/user/${uid}"
export DOCKER_HOST="unix:///run/user/${uid}/docker.sock"
[[ "${GITHUB_EVENT_NAME:-}" == pull_request ]] || fail "only for reviewed owner PR"
[[ "${GITHUB_HEAD_REF:-}" == codex/odotrack-redis-aof-staging-20261031 ]] || fail "unexpected branch"
docker info >/dev/null 2>&1 || fail "Docker unavailable"

read -r redis_volume redis_health db_health <<< "$(python3 - <<'PY'
import json,subprocess
def get(name):
    obj=json.loads(subprocess.check_output(["docker","inspect",name],text=True))[0]
    return obj, (obj.get("State",{}).get("Health") or {}).get("Status", "none")
r,rh=get("odo_track-redis-1")
_,dh=get("odo_track-db-1")
mounts=[x.get("Name","") for x in r["Mounts"] if x.get("Destination")=="/data" and x.get("Type")=="volume"]
if len(mounts)!=1:
    raise SystemExit("unexpected Redis data mounts")
print(mounts[0], rh, dh)
PY
)"
[[ "$redis_volume" == odo_track_odo-redis-data ]] || fail "unexpected volume identity"
[[ "$db_health" == healthy ]] || fail "database health must be healthy"
[[ "$redis_health" != healthy ]] || fail "Redis already healthy; no repair needed"
log "preflight: expected Redis volume, DB healthy, Redis broken"

run_id="${GITHUB_RUN_ID:?}"
backup_dir="/home/agent/.local/share/odotrack-redis-recovery/${run_id}"
candidate="odo_track_redis_recovery_candidate_${run_id}"
[[ ! -e "$backup_dir" ]] || fail "recovery path already exists"
if docker volume inspect "$candidate" >/dev/null 2>&1; then fail "candidate exists"; fi
mkdir -m 0700 -p "$backup_dir"

# Current Redis never reaches ready state. Stop only this broken Redis container
# while its persisted data is snapshotted. Preserve postgres/app/worker.
docker stop -t 10 odo_track-redis-1 >/dev/null || fail "failed to stop broken Redis"
trap 'docker start odo_track-redis-1 >/dev/null 2>&1 || true' EXIT

# Offline, read-only source volume archive. Never print dataset contents.
docker run --rm --network none --entrypoint sh \
  -v "${redis_volume}:/source:ro" -v "${backup_dir}:/backup" \
  redis:7-alpine -ec 'cd /source && tar -cf /backup/redis-volume.before.tar .'
chmod 0600 "$backup_dir/redis-volume.before.tar"
tar -tf "$backup_dir/redis-volume.before.tar" | grep -Fx './appendonlydir/appendonly.aof.manifest' >/dev/null || fail "AOF manifest absent from backup"
sha256sum "$backup_dir/redis-volume.before.tar" > "$backup_dir/redis-volume.before.tar.sha256"
(cd "$backup_dir" && sha256sum -c redis-volume.before.tar.sha256 >/dev/null) || fail "archive hash readback failed"
log "offline Redis backup created and SHA256 verified; bytes=$(stat -c '%s' "$backup_dir/redis-volume.before.tar")"

# Copy source to a separate named volume. Do not run --fix on Production data.
docker volume create --label odo-track-purpose=redis-aof-diagnostic "$candidate" >/dev/null
docker run --rm --network none --entrypoint sh \
  -v "${redis_volume}:/source:ro" -v "${candidate}:/target" \
  redis:7-alpine -ec 'cp -a /source/. /target/ && test -f /target/appendonlydir/appendonly.aof.manifest'

candidate_bytes="$(docker run --rm --network none --entrypoint stat -v "${candidate}:/data:ro" redis:7-alpine -c '%s' /data/appendonlydir/appendonly.aof.3.incr.aof)"
[[ "$candidate_bytes" =~ ^[0-9]+$ ]] || fail "candidate size unavailable"
[[ "$candidate_bytes" -gt 100 ]] || fail "candidate AOF unexpectedly tiny"

# The checker needs write access even without --fix; candidate is disposable.
set +e
docker run --rm --network none --entrypoint redis-check-aof \
  -v "${candidate}:/data" redis:7-alpine \
  /data/appendonlydir/appendonly.aof.manifest \
  > "$backup_dir/candidate-check.txt" 2>&1
check_rc=$?
set -e
log "candidate_readonly_check_rc=${check_rc} candidate_incr_bytes=${candidate_bytes}"
python3 - "$backup_dir/candidate-check.txt" <<'PY'
import pathlib,re,sys
s=pathlib.Path(sys.argv[1]).read_text(errors="replace")
print("candidate_check_flags="+str({
  "invalid":bool(re.search(r"not valid|bad file format|invalid|corrupt|fix",s,re.I)),
  "io_error":bool(re.search(r"read-only file system|permission denied|cannot open",s,re.I)),
  "supports_manifest":"Multi Part AOF" in s,
}))
for line in s.splitlines():
    vals=re.findall(r"(size|ok_up_to|diff|ok_up_to_line)\s*=\s*(\d+)",line,re.I)
    if vals: print("candidate_check_metrics="+repr(vals))
PY
log "stage complete; no Production AOF bytes changed. Backup and candidate retained for recovery."
