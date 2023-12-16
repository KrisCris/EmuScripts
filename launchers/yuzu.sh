#!/bin/sh

LOGGER="../tools/logger.sh"
UPDATER="../tools/updater.sh"
LAUNCHER="../tools/launcher.sh"

source "$LOGGER"
source "$UPDATER"
source "$LAUNCHER"

EMU_NAME="yuzu"
EMU_FOLDER="$HOME/Applications"
EXE=$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")

# main
log "Starting"
log "Execuatble Path: '$EXE'"
if [[ "$1" == "--ea" ]]; then
    log "using yuzu ea"
    # Check for the existence of .yuzu_token file
    yuzu_token=$(find "$SCRIPT_DIR" -iname ".yuzu_token")
    if [[ -z "$yuzu_token" ]]; then
        log "Check YUZU_TOKEN_SAMPLE first, you should have a .yuzu_token file created under the same directory!"
        exit 1
    fi

    log "Located token file: '$yuzu_token'"
    source "$yuzu_token"

    User_Agent="liftinstall (j-selby)"
    YUZU_EA_API_VERSIONS="https://api.yuzu-emu.org/downloads/earlyaccess/"
    YUZU_EA_API_AUTH="https://api.yuzu-emu.org/jwt/installer/"
    update_yuzu_ea
    shift
else
    log "using yuzu mainline"
    UPDATE_HOST="https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest"
    update_from_github "$(basename $EXE)" "$UPDATE_HOST"
fi

run "$EXE" "${@}"
