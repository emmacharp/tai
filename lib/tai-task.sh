#!/usr/bin/env bash
set -euo pipefail

TASK="$1"
ROOT="$2"

REQ_DIR="$ROOT/.tai_bus/requests"

mkdir -p "$REQ_DIR"

timestamp="$(date +%Y%m%d-%H%M%S)"
req_file="$REQ_DIR/task-$timestamp.json"

cat > "$req_file" <<EOF
{
  "task": "$TASK",
  "cwd": "$ROOT"
}
EOF

echo "[tai] queued: $req_file"
