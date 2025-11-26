#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TMUX:-}" ]; then
  echo "[tai] ERROR: 'tai tui' must be run inside a tmux session."
  exit 1
fi

ROOT="${1:-$PWD}"

if ! command -v codex >/dev/null; then
  echo "[tai] ERROR: codex CLI is not installed or not on PATH."
  exit 1
fi

TUI_PANE="$(tmux split-window -h -c "$ROOT" -P -F '#{pane_id}' \
  "cd \"$ROOT\" && exec codex")"
tmux select-pane -t "$TUI_PANE" -T "tai-tui"
