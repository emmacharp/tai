#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TMUX:-}" ]; then
  echo "[tai] ERROR: 'tai tui' must be run inside a tmux session."
  exit 1
fi

ROOT="${1:-$PWD}"
BUS="$ROOT/.tai_bus"
mkdir -p "$BUS"
TUI_FILE="$BUS/tui-pane.id"

ORIGINAL_PANE="$(tmux display-message -p '#{pane_id}')"

if ! command -v codex >/dev/null; then
  echo "[tai] ERROR: codex CLI is not installed or not on PATH."
  exit 1
fi

TUI_PANE="$(tmux split-window -h -c "$ROOT" -P -F '#{pane_id}' \
  "cd \"$ROOT\" && exec codex")"
echo "$TUI_PANE" > "$TUI_FILE"
tmux select-pane -t "$TUI_PANE" -T "tai-tui"
tmux select-pane -t "$ORIGINAL_PANE"
