#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
log() { printf '[odotrack-redis-salvage] %s\n' "$*"; }
fail() { log "STOP: $*"; exit 1; }

[[ "$(id -un)" == agent ]] || fail "unexpected principal"
[[ "$GITHUB_EVENT_NAME" == pull_request && "$GITHUB_HEAD_REF" == codex/odotrack-redis-aof-salvage-20261031 ]] || fail "unexpected workflow identity"
uid="$(id -u)"
export XDG_RUNTIME_DIR="/run/user/$uid"
export DOCKER_HOST="unix:///run/user/$uid/docker.sock"
docker info >/dev/null || fail "rootless Docker unavailable"

backup_dir="/home/agent/.local/share/odotrack-redis-recovery/41203796895"
[[ -f "$backup_dir/redis-volume.before.tar" ]] || fail "original archive not found"
(cd "$backup_dir" && sha256sum -c redis-volume.before.tar.sha256 >/dev/null) || fail "original archive hash invalid"
workdir="/home/agent/.local/share/odotrack-redis-recovery/salvage-$GITHUB_RUN_ID"
[[ ! -e "$workdir" ]] || fail "recovery path exists"
mkdir -m 0700 "$workdir"
python3 scripts/rebuild_redis_aof.py "$workdir"

redis_volume="$(docker inspect odo_track-redis-1 | python3 -c 'import json,sys; r=json.load(sys.stdin)[0]; x=[m["Name"] for m in r["Mounts"] if m.get("Destination")=="/data" and m.get("Type")=="volume"]; assert len(x)==1; print(x[0])')"
[[ "$redis_volume" == odo_track_odo-redis-data ]] || fail "unexpected Redis volume"
db_health="$(docker inspect -f '{{.State.Health.Status}}' odo_track-db-1)"
[[ "$db_health" == healthy ]] || fail "DB not healthy"
redis_health="$(docker inspect -f '{{.State.Health.Status}}' odo_track-redis-1)"
[[ "$redis_health" != healthy ]] || fail "Redis no longer broken"

candidate="odo_track_redis_salvage_candidate_$GITHUB_RUN_ID"
docker volume inspect "$candidate" >/dev/null 2>&1 && fail "candidate already exists"
docker volume create --label odo-track-purpose=redis-aof-salvage "$candidate" >/dev/null

# Reconstruct only into the newly created candidate volume.
docker run --rm --network none -v "$candidate:/data" -v "$backup_dir:/backup:ro" --entrypoint sh redis:7-alpine -ec 'cd /data && tar -xf /backup/redis-volume.before.tar'
docker run --rm --network none -v "$candidate:/data" -v "$workdir:/repair:ro" --entrypoint sh redis:7-alpine -ec 'cp /repair/repaired.incr.aof /data/appendonlydir/appendonly.aof.3.incr.aof'
expected_hash="$(cat "$workdir/repaired.sha256")"
candidate_hash="$(docker run --rm --network none -v "$candidate:/data:ro" --entrypoint sha256sum redis:7-alpine /data/appendonlydir/appendonly.aof.3.incr.aof | awk '{print $1}')"
[[ "$expected_hash" == "$candidate_hash" ]] || fail "candidate read-back hash mismatch"

# redis-check-aof opens files read-write even without --fix; run on candidate only.
docker run --rm --network none -v "$candidate:/data" --entrypoint redis-check-aof redis:7-alpine /data/appendonlydir/appendonly.aof.manifest > "$workdir/redis-aof-check.txt" 2>&1 || fail "repaired candidate AOF did not validate"
log "candidate Redis 7 multi-part AOF validation PASS"

verify_container="odo-redis-salvage-smoke-$GITHUB_RUN_ID"
docker run --rm -d --name "$verify_container" --network none --memory 750m -v "$candidate:/data" redis:7-alpine redis-server --appendonly yes --port 0 --unixsocket /tmp/redis-verify.sock --unixsocketperm 700 --auto-aof-rewrite-percentage 0 --save '' > /dev/null
trap 'docker stop "$verify_container" >/dev/null 2>&1 || true' EXIT
verified=0
for _ in $(seq 1 60); do
  if docker exec "$verify_container" redis-cli -s /tmp/redis-verify.sock PING 2>/dev/null | grep -Fxq PONG; then
    verified=1
    break
  fi
  if [[ "$(docker inspect -f '{{.State.Running}}' "$verify_container" 2>/dev/null || echo false)" != true ]]; then
    break
  fi
  sleep 1
done
[[ "$verified" -eq 1 ]] || fail "isolated Redis server could not restore repaired candidate"
key_count="$(docker exec "$verify_container" redis-cli -s /tmp/redis-verify.sock DBSIZE | tr -d '\r\n')"
[[ "$key_count" =~ ^[0-9]+$ ]] || fail "isolated key count unavailable"
log "isolated Redis PING PASS; restored_key_count=$key_count"
docker stop "$verify_container" >/dev/null
trap - EXIT

# Stop only broken Redis. Confirm the source increment still matches the backed-up original.
docker stop -t 10 odo_track-redis-1 >/dev/null || fail "cannot stop broken Redis"
trap 'docker start odo_track-redis-1 >/dev/null 2>&1 || true' EXIT
original_hash="$(docker run --rm --network none -v "$redis_volume:/data:ro" --entrypoint sha256sum redis:7-alpine /data/appendonlydir/appendonly.aof.3.incr.aof | awk '{print $1}')"
[[ "$original_hash" == "$(cat "$workdir/source.sha256")" ]] || fail "original volume differs from archived source; refusing cutover"

# Move the original AOF directory aside without deleting it, then install validated copy.
docker run --rm --network none -e REPAIR_ID="$GITHUB_RUN_ID" -v "$candidate:/source:ro" -v "$redis_volume:/target" --entrypoint sh redis:7-alpine -ec '
  original=/target/appendonlydir
  kept=/target/appendonlydir.pre-repair-$REPAIR_ID
  test -d "$original" && test ! -e "$kept" && test -f /source/appendonlydir/appendonly.aof.manifest
  mv "$original" "$kept"
  if cp -a /source/appendonlydir "$original" && test -f "$original/appendonly.aof.manifest"; then
    :
  else
    rm -rf "$original"
    mv "$kept" "$original"
    exit 1
  fi
'
log "validated AOF installed; original AOF directory retained inside volume"
docker start odo_track-redis-1 >/dev/null || fail "cannot start Redis after salvage"

redis_ready=0
for _ in $(seq 1 75); do
  status="$(docker inspect -f '{{.State.Health.Status}}' odo_track-redis-1 2>/dev/null || echo missing)"
  if [[ "$status" == healthy ]] && docker exec odo_track-redis-1 redis-cli PING 2>/dev/null | grep -Fxq PONG; then
    redis_ready=1
    break
  fi
  sleep 1
done

if [[ "$redis_ready" -ne 1 ]]; then
  log "Redis failed live health; rolling back AOF directory without deleting original"
  docker stop -t 10 odo_track-redis-1 >/dev/null 2>&1 || true
  docker run --rm --network none -e REPAIR_ID="$GITHUB_RUN_ID" -v "$redis_volume:/data" --entrypoint sh redis:7-alpine -ec '
    test -d "/data/appendonlydir.pre-repair-$REPAIR_ID"
    mv /data/appendonlydir "/data/appendonlydir.failed-salvage-$REPAIR_ID"
    mv "/data/appendonlydir.pre-repair-$REPAIR_ID" /data/appendonlydir
  ' || fail "rollback failed: backup remains available; stop"
  fail "Redis salvage not accepted; original AOF restored"
fi
trap - EXIT
log "REDIS_RECOVERY_ACCEPTED: health=healthy ping=PONG; no original AOF deleted"
