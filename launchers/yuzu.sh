#!/bin/sh
EMU_NAME="yuzu"

LOGGER="../tools/logger.sh"
UPDATER="../tools/updater.sh"
source "$LOGGER"
source "$UPDATER"

launch_yuzu() {
    if [[ -z "$EXE" ]]; then
        log "No EXEcutable found, exiting"
        exit 1
    fi

    chmod +x "$EXE"
    log "Launching \"$EXE\" with params: \"${@}\""
    "$EXE" "${@}"
}

# Main EXEcution starts here
log "Starting"

# Check for the existence of .yuzu_token file
yuzu_token=$(find "$SCRIPT_DIR" -iname ".yuzu_token")
if [[ -z "$yuzu_token" ]]; then
    log "Check YUZU_TOKEN_SAMPLE first, you should have a .yuzu_token file created under the same directory!"
    exit 1
fi

log "Located token file '$yuzu_token'"
source "$yuzu_token"

EMU_FOLDER="$HOME/Applications"
EXE=$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")
log "Execuatble Path: '$EXE'"
User_Agent="liftinstall (j-selby)"
YUZU_EA_API_VERSIONS="https://api.yuzu-emu.org/downloads/earlyaccess/"
YUZU_EA_API_AUTH="https://api.yuzu-emu.org/jwt/installer/"

update_yuzu_ea

launch_yuzu "${@}"
