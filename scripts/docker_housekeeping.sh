#!/usr/bin/env bash
set -Eeuo pipefail

PHASE="${1:-}"
PRUNE_AGE="${ODO_DOCKER_PRUNE_AGE:-24h}"
HIGH_WATER_PERCENT="${ODO_DOCKER_HIGH_WATER_PERCENT:-85}"
ABORT_PERCENT="${ODO_DOCKER_ABORT_PERCENT:-95}"
MIN_FREE_GB="${ODO_DOCKER_MIN_FREE_GB:-4}"

log() {
  printf '[odo-docker-housekeeping] %s\n' "$*"
}

fail() {
  printf '[odo-docker-housekeeping] ERROR: %s\n' "$*" >&2
  exit 1
}

validate_percent() {
  local name="$1"
  local value="$2"
  [[ "$value" =~ ^[0-9]+$ ]] || fail "${name} must be an integer: ${value}"
  (( value >= 0 && value <= 100 )) || fail "${name} must be between 0 and 100: ${value}"
}

[[ "$PHASE" == "pre-build" || "$PHASE" == "post-build" || "$PHASE" == "post-deploy" ]] \
  || fail "usage: $0 {pre-build|post-build|post-deploy}"
validate_percent "ODO_DOCKER_HIGH_WATER_PERCENT" "$HIGH_WATER_PERCENT"
validate_percent "ODO_DOCKER_ABORT_PERCENT" "$ABORT_PERCENT"
[[ "$MIN_FREE_GB" =~ ^[0-9]+$ ]] || fail "ODO_DOCKER_MIN_FREE_GB must be an integer: ${MIN_FREE_GB}"
(( MIN_FREE_GB > 0 )) || fail "ODO_DOCKER_MIN_FREE_GB must be greater than zero"
MIN_FREE_KB=$((MIN_FREE_GB * 1024 * 1024))
(( ABORT_PERCENT > HIGH_WATER_PERCENT )) \
  || fail "abort percent must be greater than high-water percent"
case "${DOCKER_HOST:-}" in
  unix:///run/user/*/docker.sock) ;;
  *) fail "refusing non-rootless Docker endpoint: ${DOCKER_HOST:-unset}" ;;
esac

docker info >/dev/null 2>&1 || fail "rootless Docker is not reachable at ${DOCKER_HOST}"
docker_root="$(docker info --format '{{.DockerRootDir}}')"
[[ -n "$docker_root" && -d "$docker_root" ]] || fail "Docker root directory is unavailable: ${docker_root:-unset}"

disk_available_kb() {
  local available
  available="$(df -Pk "$docker_root" | awk 'NR == 2 { print $4 }')"
  [[ "$available" =~ ^[0-9]+$ ]] || fail "could not determine free disk space for ${docker_root}"
  printf '%s\n' "$available"
}

disk_usage_percent() {
  local usage
  usage="$(df -P "$docker_root" | awk 'NR == 2 { gsub(/%/, "", $5); print $5 }')"
  [[ "$usage" =~ ^[0-9]+$ ]] || fail "could not determine disk usage for ${docker_root}"
  printf '%s\n' "$usage"
}

routine_prune() {
  log "pruning unused build cache older than ${PRUNE_AGE}"
  docker builder prune --force --filter "until=${PRUNE_AGE}"
  log "pruning dangling images older than ${PRUNE_AGE}"
  docker image prune --force --filter "until=${PRUNE_AGE}"
}

pressure_prune() {
  log "high disk usage: pruning all unused build cache"
  docker builder prune --force
  log "high disk usage: pruning all dangling images"
  docker image prune --force
}

usage_before="$(disk_usage_percent)"
log "phase=${PHASE} docker_root=${docker_root} usage_before=${usage_before}%"

routine_prune
usage_after="$(disk_usage_percent)"

if (( usage_after >= HIGH_WATER_PERCENT )); then
  log "usage ${usage_after}% >= high-water ${HIGH_WATER_PERCENT}%"
  pressure_prune
  usage_after="$(disk_usage_percent)"
fi

available_after_kb="$(disk_available_kb)"
log "phase=${PHASE} usage_after=${usage_after}% available_after_kb=${available_after_kb}"

capacity_exhausted=0
if (( usage_after >= ABORT_PERCENT || available_after_kb < MIN_FREE_KB )); then
  capacity_exhausted=1
fi

if (( capacity_exhausted == 1 )); then
  if [[ "$PHASE" == "pre-build" ]]; then
    fail "insufficient Docker disk headroom: usage=${usage_after}% free_kb=${available_after_kb}; require usage<${ABORT_PERCENT}% and free>=${MIN_FREE_GB}GiB"
  fi
  log "WARNING: low Docker disk headroom after ${PHASE}: usage=${usage_after}% free_kb=${available_after_kb}"
fi

log "housekeeping completed"
