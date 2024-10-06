#!/bin/sh
LOGGER="../tools/logger.sh"
UPDATER="../tools/updater.sh"
LAUNCHER="../tools/launcher.sh"

EMU_NAME="ryujinx"
UPDATE_HOST="https://api.github.com/repos/Samueru-sama/Ryujinx-AppImage/releases/latest"
EMU_FOLDER="$HOME/Applications"
EXE=$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")

source "$LOGGER"
source "$UPDATER"
source "$LAUNCHER"


# main
log "Starting"
log "Execuatble Path: '$EXE'"
update_from_github "$(basename $EXE)" "$UPDATE_HOST"

COMMAND=""

if command -v gamemoderun > /dev/null 2>&1; then
    COMMAND="$COMMAND gamemoderun"
fi
exec $COMMAND "$EXE" "${@}"

#run "$EXE" "${@}"
