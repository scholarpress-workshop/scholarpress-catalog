#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

declare -A PDFS=(
  ["2020-12-chambers.pdf"]="https://scholarworks.indianapolis.iu.edu/bitstreams/d2a63ecc-651e-4553-a32e-6499a3f61ccc/download"
  ["2025-05-li.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/1894491a-5f86-4423-8282-5a05a54ab3df/download"
  ["2025-06-wang.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/708b0ded-f25f-45fb-8fa4-830589533000/download"
  ["2025-08-khan.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/8d546309-7a33-436f-91d5-81bb4c8ea1e4/download"
  ["2025-10-paladhi.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/23721b4d-50fc-45e8-9ef6-e1c2eb91bb59/download"
  ["2026-05-yan.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/9cf75598-787f-4987-b3db-d7a4d50905dd/download"
  ["2025-05-bent.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/b57106d3-7dae-44d9-97a1-f2e07409e5be/download"
  ["2025-06-alexander.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/89136689-273e-43b5-b925-95d8dd339aa3/download"
  ["2025-07-kim.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/2bf9d49f-3bb1-40fe-a282-a1457fbde161/download"
  ["2025-08-kniess.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/cf2bf8c1-e98f-4c02-8120-04b646f332fa/download"
  ["2025-12-johnson.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/71ce1f75-1674-4e6f-86ed-2f084570ebd9/download"
  ["2025-05-kang.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/91a53adf-5204-417c-b20a-a46fc6aa47e4/download"
  ["2025-06-heilman.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/a90cbcaf-e024-4978-be51-d69c68a4e254/download"
  ["2025-07-nguyen.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/f308f6ab-59dd-423c-b86d-010ad3f04ca0/download"
  ["2025-10-kile.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/968823bd-cdcc-4f31-aa73-da89937c3a87/download"
  ["2026-05-nagasaka.pdf"]="https://scholarworks.iu.edu/dspace/bitstreams/cc792d68-1324-4bb7-aec2-ff794b9fe1d1/download"
)

for FILE in "${!PDFS[@]}"; do
  if [ -f "$SCRIPT_DIR/$FILE" ]; then
    echo "[SKIP] $FILE already exists"
  else
    echo "[GET] $FILE"
    curl -L -o "$SCRIPT_DIR/$FILE" "${PDFS[$FILE]}"
  fi
done

echo "Done."
