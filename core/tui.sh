draw_dashboard() {
    clear
    
    # --- System Metrics ---
    local HOSTNAME=$(hostname)
    local IP=$(curl -s4 ifconfig.me 2>/dev/null || echo "Unknown")
    local UPTIME=$(uptime -p | sed 's/up //')
    local DATE=$(date +"%A, %d %B %Y - %T")
    
    # RAM Usage & Bar
    local RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    local RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
    local RAM_PERCENT=0
    [ "$RAM_TOTAL" -gt 0 ] && RAM_PERCENT=$((RAM_USED * 100 / RAM_TOTAL))
    local BAR_LENGTH=15
    local FILLED_LEN=$((RAM_PERCENT * BAR_LENGTH / 100))
    local EMPTY_LEN=$((BAR_LENGTH - FILLED_LEN))
    local RAM_BAR="["$(printf "%${FILLED_LEN}s" | tr ' ' '#')$(printf "%${EMPTY_LEN}s" | tr ' ' '-')"]"

    # Active Accounts Counter
    local SSH_USERS=$(awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd | wc -l)
    local XRAY_USERS=0
    if [ -f "/usr/local/etc/xray/config.json" ]; then
        XRAY_USERS=$(jq -r '.inbounds[0].settings.clients | length' /usr/local/etc/xray/config.json 2>/dev/null || echo "0")
    fi

    # Service Status Indicators
    local SSH_STAT=$(systemctl is-active --quiet ssh && echo -e "\033[0;32m● ON\033[0m" || echo -e "\033[0;31m● OFF\033[0m")
    local XRAY_STAT=$(systemctl is-active --quiet xray && echo -e "\033[0;32m● ON\033[0m" || echo -e "\033[0;31m● OFF\033[0m")
    local DNS_STAT=$(systemctl is-active --quiet dnstt-server && echo -e "\033[0;32m● ON\033[0m" || echo -e "\033[0;31m● OFF\033[0m")

    # --- Dynamic Padding Helper ---
    # This ensures the right border always aligns perfectly regardless of variable lengths
    print_line() {
        local text="$1"
        local text_no_ansi=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\x1b(B//g')
        local length=${#text_no_ansi}
        local pad=$(( 56 - length ))
        [ $pad -lt 0 ] && pad=0
        local padding=$(printf "%${pad}s" "")
        echo -e "\033[0;36m│ \033[0m${text}${padding} \033[0;36m│\033[0m"
    }

    # --- Render Dashboard ---
    echo -e "\033[0;36m┌──────────────────────────────────────────────────────────┐\033[0m"
    print_line "\033[1;37m                 TECHFEEDS VPN PRO\033[0m"
    echo -e "\033[0;36m├──────────────────────────────────────────────────────────┤\033[0m"
    print_line "\033[1;37mDate:\033[0m \033[0;32m$DATE\033[0m"
    print_line "\033[1;37mHost:\033[0m \033[0;33m$HOSTNAME\033[0m \033[1;37m| IP:\033[0m \033[0;33m$IP\033[0m"
    print_line "\033[1;37mUptime:\033[0m \033[0;36m$UPTIME\033[0m"
    print_line "\033[1;37mRAM:\033[0m \033[0;32m$RAM_BAR\033[0m \033[0;33m${RAM_PERCENT}%\033[0m (${RAM_USED}MB / ${RAM_TOTAL}MB)"
    echo -e "\033[0;36m├──────────────────────────────────────────────────────────┤\033[0m"
    print_line "\033[1;37mSERVICES:\033[0m SSH $SSH_STAT  \033[1;37mXRAY\033[0m $XRAY_STAT  \033[1;37mDNSTT\033[0m $DNS_STAT"
    print_line "\033[1;37mACCOUNTS:\033[0m \033[0;33m${SSH_USERS}\033[0m SSH Users | \033[0;33m${XRAY_USERS}\033[0m Xray Clients"
    
    # --- Segmented Menu Layout ---
    echo -e "\033[0;36m├──────────────────────────────────────────────────────────┤\033[0m"
    print_line "\033[1;33m[ PROTOCOL MANAGEMENT ]\033[0m"
    print_line "  \033[1;32m[1]\033[0m \033[0;36mSSH & SSHWS Manager\033[0m"
    print_line "  \033[1;32m[2]\033[0m \033[0;36mVLESS Manager\033[0m"
    print_line "  \033[1;32m[3]\033[0m \033[0;36mVMESS Manager\033[0m"
    print_line "  \033[1;32m[4]\033[0m \033[0;36mTrojan Manager\033[0m"
    echo -e "\033[0;36m├──────────────────────────────────────────────────────────┤\033[0m"
    print_line "\033[1;33m[ SERVER & AUTOMATION ]\033[0m"
    print_line "  \033[1;32m[5]\033[0m \033[0;36mXray & Transport Manager\033[0m"
    print_line "  \033[1;32m[6]\033[0m \033[0;36mSSL/TLS & Domain Manager\033[0m"
    print_line "  \033[1;32m[7]\033[0m \033[0;36mServer & Security Manager\033[0m"
    print_line "  \033[1;32m[8]\033[0m \033[0;36mService & Port Manager\033[0m"
    echo -e "\033[0;36m├──────────────────────────────────────────────────────────┤\033[0m"
    print_line "\033[1;33m[ DIAGNOSTICS & TOOLS ]\033[0m"
    print_line "  \033[1;32m[9]\033[0m \033[0;36mMonitoring & Tools\033[0m"
    print_line "  \033[1;32m[10]\033[0m \033[0;36mAdvanced Settings\033[0m"
    
    echo -e "\033[0;31m├──────────────────────────────────────────────────────────┤\033[0m"
    echo -e "\033[0;31m│  [0] Exit Techfeeds VPN Pro                              │\033[0m"
    echo -e "\033[0;31m└──────────────────────────────────────────────────────────┘\033[0m"
}
