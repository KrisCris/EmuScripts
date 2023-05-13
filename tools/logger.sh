#!/bin/sh

set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
LOG_DIR="$SCRIPT_DIR/../logs"
LOG_FILE="$LOG_DIR/$EMU_NAME.log"
BACKUP_LOG_FILE="$LOG_DIR/$EMU_NAME.bk.log"

# Create the logs directory if it doesn't exist
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

# Backup the log file if it exists
if [[ -f "$LOG_FILE" ]]; then
    mv "$LOG_FILE" "$BACKUP_LOG_FILE"
fi

log() {
    local now=$(date +'%H:%M:%S')
    echo "[$now] $1"
    echo "[$now] $1" >> "$LOG_FILE"
}