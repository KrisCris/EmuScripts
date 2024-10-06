#!/bin/sh
LOGGER="../tools/logger.sh"
UPDATER="../tools/updater.sh"
LAUNCHER="../tools/launcher.sh"

EMU_NAME="sudachi"
EMU_FOLDER="$HOME/Applications"
EXE="$(find "$EMU_FOLDER" -iname "$EMU_NAME*")"

YUZU_EA="https://api.yuzu-emu.org/downloads/earlyaccess/"
YUZU_EA_API_AUTH="https://api.yuzu-emu.org/jwt/installer/"
YUZU_MAINLINE="https://api.github.com/repos/yuzu-emu/yuzu-mainline/releases/latest"

source "$LOGGER"
source "$UPDATER"
source "$LAUNCHER"

# main
log "Starting"
log "Execuatble Path: '$EXE'"

run "$EXE" "${@}"
