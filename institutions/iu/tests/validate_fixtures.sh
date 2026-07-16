#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="${SCHOLARPRESS_IMAGE:-ghcr.io/scholarpress-workshop/scholarpress-backend-publish-service:latest}"
CATALOG_MOUNT="/catalog"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FIXTURES_DIR="$(cd "$SCRIPT_DIR/fixtures" && pwd)"
CATALOG_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

FAIL_COUNT=0
PASS_COUNT=0

parse_yaml() {
  python3 -c "
import yaml, sys, json
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
print(json.dumps(data))
" "$1"
}

run_check() {
  local pdf="$1"
  if command -v scholarpress &>/dev/null; then
    scholarpress check --spec "$CATALOG_ROOT/institutions/iu/spec.yaml" --json "$pdf" 2>/dev/null
  else
    cargo run --manifest-path "$(cd "$SCRIPT_DIR/../../../.." 2>/dev/null && pwd || echo .)/scholarpress-backend/Cargo.toml" -q -p scholarpress-cli -- check --spec "$CATALOG_ROOT/institutions/iu/spec.yaml" --json "$pdf" 2>/dev/null
  fi
}

assert_fails() {
  local pdf="$1" check_id="$2"
  local output
  output=$(run_check "$pdf")
  if echo "$output" | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = [r for r in data.get('results', []) if r['check_id'] == '$check_id']
if not results: sys.exit(1)
if results[0]['status'] not in ('FAIL', 'ERROR'): sys.exit(1)
" 2>/dev/null; then
    echo "  PASS: $check_id fails as expected"
    return 0
  else
    echo "  FAIL: expected $check_id to FAIL in $(basename "$pdf")"
    return 1
  fi
}

assert_passes() {
  local pdf="$1" check_id="$2"
  local output
  output=$(run_check "$pdf")
  if echo "$output" | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = [r for r in data.get('results', []) if r['check_id'] == '$check_id']
if not results: sys.exit(1)
if results[0]['status'] not in ('FAIL', 'ERROR'): sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
    echo "  PASS: $check_id passes as expected"
    return 0
  else
    echo "  FAIL: expected $check_id to PASS in $(basename "$pdf")"
    return 1
  fi
}

assert_all_pass() {
  local pdf="$1"
  local output
  output=$(run_check "$pdf")
  local failures
  failures=$(echo "$output" | python3 -c "
import sys, json
data = json.load(sys.stdin)
fails = [r['check_id'] for r in data.get('results', [])
         if r['status'] not in ('PASS', 'MANUAL')]
print('\n'.join(fails))
" 2>/dev/null)
  if [ -z "$failures" ]; then
    echo "  PASS: all automatable checks pass"
    return 0
  else
    echo "  FAIL: unexpected failures in $(basename "$pdf"): $failures"
    return 1
  fi
}

echo "=== Catalog Fixture Validation ==="

EXPECTED=$(parse_yaml "$DIR/expected_results.yaml")

for pdf in "$FIXTURES_DIR"/*.pdf; do
  name=$(basename "$pdf")
  echo "--- $name ---"

  assertions=$(echo "$EXPECTED" | python3 -c "
import sys, json
data = json.load(sys.stdin)
fixtures = data.get('fixtures', {})
if '$name' not in fixtures:
    sys.exit(0)
f = fixtures['$name']
print(json.dumps(f))
" 2>/dev/null) || { echo "  SKIP: no expected results defined"; echo; continue; }

  assert_passes_list=$(echo "$assertions" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('\n'.join(d.get('assert_passes', [])))
" 2>/dev/null)

  assert_fails_list=$(echo "$assertions" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('\n'.join(d.get('assert_fails', [])))
" 2>/dev/null)

  pdf_passed=true

  if [ "$assert_passes_list" = "ALL" ]; then
    assert_all_pass "$pdf" || pdf_passed=false
  else
    while IFS= read -r check_id; do
      [ -z "$check_id" ] && continue
      assert_passes "$pdf" "$check_id" || pdf_passed=false
    done <<< "$assert_passes_list"
  fi

  while IFS= read -r check_id; do
    [ -z "$check_id" ] && continue
    assert_fails "$pdf" "$check_id" || pdf_passed=false
  done <<< "$assert_fails_list"

  if [ "$pdf_passed" = true ]; then
    ((PASS_COUNT+=1))
  else
    ((FAIL_COUNT+=1))
  fi
  echo
done

echo "=== Results: $PASS_COUNT passed, $FAIL_COUNT failed ==="
if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
