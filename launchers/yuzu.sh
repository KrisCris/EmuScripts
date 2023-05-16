#!/bin/sh
EMU_NAME="yuzu"

LOGGER="../tools/logger.sh"
source "$LOGGER"

check_internet_connection() {
    if ! curl -s --head --fail "http://google.com" >/dev/null; then
        return 1
    fi
    return 0
}

check_for_updates() {
    if ! check_internet_connection; then
        log "No network connection. Skipping update."
        return 1
    fi

    log "Network connection available. Attempting update..."

    local exe_name=$(basename "$exe")    
    local latest_url=$(curl -s "$YUZU_EA_API_VERSIONS" | grep -m 1 -io 'https.*AppImage')
    local latest_name=$(echo "$latest_url" | grep -m 1 -io 'yuzu-early-access.*AppImage')
    
    if [[ "$latest_name" != "$exe_name" ]]; then
        log "New version \"$latest_name\" found!"
        local auth_response=$(curl -s -w "HTTPSTATUS:%{http_code}" --header "X-USERNAME: $X_USERNAME" --header "X-TOKEN: $X_TOKEN" --header "User-Agent: $User_Agent" -X POST "$YUZU_EA_API_AUTH")
        local auth_status=$(echo "$auth_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        local auth_token=$(echo "$auth_response" | sed -e 's/HTTPSTATUS:.*//g')
        log "Authenticating user \"$X_USERNAME\""
        log "Auth status: $auth_status"

        if [[ "$auth_status" = "200" ]]; then
            log "Retrieved JWT token: \"$auth_token\""
            local new_exe="$EMU_FOLDER/$latest_name"
            log "Downloading to '$new_exe'"
            if curl --fail --connect-timeout 5 --max-time 10 --header "Authorization: Bearer $auth_token" "$latest_url" --output "$new_exe" >/dev/null 2>&1; then
                log "Successfully downloaded"
                # Move the old executable only when curl completes successfully
                if [[ -f "$exe" ]]; then
                    rm "$exe"
                fi
                log "Updated!"
                exe="$new_exe"
            else
                log "Error downloading file"
                rm "$new_exe"
                return 1
            fi
        else
            log "Invalid Yuzu username or token, skipping update"
        fi
    else 
        log "No update available!"
    fi
}

launch_yuzu() {
    if [[ -z "$exe" ]]; then
        log "No executable found, exiting"
        exit 1
    fi

    chmod +x "$exe"
    log "Launching \"${@}\" with executable \"$exe\""
    "$exe" "${@}"
}

# Main execution starts here
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
exe=$(find "$EMU_FOLDER" -iname "$EMU_NAME*.AppImage")
log "Execuatble Path: '$exe'"
User_Agent="liftinstall (j-selby)"
YUZU_EA_API_VERSIONS="https://api.yuzu-emu.org/downloads/earlyaccess/"
YUZU_EA_API_AUTH="https://api.yuzu-emu.org/jwt/installer/"

check_for_updates
launch_yuzu "${@}"
