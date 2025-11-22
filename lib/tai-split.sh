#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TMUX:-}" ]; then
  echo "[tai] ERROR: 'tai split' must be run inside a tmux session."
  exit 1
fi

ROOT="${1:-$PWD}"
LOGFILE="$ROOT/.tai_bus/logs/agent.log"
mkdir -p "$(dirname "$LOGFILE")"

# Ensure logs exist
touch "$LOGFILE"

# Use user shell
USER_SHELL="${SHELL:-$(tmux show -g default-shell | awk '{print $2}')}"
[ -z "$USER_SHELL" ] && USER_SHELL="/bin/bash"

# TOP-RIGHT PANE: tai agent
tmux split-window -h -p 35 -c "$ROOT" \
    "echo '[tai] agent starting…'; tai agent-loop \"$ROOT\""

tmux select-pane -R

# BOTTOM-RIGHT PANE: live log viewer
tmux split-window -v -p 50 -c "$ROOT" "tail -f \"$LOGFILE\""

# return to left pane
tmux select-pane -L
