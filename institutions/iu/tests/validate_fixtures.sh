#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="ghcr.io/scholarpress-workshop/scholarpress-backend-publish-service:latest"
CATALOG_MOUNT="/catalog"
FAIL_COUNT=0
PASS_COUNT=0

run_check() {
  local pdf="$1"
  docker run --rm \
    -v "$(cd "$DIR/../../.." && pwd):$CATALOG_MOUNT:ro" \
    "$IMAGE" \
    scholarpress check \
      --spec "$CATALOG_MOUNT/iu/spec.yaml" \
      --json --quiet \
      "$CATALOG_MOUNT/iu/tests/fixtures/$pdf" 2>/dev/null
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
  else
    echo "  FAIL: expected $check_id to FAIL in $pdf"
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
  else
    echo "  FAIL: unexpected failures in $pdf: $failures"
    return 1
  fi
}

echo "=== Catalog Fixture Validation ==="
echo "Image: $IMAGE"
echo

for pdf in "$DIR/fixtures"/*.pdf; do
  name=$(basename "$pdf")
  echo "--- $name ---"

  case "$name" in
    baseline.pdf|golden.pdf)
      assert_all_pass "$name" && ((PASS_COUNT+=1)) || ((FAIL_COUNT+=1))
      ;;
    left-narrow.pdf|right-narrow.pdf|left-wide.pdf|right-wide.pdf|top-narrow.pdf|bottom-narrow.pdf|top-wide.pdf)
      assert_fails "$name" "global_margins" && ((PASS_COUNT+=1)) || ((FAIL_COUNT+=1))
      ;;
    asymmetric.pdf)
      assert_fails "$name" "margin_symmetry" && ((PASS_COUNT+=1)) || ((FAIL_COUNT+=1))
      ;;
    messy.pdf)
      echo "  SKIP: smoke test only"
      ((PASS_COUNT+=1))
      ;;
    *)
      echo "  SKIP: no expected results defined"
      ;;
  esac
  echo
done

echo "=== Results: $PASS_COUNT passed, $FAIL_COUNT failed ==="
if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
