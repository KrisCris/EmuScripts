set +e
check_internet() {
    if : >/dev/tcp/8.8.8.8/53; then
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
    if check_internet; then
        local currentExe=$1
        local host=$2
        local metaData=$(curl -fSs ${host})
        local fileToDownload=$(echo ${metaData} | jq -r '.assets[] | select(.name|test(".*.AppImage$")).browser_download_url')
        local newExe=$(echo ${metaData} | jq -r '.assets[] | select(.name|test(".*.AppImage$")).name')
        if [ "$newExe" = "$currentExe" ] ;then
            log "no need to update."
        elif [ -z "$newExe" ] ;then
            log "couldn't get metadata."
        else
            zenity --question --title="Update available!" --width 200 --text "Version ${newExe} available. Would you like to update?" --ok-label="Yes" --cancel-label="No" 2>/dev/null
            if [ $? = 0 ]; then
                log "download ${newExe} appimage to $EMU_FOLDER/$newExe"
                if safeDownload "$EMU_FOLDER/$newExe" "${fileToDownload}" "1"; then
                    rm "$EMU_FOLDER/$currentExe"
                    export EXE="$EMU_FOLDER/$newExe"
                else
                    log "Error updating $EMU_NAME!"
                    zenity --error --text "Error updating $EMU_NAME!" --width=250 2>/dev/null
                fi
            fi
        fi
    fi
}

update_yuzu_ea() {
    if check_internet; then
        local exe_name=$(basename "$EXE")
        local latest_url=$(curl -s "$YUZU_EA_API_VERSIONS" | grep -m 1 -io 'https.*AppImage')
        local latest_name=$(echo "$latest_url" | grep -m 1 -io 'yuzu-early-access.*AppImage')

        if [[ "$latest_name" != "$EXE_name" ]]; then
            log "New version \"$latest_name\" found!"
            zenity --question --title="Yuzu update available!" --width 200 --text "Yuzu ${currentVer} available. Would you like to update?" --ok-label="Yes" --cancel-label="No" 2>/dev/null
            if [ $? = 0 ]; then
                local auth_response=$(curl -s -w "HTTPSTATUS:%{http_code}" --header "X-USERNAME: $X_USERNAME" --header "X-TOKEN: $X_TOKEN" --header "User-Agent: $User_Agent" -X POST "$YUZU_EA_API_AUTH")
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
