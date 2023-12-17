#!/bin/sh
LOGGER="../tools/logger.sh"
UPDATER="../tools/updater.sh"
LAUNCHER="../tools/launcher.sh"

EMU_NAME="yuzu"
EMU_FOLDER="$HOME/Applications"
EXE="$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")"

YUZU_EA="https://api.yuzu-emu.org/downloads/earlyaccess/"
YUZU_EA_API_AUTH="https://api.yuzu-emu.org/jwt/installer/"
YUZU_MAINLINE="https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest"

source "$LOGGER"
source "$UPDATER"
source "$LAUNCHER"

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

    update_yuzu_ea "$(basename $EXE)" "$YUZU_EA" "$YUZU_EA_API_AUTH" 
    shift
else
    log "using yuzu mainline"
    update_from_github "$(basename $EXE)" "$YUZU_MAINLINE"
fi

run "$EXE" "${@}"
