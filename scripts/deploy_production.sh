#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="${ODO_PRODUCTION_DIR:-/home/agent/odo_track}"
ENV_FILE="${ODO_ENV_FILE:-${APP_DIR}/.env.production}"
COMPOSE_FILE="${ODO_COMPOSE_FILE:-${APP_DIR}/docker-compose.production.yml}"
PUBLIC_HEALTH_URL="${ODO_PUBLIC_HEALTH_URL:-https://odt.hiroyuki9614.com/up}"
LOCAL_HEALTH_URL="${ODO_LOCAL_HEALTH_URL:-http://127.0.0.1:3100/up}"
EXPECTED_USER="${ODO_DEPLOY_USER:-agent}"

log() {
  printf '[odo-deploy] %s\n' "$*"
}

fail() {
  printf '[odo-deploy] ERROR: %s\n' "$*" >&2
  exit 1
}

[[ "$(id -un)" == "$EXPECTED_USER" ]] || fail "must run as ${EXPECTED_USER}, not $(id -un)"
[[ -d "$APP_DIR/.git" ]] || fail "production checkout not found: ${APP_DIR}"
[[ -f "$ENV_FILE" ]] || fail "production env file not found: ${ENV_FILE}"

AGENT_UID="$(id -u)"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${AGENT_UID}}"
export DOCKER_HOST="${DOCKER_HOST:-unix://${XDG_RUNTIME_DIR}/docker.sock}"

case "$DOCKER_HOST" in
  unix:///run/user/*/docker.sock) ;;
  *) fail "refusing non-rootless Docker endpoint: ${DOCKER_HOST}" ;;
esac

docker info >/dev/null 2>&1 || fail "rootless Docker is not reachable at ${DOCKER_HOST}"

tracked_changes="$(git -C "$APP_DIR" status --porcelain --untracked-files=no)"
if [[ -n "$tracked_changes" ]]; then
  printf '[odo-deploy] tracked local modifications detected:\n%s\n' "$tracked_changes" >&2
  fail "production checkout has tracked local modifications"
fi

log "fetching origin/main"
git -C "$APP_DIR" fetch --prune origin main

if git -C "$APP_DIR" show-ref --verify --quiet refs/heads/main; then
  git -C "$APP_DIR" checkout main
  git -C "$APP_DIR" merge --ff-only origin/main
else
  git -C "$APP_DIR" checkout --track -b main origin/main
fi

[[ -f "$COMPOSE_FILE" ]] || fail "compose file not found after main sync: ${COMPOSE_FILE}"

compose=(
  docker compose
  --project-directory "$APP_DIR"
  --env-file "$ENV_FILE"
  -f "$COMPOSE_FILE"
)

log "building application images"
"${compose[@]}" build app worker

log "ensuring database and redis are running"
"${compose[@]}" up -d db redis

log "preparing database"
"${compose[@]}" run --rm app bundle exec rails db:prepare

log "starting application and worker"
"${compose[@]}" up -d --no-build app worker

log "waiting for local application health"
healthy=0
for _ in $(seq 1 45); do
  if curl --fail --silent --show-error --max-time 5 "$LOCAL_HEALTH_URL" >/dev/null; then
    healthy=1
    break
  fi
  sleep 2
done
[[ "$healthy" -eq 1 ]] || fail "local health check failed: ${LOCAL_HEALTH_URL}"

worker_id="$("${compose[@]}" ps -q worker)"
[[ -n "$worker_id" ]] || fail "worker container was not created"
[[ "$(docker inspect -f '{{.State.Running}}' "$worker_id")" == "true" ]] || fail "worker container is not running"

log "checking external HTTPS endpoint"
curl --fail --silent --show-error --max-time 15 "$PUBLIC_HEALTH_URL" >/dev/null \
  || fail "external health check failed: ${PUBLIC_HEALTH_URL}"

log "deployment succeeded"
"${compose[@]}" ps
