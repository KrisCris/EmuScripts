#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
mv "$SCRIPT_DIR/yuzu.log" "$SCRIPT_DIR/yuzu.bk.log"
log() {
    now="$(date +'%H:%M:%S')"
    echo "[$now] $1"  >> "$SCRIPT_DIR/yuzu.log"
}
yuzu_token=$(find $SCRIPT_DIR -iname ".yuzu_token")
if [ "$yuzu_token" = '' ]; then
    log "check YUZU_TOKEN_SAMPLE first, you should have a .yuzu_token file created under the same directory!"
    exit
fi

log 'Starting'
source $yuzu_token

EMU_NAME="yuzu"
emu_folder="$HOME/Applications"

exe=$(find $emu_folder -iname "$EMU_NAME*.AppImage")

User_Agent="liftinstall (j-selby)"
YUZU_EA_API_VERSIONS="https://api.yuzu-emu.org/downloads/earlyaccess/"
YUZU_EA_API_AUTH="https://api.yuzu-emu.org/jwt/installer/"

if : >/dev/tcp/8.8.8.8/53; then
    log "checking updates"
    latest_url=$(curl https://api.yuzu-emu.org/downloads/earlyaccess/ | grep -m 1 -io 'https.*AppImage')
    latest_name=$(echo $latest_url | grep -m 1 -io 'yuzu-early-access.*AppImage')
    exe_name=$(echo $exe | grep -m 1 -io 'yuzu.*AppImage')
    if [ "$latest_name" != "$exe_name" ]; then
        log "new version \"$latest_name\" found!"
        auth_response=$(curl -s -w "HTTPSTATUS:%{http_code}" --header "X-USERNAME: $X_USERNAME" --header "X-TOKEN: $X_TOKEN" --header "User-Agent: $User_Agent" -X POST "$YUZU_EA_API_AUTH")
        auth_status=$(echo $auth_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        auth_token=$(echo $auth_response | sed -e 's/HTTPSTATUS\:.*//g')
        log "authenticating user \"$X_USERNAME\""

        log "auth status: $auth_status"
        if [ $auth_status = "200" ]; then
            log "retrieved jwt token: \"$auth_token\""
            mv "$exe" "$emu_folder/yuzu.bk.AppImage"
            exe="$emu_folder/$latest_name"
            log "downloading"
            curl --header "Authorization: Bearer $auth_token" "$latest_url" --output "$exe"
            log "updated!"
        else
            log "invalid yuzu username or token, skip update"
        fi
    fi
else
    log "no internet connection"
fi

if [ "$exe" = '' ]; then
    log "no executable found, exiting"
    exit
fi

chmod +x "$exe"
log "launching \"${@}\" with executable \"$exe\""
"$exe" "${@}"