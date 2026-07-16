#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="${SCHOLARPRESS_IMAGE:-ghcr.io/scholarpress-workshop/scholarpress-backend-publish-service:latest}"
CATALOG_MOUNT="/catalog"

SCRIPT_DIR="$DIR"
FIXTURES_DIR="$DIR/fixtures"
CATALOG_ROOT="$(cd "$DIR/../../.." && pwd)"

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
  docker run --rm \
    -v "$CATALOG_ROOT:$CATALOG_MOUNT:ro" \
    "$IMAGE" \
    scholarpress check \
      --spec "$CATALOG_MOUNT/institutions/iu/spec.yaml" \
      --json \
      "$CATALOG_MOUNT/institutions/iu/tests/fixtures/$(basename "$pdf")" 2>/tmp/check-stderr.txt
}

# ---- Phase 1: diagnostic ----
echo "=== Catalog Fixture Validation ==="
echo "CATALOG_ROOT=$CATALOG_ROOT"
echo "--- diagnostic: docker pull ---"
docker pull "$IMAGE" 2>&1 || true
echo "--- diagnostic: test check on baseline.pdf ---"
run_check "$FIXTURES_DIR/baseline.pdf" > /tmp/check-stdout.txt 2>/dev/null; echo "exit=$?"
echo "STDOUT (first 500 chars):"
head -c 500 /tmp/check-stdout.txt 2>/dev/null || echo "(empty)"
echo ""
echo "STDERR (first 500 chars):"
head -c 500 /tmp/check-stderr.txt 2>/dev/null || echo "(empty)"
exit 0
