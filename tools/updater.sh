set +e
check_internet() {
    curl "$1"
    if [[ $? -eq 0 ]]; then
        log 'Internet available. Check for Update'
        return 0
    fi
    log 'No Internet Connection, Skip Update'
    return 1
}

# credit to EmuDeck Team
safeDownload() {
    local outFile="$1"
    local url="$2"
    local showProgress="$3"
    local headers="$4"

    log "safeDownload()"
    log "- $outFile"
    log "- $url"
    log "- $showProgress"
    log "- $headers"

    if [ "$showProgress" == "true" ] || [[ $showProgress -eq 1 ]]; then
        request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 | tee >(stdbuf -oL tr '\r' '\n' | sed -u 's/^ *\([0-9][0-9]*\).*\( [0-9].*$\)/\1\n#Download Speed\:\2/' | zenity --progress --title "Downloading $(basename $outFile)" --width 600 --auto-close --no-cancel 2>/dev/null) && echo $'\2'${PIPESTATUS[0]})
    else
        request=$(curl -w $'\1'"%{response_code}" --fail -L "$url" -H "$headers" -o "$outFile.temp" 2>&1 && echo $'\2'0 || echo $'\2'$?)
    fi
    requestInfo=$(sed -z s/.$// <<< "${request%$'\1'*}")
    returnCodes="${request#*$'\1'}"
    httpCode="${returnCodes%$'\2'*}"
    exitCode="${returnCodes#*$'\2'}"
    log "$requestInfo"
    log "HTTP response code: $httpCode"
    log "CURL exit code: $exitCode"
    if [ "$httpCode" = "200" ] && [ "$exitCode" == "0" ]; then
        log "$name downloaded successfully";
        mv -v "$outFile.temp" "$outFile"
        return 0
    else
        log "$name download failed"
        rm -f "$outFile.temp"
        return 1
    fi
}

update_from_github() {
    local current_name=$1
    local host=$2
    if check_internet "$host"; then
        local metaData=$(curl -fSs ${host})
        local fileToDownload=$(echo ${metaData} | jq -r '.assets[] | select(.name|test(".*.AppImage$")).browser_download_url')
        local latest_name=$(echo ${metaData} | jq -r '.assets[] | select(.name|test(".*.AppImage$")).name')
        log "LATEST VERSION:  $latest_name"
        log "CURRENT VERSION: $current_name"

        if [ "$latest_name" = "$current_name" ]; then
            log "no need to update."
        elif [ -z "$latest_name" ]; then
            log "couldn't get metadata."
        else
            zenity --question --title="Update available!" --width 450 --text "Update Available!\nCurrentVer: ${current_name}\nLatestVer: ${latest_name}\nWould you like to upgrade?" --ok-label="Yes" --cancel-label="No" 2>/dev/null
            if [ $? = 0 ]; then
                log "download ${latest_name} appimage to $EMU_FOLDER/$latest_name"
                if safeDownload "$EMU_FOLDER/$latest_name" "${fileToDownload}" "1"; then
                    rm "$EMU_FOLDER/$current_name"
                    export EXE="$EMU_FOLDER/$latest_name"
                else
                    log "Error updating $EMU_NAME!"
                    zenity --error --text "Error updating $EMU_NAME!" --width=250 2>/dev/null
                fi
            fi
        fi
    fi
}

update_yuzu_ea() {
    local current_name="$1"
    local url_version="$2"
    local url_auth="$3"
    if check_internet "$url_version"; then
        local latest_url=$(curl -s "$url_version" | grep -m 1 -io 'https.*AppImage')
        local latest_name=$(echo "$latest_url" | grep -m 1 -io 'yuzu-early-access.*AppImage')
        log "LATEST VERSION:  $latest_name"
        log "CURRENT VERSION: $current_name"
        if [ -z $latest_name ]; then
            log "No new version find..."
            return 1
        fi
        if [[ "$latest_name" != "$current_name" ]]; then
            log "New version \"$latest_name\" found!"
            zenity --question --title="Update available!" --width 450 --text "Update Available!\nCurrentVer: ${current_name}\nLatestVer: ${latest_name}.\nWould you like to upgrade?" --ok-label="Yes" --cancel-label="No" 2>/dev/null
            if [ $? = 0 ]; then
                local auth_response=$(curl -s -w "HTTPSTATUS:%{http_code}" --header "X-USERNAME: $X_USERNAME" --header "X-TOKEN: $X_TOKEN" --header "User-Agent: $User_Agent" -X POST "$url_auth")
                local auth_status=$(echo "$auth_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
                local auth_token=$(echo "$auth_response" | sed -e 's/HTTPSTATUS:.*//g')
                log "Authenticating user \"$X_USERNAME\""
                log "Auth status: $auth_status"

                if [[ "$auth_status" = "200" ]]; then
                    log "Retrieved JWT token: \"$auth_token\""
                    local new_exe="$EMU_FOLDER/$latest_name"
                    log "Downloading to '$new_exe'"
                    if safeDownload "$new_exe" "$latest_url" "1" "Authorization: Bearer $auth_token"; then
                        rm "$EXE"
                        export EXE="$new_exe"
                    else
                        log "Error updating $EMU_NAME!"
                        zenity --error --text "Error updating $EMU_NAME!" --width=250 2>/dev/null
                    fi
                else
                    zenity --error --text "Invalid Yuzu username or token!" --width=250 2>/dev/null
                    log "Invalid Yuzu username or token, skipping update"
                fi
            fi
        else
            log "No update available!"
        fi
    fi
}
