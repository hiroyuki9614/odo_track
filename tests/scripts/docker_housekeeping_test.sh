#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOUSEKEEPING="${ROOT_DIR}/scripts/docker_housekeeping.sh"
DEPLOY_SCRIPT="${ROOT_DIR}/scripts/deploy_production.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/bin" "$TMP_DIR/docker-root"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

cat > "$TMP_DIR/bin/docker" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
printf '%s\n' "$*" >> "$COMMAND_LOG"
if [[ "${1:-}" == "info" && "${2:-}" == "--format" ]]; then
  printf '%s\n' "$FAKE_DOCKER_ROOT"
fi
EOF
chmod +x "$TMP_DIR/bin/docker"

cat > "$TMP_DIR/bin/df" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
index="$(cat "$DF_INDEX_FILE")"
line=$((index + 1))
usage="$(sed -n "${line}p" "$DF_SEQUENCE_FILE")"
if [[ -z "$usage" ]]; then
  usage="$(tail -n 1 "$DF_SEQUENCE_FILE")"
fi
printf '%s\n' "$((index + 1))" > "$DF_INDEX_FILE"
printf 'Filesystem 1024-blocks Used Available Capacity Mounted on\n'
printf '/dev/fake 10000000 4000000 %s %s%% %s\n' "$FAKE_AVAILABLE_KB" "$usage" "$FAKE_DOCKER_ROOT"
EOF
chmod +x "$TMP_DIR/bin/df"

run_case() {
  local name="$1"
  local phase="$2"
  shift 2
  local command_log="$TMP_DIR/${name}.commands"
  local sequence_file="$TMP_DIR/${name}.sequence"
  local index_file="$TMP_DIR/${name}.index"
  local available_kb="${FAKE_AVAILABLE_KB_OVERRIDE:-6000000}"

  printf '%s\n' "$@" > "$sequence_file"
  printf '0\n' > "$index_file"
  : > "$command_log"

  COMMAND_LOG="$command_log" \
  DF_SEQUENCE_FILE="$sequence_file" \
  DF_INDEX_FILE="$index_file" \
  FAKE_DOCKER_ROOT="$TMP_DIR/docker-root" \
  FAKE_AVAILABLE_KB="$available_kb" \
  DOCKER_HOST="unix:///run/user/1002/docker.sock" \
  PATH="$TMP_DIR/bin:$PATH" \
    "$HOUSEKEEPING" "$phase"
}

assert_line() {
  local file="$1"
  local expected="$2"
  grep -Fxq -- "$expected" "$file" || fail "missing command: ${expected}"
}

assert_no_line() {
  local file="$1"
  local unexpected="$2"
  if grep -Fxq -- "$unexpected" "$file"; then
    fail "unexpected command: ${unexpected}"
  fi
}

run_case healthy pre-build 70 70
healthy_log="$TMP_DIR/healthy.commands"
assert_line "$healthy_log" 'builder prune --force --filter until=24h'
assert_line "$healthy_log" 'image prune --force --filter until=24h'
assert_no_line "$healthy_log" 'builder prune --force'
assert_no_line "$healthy_log" 'image prune --force'

run_case pressure pre-build 90 90 80
pressure_log="$TMP_DIR/pressure.commands"
assert_line "$pressure_log" 'builder prune --force'
assert_line "$pressure_log" 'image prune --force'

if run_case critical pre-build 96 96 96; then
  fail 'pre-build must refuse to continue above the abort threshold'
fi

run_case post-critical post-deploy 96 96 96

if FAKE_AVAILABLE_KB_OVERRIDE=3000000 run_case low-free pre-build 80 80; then
  fail 'pre-build must refuse to continue with less than 4 GiB free'
fi

grep -Fq 'bash "$HOUSEKEEPING_SCRIPT" pre-build' "$DEPLOY_SCRIPT" \
  || fail 'deploy script does not run pre-build housekeeping'
grep -Fq 'bash "$HOUSEKEEPING_SCRIPT" post-deploy' "$DEPLOY_SCRIPT" \
  || fail 'deploy script does not run post-deploy housekeeping'

HEALTHCHECK_LIB="${ROOT_DIR}/scripts/http_health_check.sh"
[[ -f "$HEALTHCHECK_LIB" ]] || fail 'HTTP health helper is missing'

cat > "$TMP_DIR/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
printf '%s' "${FAKE_HTTP_STATUS:-200}"
exit "${FAKE_CURL_EXIT:-0}"
EOF
chmod +x "$TMP_DIR/bin/curl"

if ! FAKE_HTTP_STATUS=200 PATH="$TMP_DIR/bin:$PATH" bash -c 'source "$1"; http_health_200 "http://example.test/up" 5' _ "$HEALTHCHECK_LIB"; then
  fail 'HTTP 200 must pass health check'
fi
if FAKE_HTTP_STATUS=301 PATH="$TMP_DIR/bin:$PATH" bash -c 'source "$1"; http_health_200 "http://example.test/up" 5' _ "$HEALTHCHECK_LIB"; then
  fail 'HTTP 301 must not pass health check'
fi
if FAKE_HTTP_STATUS=503 PATH="$TMP_DIR/bin:$PATH" bash -c 'source "$1"; http_health_200 "http://example.test/up" 5' _ "$HEALTHCHECK_LIB"; then
  fail 'HTTP 503 must not pass health check'
fi
if FAKE_HTTP_STATUS=000 FAKE_CURL_EXIT=7 PATH="$TMP_DIR/bin:$PATH" bash -c 'source "$1"; http_health_200 "http://example.test/up" 5' _ "$HEALTHCHECK_LIB"; then
  fail 'curl transport failure must not pass health check'
fi

grep -Fq -- "-H 'X-Forwarded-Proto: https'" "$DEPLOY_SCRIPT" \
  || fail 'local deploy health check must mark the direct Rails request as forwarded HTTPS'
grep -Fq 'http_health_200 "$PUBLIC_HEALTH_URL" 15' "$DEPLOY_SCRIPT" \
  || fail 'public deploy health check must require exact HTTP 200'

printf 'PASS: docker housekeeping safety and pressure behavior\n'
