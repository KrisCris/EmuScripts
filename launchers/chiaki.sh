#!/bin/bash
LOGGER="../tools/logger.sh"
EMU_NAME="chiaki"
source "$LOGGER"

# Function to parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --local-addr)
                LOCAL_ADDR="$2"
                shift 2
                ;;
            --home)
                HOME_IP="$2"
                shift 2
                ;;
            --remote)
                REMOTE_HOST="$2"
                shift 2
                ;;
            *)
                OTHER_PARAMS+=("$1")
                shift
                ;;
        esac
    done
}

# Function to get all current IP addresses
get_current_ips() {
    ip addr show | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1
}

# Function to validate if a string is an IPv4 address
is_ipv4() {
    local ip="$1"
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0  # Valid IPv4
    else
        return 1  # Not a valid IPv4
    fi
}

# Function to resolve domain to IPv4 using getent
resolve_remote_ip() {
    ping -4 -c 1 "$REMOTE_HOST" | head -n 1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1
}

# Function to check if LOCAL_ADDR matches any of the current IPs
check_home_ip_match() {
    for ip in $CURRENT_IPS; do
        if [[ "$ip" == "$LOCAL_ADDR" ]]; then
            return 0  # Match found
        fi
    done
    return 1  # No match
}

# Main logic
log "Args: $@"
parse_arguments "$@"

# Ensure mandatory parameters are provided
if [[ -z "$HOME_IP" || -z "$REMOTE_HOST" ]]; then
    log "Usage: $0 --local-addr=<local_addr> --home=<home_ip> --remote=<remote_domain_or_ip> [other_parameters...]"
    exit 1
fi

CURRENT_IPS=$(get_current_ips)
log "IPs: $CURRENT_IPS"

if check_home_ip_match; then
    log "Current IP matches home local addr ($LOCAL_ADDR). Performing home action..."
    FINAL_IP=$HOME_IP
else
    if is_ipv4 "$REMOTE_HOST"; then
        REMOTE_IP="$REMOTE_HOST"
        log "Remote host is already an IPv4 address: $REMOTE_IP"
    else
        REMOTE_IP=$(resolve_remote_ip)
        if [[ -z "$REMOTE_IP" ]]; then
            log "Failed to resolve remote domain: $REMOTE_HOST"
            exit 1
        else
            log "Resolved $REMOTE_HOST to IP $REMOTE_IP"
        fi
    fi
    log "Performing remote action..."
    FINAL_IP=$REMOTE_IP
fi

log "Launching chiaki: /usr/bin/flatpak run io.github.streetpea.Chiaki4deck ${OTHER_PARAMS[*]} $FINAL_IP"

/usr/bin/flatpak run io.github.streetpea.Chiaki4deck ${OTHER_PARAMS[*]} $FINAL_IP
