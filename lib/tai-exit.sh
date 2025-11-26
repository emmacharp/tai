#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TMUX:-}" ]; then
  echo "[tai] ERROR: 'tai exit' must be run inside a tmux session."
  exit 1
fi

# current session name
SESSION="$(tmux display-message -p '#{session_name}')"

# kill panes with titles tai-agent or tai-log (if present)
for pane in $(tmux list-panes -t "$SESSION" -F '#{pane_id} #{pane_title}' | awk '$2=="tai-agent" || $2=="tai-log"{print $1}'); do
  tmux kill-pane -t "$pane"
done

echo "[tai] closed agent/log panes in session $SESSION"
