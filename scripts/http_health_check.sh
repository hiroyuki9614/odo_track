#!/usr/bin/env bash

http_health_200() {
  local url="$1"
  local timeout_seconds="$2"
  shift 2

  local status
  if ! status="$(curl \
    --silent \
    --show-error \
    --output /dev/null \
    --write-out '%{http_code}' \
    --max-time "$timeout_seconds" \
    "$@" \
    "$url")"; then
    return 1
  fi

  [[ "$status" == "200" ]]
}
