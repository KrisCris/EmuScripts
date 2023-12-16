set +e

run() {
    local exe_path="$1"
    shift

    if [[ -z "$exe_path" ]]; then
        log "No executable found, exiting"
        exit 1
    fi

    chmod +x "$exe_path"
    log "Launching \"$exe_path\" with params: \"${@}\""
    "$exe_path" "${@}"
}