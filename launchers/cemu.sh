#!/bin/sh
LOGGER="../tools/logger.sh"
UPDATER="../tools/updater.sh"
LAUNCHER="../tools/launcher.sh"

source "$LOGGER"
source "$UPDATER"
source "$LAUNCHER"

EMU_NAME="cemu"
UPDATE_HOST="https://api.github.com/repos/cemu-project/Cemu/releases/latest"
EMU_FOLDER="$HOME/Applications"
EXE=$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")

# main
log "Starting"
log "Execuatble Path: '$EXE'"
update_from_github "$(basename $EXE)" "$UPDATE_HOST"

run "$EXE" "${@}"