#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
expected_api_base='https://equipment-api.sentient-octopus.dev'

assert_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq -- "$expected" "$file"; then
    printf 'Missing expected text in %s: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

assert_not_contains() {
  local file="$1"
  local unexpected="$2"
  if grep -Fq -- "$unexpected" "$file"; then
    printf 'Found forbidden text in %s: %s\n' "$file" "$unexpected" >&2
    exit 1
  fi
}

assert_contains "$repo_root/Dockerfile" "ARG API_BASE_URL=$expected_api_base"
assert_contains "$repo_root/Dockerfile" "RUN test \"\$API_BASE_URL\" = \"$expected_api_base\""
assert_contains "$repo_root/docker-compose.yml" "API_BASE_URL: \${API_BASE_URL:-$expected_api_base}"
assert_contains "$repo_root/lib/main.dart" "defaultValue: '$expected_api_base'"
assert_contains "$repo_root/.github/workflows/container.yml" "API_BASE_URL: $expected_api_base"
assert_not_contains "$repo_root/nginx.conf" 'try_files $uri $uri/ /index.html'
assert_contains "$repo_root/nginx.conf" 'location ~ ^/staging(?:/|$)'
assert_contains "$repo_root/nginx.conf" 'location ~ ^/api(?:/|$)'
assert_contains "$repo_root/nginx.conf" 'return 405;'
assert_contains "$repo_root/nginx.conf" 'add_header Allow "GET, HEAD" always;'

printf '%s\n' 'Static frontend contract checks passed.'

image="${1:-}"
if [[ -z "$image" ]]; then
  printf '%s\n' 'Container smoke checks skipped: no image argument supplied.'
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' 'Container smoke checks skipped: docker is unavailable.'
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  printf '%s\n' 'curl is required for container smoke checks.' >&2
  exit 1
fi

container_name='equipment-manager-frontend-contract'
port="${FRONTEND_CONTRACT_PORT:-18083}"
base_url="http://127.0.0.1:${port}"
body_file="$(mktemp)"
headers_file="$(mktemp)"

cleanup() {
  docker rm --force "$container_name" >/dev/null 2>&1 || true
  rm -f "$body_file" "$headers_file"
}
trap cleanup EXIT

docker rm --force "$container_name" >/dev/null 2>&1 || true
docker run --detach --name "$container_name" --publish "127.0.0.1:${port}:80" "$image" >/dev/null

for attempt in $(seq 1 30); do
  status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$base_url/healthz")"
  if [[ "$status" == '200' ]]; then
    break
  fi
  sleep 2
done

assert_response() {
  local method="$1"
  local path="$2"
  local expected_status="$3"
  local expected_body="${4:-}"
  local status

  : >"$body_file"
  : >"$headers_file"
  status="$(curl --silent --show-error --request "$method" \
    --dump-header "$headers_file" --output "$body_file" \
    --write-out '%{http_code}' "$base_url$path")"
  if [[ "$status" != "$expected_status" ]]; then
    printf '%s %s expected HTTP %s, got %s\n' "$method" "$path" "$expected_status" "$status" >&2
    exit 1
  fi
  if [[ -n "$expected_body" ]] && ! printf '%s' "$expected_body" | cmp -s - "$body_file"; then
    printf 'Unexpected response body for %s %s\n' "$method" "$path" >&2
    exit 1
  fi
}

assert_allow_header() {
  if ! grep -Eiq '^Allow:[[:space:]]*GET, HEAD\r?$' "$headers_file"; then
    printf 'Missing Allow: GET, HEAD header\n' >&2
    exit 1
  fi
}

assert_response GET / 200
grep -Fq 'Equipment Manager' "$body_file"
assert_response HEAD / 200
assert_response POST / 405
assert_allow_header

assert_response GET /healthz 200 $'ok\n'
assert_response HEAD /healthz 200
assert_response POST /healthz 405
assert_allow_header

assert_response GET /index.html 200
assert_response POST /index.html 405
assert_allow_header

for path in /staging /staging/ /staging/private /api /api/ /api/v1 /readyz /missing; do
  assert_response GET "$path" 404
done
assert_response POST /missing 404

printf '%s\n' 'Container frontend contract smoke checks passed.'
