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

# Keep track of the original pane so we can return to it
LEFT_PANE="$(tmux display-message -p '#{pane_id}')"

# TOP-RIGHT PANE: tai agent
tmux split-window -h -p 35 -c "$ROOT" \
  "echo '[tai] agent starting…'; \
   if command -v bat >/dev/null; then \
     tai agent-loop \"$ROOT\" | bat --paging=never --color=always --file-name agent.log.md; \
   elif [ -x \"$HOME/.local/lib/tai/tai-color.sh\" ]; then \
     tai agent-loop \"$ROOT\" | \"$HOME/.local/lib/tai/tai-color.sh\"; \
   else \
     tai agent-loop \"$ROOT\"; \
   fi"
# New pane is active; capture and title it
AGENT_PANE="$(tmux display-message -p '#{pane_id}')"
tmux select-pane -T "tai-agent"

# BOTTOM-RIGHT PANE: live log viewer (split the agent pane)
tmux split-window -t "$AGENT_PANE" -v -p 35 -c "$ROOT" \
  "if command -v vim >/dev/null; then \
     vim -n +\"syntax on\" \
         +\"set filetype=markdown\" \
         +\"setlocal nowrap noswapfile nobackup noundofile autoread updatetime=1000 nomodifiable ro\" \
         +\"normal! G\" \
         +\"autocmd CursorHold,CursorHoldI,BufEnter * silent! checktime | silent! normal! G | redraw!\" \"$LOGFILE\"; \
   elif command -v bat >/dev/null; then \
     tail -f \"$LOGFILE\" | bat --paging=never --color=always --file-name agent.log.md; \
   else \
     tail -f \"$LOGFILE\"; \
   fi"
tmux select-pane -T "tai-log"

# return to left pane
tmux select-pane -t "$LEFT_PANE"
