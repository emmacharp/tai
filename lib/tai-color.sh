#!/usr/bin/env bash

# tai-color library — loadable from any tai script

# Only enable strict mode when executed directly so sourcing stays safe.
if [[ "${BASH_SOURCE[0]:-}" == "$0" ]]; then
    set -euo pipefail
fi

# ANSI Colors
RED="\033[31m"
GRN="\033[32m"
YLW="\033[33m"
BLU="\033[34m"
MAG="\033[35m"
CYN="\033[36m"
WHT="\033[37m"
DIM="\033[2m"
BOLD="\033[1m"
RESET="\033[0m"

# --------------------------------------
# tai_color_line "line"
# Colorize a single line based on pattern
# --------------------------------------
tai_color_line() {
    local line="$1"

    # TASK BOUNDARIES
    if [[ "$line" == "----- TASK START"* ]]; then
        printf "${BOLD}${MAG}%s${RESET}\n" "$line"
        return
    fi

    if [[ "$line" == "----- TASK END"* ]]; then
        printf "${BOLD}${GRN}%s${RESET}\n" "$line"
        return
    fi

    # TAI STATUS
    if [[ "$line" == "[tai] PROCESSING"* ]]; then
        printf "${BOLD}${CYN}%s${RESET}\n" "$line"
        return
    fi

    if [[ "$line" == "[tai] DONE"* ]]; then
        printf "${BOLD}${GRN}%s${RESET}\n" "$line"
        return
    fi

    if [[ "$line" == "[tai] ERROR"* ]]; then
        printf "${BOLD}${RED}%s${RESET}\n" "$line"
        return
    fi

    # TIMESTAMP LINES (safe glob, escaped parentheses)
    if [[ "$line" == *"("*")"* && "$line" == *" 20"??")"* ]]; then
        printf "${DIM}%s${RESET}\n" "$line"
        return
    fi

    # PROMPT INDICATORS
    if [[ "$line" == "PROMPT:"* ]]; then
        printf "${BOLD}${YLW}%s${RESET}\n" "$line"
        return
    fi

    # EXECUTION OUTPUT HEADER
    if [[ "$line" == "EXECUTION OUTPUT:"* ]]; then
        printf "${BOLD}${BLU}%s${RESET}\n" "$line"
        return
    fi

    # TOOL OUTPUT
    if [[ "$line" == tool:* ]]; then
        printf "${MAG}%s${RESET}\n" "$line"
        return
    fi

    # JSON-LIKE STRUCTURES
    if [[ "$line" == \{* ]] || [[ "$line" == \}* ]]; then
        printf "${CYN}%s${RESET}\n" "$line"
        return
    fi

    # DEFAULT
    printf "%s\n" "$line"
}

# --------------------------------------
# tai_color_stream < input
# Colorize full stream
# --------------------------------------
tai_color_stream() {
    while IFS= read -r line; do
        tai_color_line "$line"
    done
}

# When run as a standalone filter, stream stdin through the colorizer.
if [[ "${BASH_SOURCE[0]:-}" == "$0" ]]; then
    tai_color_stream
fi
