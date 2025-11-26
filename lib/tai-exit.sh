#!/usr/bin/env bash
set -euo pipefail

# abort when we're not inside tmux
if [ -z "${TMUX:-}" ]; then
  echo "[tai] ERROR: 'tai exit' must be run inside a tmux session."
  exit 1
fi

# current session name
SESSION="$(tmux display-message -p '#{session_name}')"
ROOT="${1:-$PWD}"
BUS="$ROOT/.tai_bus"
TUI_FILE="$BUS/tui-pane.id"

# close agent/log/tui panes
tmux list-panes -t "$SESSION" -F '#{pane_id} #{pane_title}' | while read -r pane title; do
  case "$title" in
    tai-tui)
      tmux send-keys -t "$pane" "exit" C-m
      sleep 0.1
      ;;
  esac

  case "$title" in
    tai-agent|tai-log|tai-tui)
      tmux kill-pane -t "$pane"
      ;;
  esac
done

rm -f "$TUI_FILE"
echo "[tai] closed agent/log panes in session $SESSION"
