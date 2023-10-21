#!/bin/sh
EMU_NAME="cemu"
EMU_FOLDER="$HOME/Applications"

LOGGER="../tools/logger.sh"
source "$LOGGER"

exe=$(find $EMU_FOLDER -iname "${EMU_NAME}*.AppImage")

chmod +x "$exe"

log "Launching \"$exe\" with params: \"${@}\""

"$exe" "${@}"
