#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$PWD}"

BUS="$ROOT/.tai_bus"
REQ_DIR="$BUS/requests"
RES_DIR="$BUS/responses"
LOG_DIR="$BUS/logs"
LOGFILE="$LOG_DIR/agent.log"
STATUS_FILE="$BUS/status.txt"

mkdir -p "$REQ_DIR" "$RES_DIR" "$LOG_DIR"

echo "[tai] agent starting in $ROOT" | tee -a "$LOGFILE"
echo "idle" > "$STATUS_FILE"
echo "[tai] agent ready — waiting for tasks..." | tee -a "$LOGFILE"

process_request() {
	local req="$1"
	local base="$(basename "$req" .json)"
	local output="$RES_DIR/$base.response.txt"

	echo "[tai] PROCESSING: $base" | tee -a "$LOGFILE"
	echo "processing: $base" > "$STATUS_FILE"

	# Extract task via jq or sed
	task_prompt="$(jq -r .task "$req" 2>/dev/null || true)"

	if [ -z "$task_prompt" ] || [ "$task_prompt" = "null" ]; then
		task_prompt="$(sed -n 's/.*\"task\"[[:space:]]*:[[:space:]]*\"\(.*\)\".*/\1/p' "$req")"
	fi

	if [ -z "$task_prompt" ]; then
		echo "[tai] ERROR: Could not extract task from $req" | tee -a "$LOGFILE"
		task_prompt="Invalid task (no 'task' key found)."
	fi

	{
		echo ""
		echo "----- TASK START: $base ($(date)) -----"
		echo "PROMPT:"
		echo "$task_prompt"
		echo ""
		echo "EXECUTION OUTPUT:"
	} >>"$LOGFILE"

	# Only the model’s message goes to $output
	codex exec --cd "$ROOT" --full-auto "$task_prompt" \
		2>>"$LOGFILE" \
		| tee "$output"

	echo "----- TASK END: $base ($(date)) -----" >>"$LOGFILE"
	echo "" >>"$LOGFILE"

	if [ $? -eq 0 ]; then
		echo "[tai] DONE: $base" | tee -a "$LOGFILE"
		echo "idle" > "$STATUS_FILE"
	else
		echo "[tai] ERROR during task: $base" | tee -a "$LOGFILE"
		echo "error: $base" > "$STATUS_FILE"
	fi

	rm -f "$req"
}

# MAIN LOOP
while true; do
	req="$(find "$REQ_DIR" -type f -name '*.json' | sort | head -n 1 || true)"
	if [ -n "$req" ]; then
		process_request "$req"
	else
		sleep 1
	fi
done
