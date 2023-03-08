#!/bin/sh
emuName="cemu"
emufolder="$HOME/Applications"

exe=$(find $emufolder -iname "${emuName}*.AppImage")

chmod +x "$exe"

echo "$exe ${@}" > "cemu.log"

"$exe" "${@}"
