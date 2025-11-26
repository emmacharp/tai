#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$PWD}"
shift || true
TEXT="${*:-}"

if [ -z "${TMUX:-}" ]; then
  echo "[tai] ERROR: 'tai send' must be run inside a tmux session."
  exit 1
fi

if [ -z "$TEXT" ]; then
  echo "[tai] ERROR: no text provided to send."
  exit 1
fi

BUS="$ROOT/.tai_bus"
TUI_FILE="$BUS/tui-pane.id"
if [ ! -f "$TUI_FILE" ]; then
  echo "[tai] ERROR: no tai-tui pane recorded (run 'tai tui' first)."
  exit 1
fi

TUI_PANE="$(cat "$TUI_FILE")"

tmux delete-buffer -b tai-tui >/dev/null 2>&1 || true
printf '%s' "$TEXT" | tmux load-buffer -b tai-tui -
tmux paste-buffer -b tai-tui -t "$TUI_PANE"
sleep 0.05
tmux send-keys -t "$TUI_PANE" ENTER
tmux delete-buffer -b tai-tui >/dev/null 2>&1 || true
