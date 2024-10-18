#!/bin/sh
LOGGER="../tools/logger.sh"
UPDATER="../tools/updater.sh"
LAUNCHER="../tools/launcher.sh"

EMU_NAME="shadps4"
if [ "$*" = "/home/deck/Applications/Sony PlayStation 4/games/CUSA03173/eboot.bin" ]; then
    EMU_NAME="bb_shadps4"
fi
UPDATE_HOST="https://api.github.com/repos/shadps4-emu/shadPS4/releases/latest"
EMU_FOLDER="$HOME/Applications/Sony PlayStation 4"
EXE=$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")

source "$LOGGER"
source "$UPDATER"
source "$LAUNCHER"

# main
log "Starting"
log "Execuatble Path: '$EXE'"
#update_from_github "$(basename $EXE)" "$UPDATE_HOST"
COMMAND=""

if command -v gamemoderun > /dev/null 2>&1; then
    COMMAND="$COMMAND gamemoderun"
fi

cd "$EMU_FOLDER"
exec $COMMAND "$EXE" "${@}"
