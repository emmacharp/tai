#!/usr/bin/env bash
set -euo pipefail

# Ensure we’re at the project root
tai_find_project_root() {
    # Strategy: if .tai_bus exists, use it;
    # otherwise, create at current dir.
    if [ -d ".tai_bus" ]; then
        echo "$PWD"
        return
    fi

    # If parent directories contain .tai_bus, use that
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.tai_bus" ]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done

    # Default: create in current directory
    mkdir -p "$PWD/.tai_bus/requests" "$PWD/.tai_bus/responses"
    echo "$PWD"
}

tai_require_tai_bus() {
    local root="$1"
    mkdir -p "$root/.tai_bus/requests" "$root/.tai_bus/responses"
}
