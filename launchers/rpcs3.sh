#!/bin/sh
EMU_NAME="rpcs3"

LOGGER="../tools/logger.sh"
source "$LOGGER"

launch() {
    if [[ -z "$EXE" ]]; then
        log "No Executable found, exiting"
        exit 1
    fi

    chmod +x "$EXE"
    log "Launching \"$EXE\" with params: \"${@}\""
    "$EXE" "${@}"
}

# Main EXEcution starts here
log "Starting"


EMU_FOLDER="$HOME/Applications"
EXE=$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")
log "Execuatble Path: '$EXE'"
UPDATE_HOST="https://api.github.com/repos/RPCS3/rpcs3-binaries-linux/releases/latest"
UPDATER="../tools/updater.sh"
source "$UPDATER"
update_from_github "$(basename $EXE)" "$UPDATE_HOST"
echo $?
launch "${@}"
