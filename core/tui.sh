draw_dashboard() {
    clear
    
    # --- System Metrics ---
    local HOSTNAME=$(cat /etc/techfeeds/domain 2>/dev/null || hostname)
    local IP=$(curl -s4 ifconfig.me 2>/dev/null || echo "Unknown")
    local SYS_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/ //g')
    local DISK_USAGE=$(df -h / | awk 'NR==2 {print $5 " of " $2}')
    local UPTIME=$(uptime -p | sed 's/up //')
    local DATE=$(date +"%a %b %d %r %Z %Y")
    
    # RAM Usage & Bar
    local RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    local RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
    local RAM_PERCENT=0
    [ "$RAM_TOTAL" -gt 0 ] && RAM_PERCENT=$((RAM_USED * 100 / RAM_TOTAL))
    local BAR_LENGTH=15
    local FILLED_LEN=$((RAM_PERCENT * BAR_LENGTH / 100))
    local EMPTY_LEN=$((BAR_LENGTH - FILLED_LEN))
    local RAM_BAR="\033[0;36m[\033[0;32m"$(printf "%${FILLED_LEN}s" | tr ' ' '█')$(printf "%${EMPTY_LEN}s" | tr ' ' '░')"\033[0;36m]\033[0m"

    # Active Accounts Counter
    local SSH_USERS=$(awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd | wc -l)
    local XRAY_USERS=0
    if [ -f "/usr/local/etc/xray/config.json" ]; then
        XRAY_USERS=$(jq -r '.inbounds[].settings.clients[]? | select(.email != null) | .email' /usr/local/etc/xray/config.json 2>/dev/null | sort -u | wc -l)
    fi

    # Raw Status for exact padding calculation (No ANSI)
    local SSH_RAW=$(systemctl is-active --quiet ssh && echo "[OK]" || echo "[FAIL]")
    local XRAY_RAW=$(systemctl is-active --quiet xray && echo "[OK]" || echo "[FAIL]")
    local DNS_RAW=$(systemctl is-active --quiet dnstt-server && echo "[OK]" || echo "[FAIL]")

    # Colored Status Indicators
    local SSH_STAT=$(systemctl is-active --quiet ssh && echo -e "\033[0;32m[OK]\033[0m" || echo -e "\033[0;31m[FAIL]\033[0m")
    local XRAY_STAT=$(systemctl is-active --quiet xray && echo -e "\033[0;32m[OK]\033[0m" || echo -e "\033[0;31m[FAIL]\033[0m")
    local DNS_STAT=$(systemctl is-active --quiet dnstt-server && echo -e "\033[0;32m[OK]\033[0m" || echo -e "\033[0;31m[FAIL]\033[0m")

    # Dynamic spacing strings to ensure perfect right-side border alignment
    local L_HOST="  Host : $IP"
    local L_UP="  Up   : $UPTIME"
    local L_RAM="  RAM  : [███████████████] ${RAM_PERCENT}% (${RAM_USED}MB/${RAM_TOTAL}MB)"
    local L_SVC="  SVC  : Xray:${XRAY_RAW} SSH:${SSH_RAW} DNSTT:${DNS_RAW}"
    local L_ACT="  📊 Active -> SSH:${SSH_USERS} Xray:${XRAY_USERS}"

    # Calculate exact padding (Box width is 57 inner characters)
    local PAD_HOST=$(( 57 - ${#L_HOST} ))
    local PAD_UP=$(( 57 - ${#L_UP} ))
    local PAD_RAM=$(( 57 - ${#L_RAM} ))
    local PAD_SVC=$(( 57 - ${#L_SVC} ))
    local PAD_ACT=$(( 57 - ${#L_ACT} ))

    # Clamp padding to 0 to prevent bash errors
    [ $PAD_HOST -lt 0 ] && PAD_HOST=0
    [ $PAD_UP -lt 0 ] && PAD_UP=0
    [ $PAD_RAM -lt 0 ] && PAD_RAM=0
    [ $PAD_SVC -lt 0 ] && PAD_SVC=0
    [ $PAD_ACT -lt 0 ] && PAD_ACT=0

    # --- Render Dashboard ---
    echo -e ""
    echo -e " \033[0;32m* Documentation:  https://github.com/albertlanc/smartking\033[0m"
    echo -e " \033[0;32m* Management:     TECHFEEDS VPN PRO\033[0m"
    echo -e " \033[0;32m* Support:        https://t.me/techfeeds\033[0m"
    echo -e ""
    echo -e " \033[0;32mSystem information as of $DATE\033[0m"
    echo -e ""
    echo -e "   \033[0;32mSystem load:\033[0m            $SYS_LOAD"
    echo -e "   \033[0;32mUsage of /:\033[0m             $DISK_USAGE"
    echo -e ""
    
    echo -e "\033[0;34m ┌── \033[0;33mTECHFEEDS VPN PRO V2.5\033[0;34m ───────────────────────────────┐\033[0m"
    echo -e "\033[0;34m │                                                         │\033[0m"
    echo -e "\033[0;34m │\033[0;36m  Host : \033[0;32m$IP\033[0m$(printf "%${PAD_HOST}s" "")\033[0;34m│\033[0m"
    echo -e "\033[0;34m │\033[0;36m  Up   : \033[0;32m$UPTIME\033[0m$(printf "%${PAD_UP}s" "")\033[0;34m│\033[0m"
    echo -e "\033[0;34m │\033[0;36m  RAM  : $RAM_BAR \033[0;31m${RAM_PERCENT}%\033[0;36m (${RAM_USED}MB/${RAM_TOTAL}MB)\033[0m$(printf "%${PAD_RAM}s" "")\033[0;34m│\033[0m"
    echo -e "\033[0;34m │\033[0;36m  SVC  : \033[0;37mXray:${XRAY_STAT}\033[0;37m SSH:${SSH_STAT}\033[0;37m DNSTT:${DNS_STAT}\033[0m$(printf "%${PAD_SVC}s" "")\033[0;34m│\033[0m"
    echo -e "\033[0;34m │\033[0;36m  \033[1;37m📊 Active -> \033[0;32mSSH:${SSH_USERS} \033[0;32mXray:${XRAY_USERS}\033[0m$(printf "%${PAD_ACT}s" "")\033[0;34m│\033[0m"
    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
    echo -e ""
    echo -e "\033[0;34m ┌─ \033[0;34mPROTOCOL MANAGEMENT \033[0;34m───────────────────────────────────┐\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m SSH & SSHWS Manager                               \033[0;34m│\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[02]\033[0;36m VLESS Manager                                     \033[0;34m│\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[03]\033[0;36m VMESS Manager                                     \033[0;34m│\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[04]\033[0;36m Trojan Manager                                    \033[0;34m│\033[0m"
    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
    echo -e ""
    echo -e "\033[0;34m ┌─ \033[0;34mSERVER & AUTOMATION \033[0;34m───────────────────────────────────┐\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[05]\033[0;36m Xray & Transport Manager                          \033[0;34m│\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[06]\033[0;36m SSL/TLS & Domain Manager                          \033[0;34m│\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[07]\033[0;36m Server & Security Manager                         \033[0;34m│\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[08]\033[0;36m Service & Port Manager                            \033[0;34m│\033[0m"
    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
    echo -e ""
    echo -e "\033[0;34m ┌─ \033[0;34mDIAGNOSTICS & TOOLS \033[0;34m───────────────────────────────────┐\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[09]\033[0;36m Monitoring & Tools                                \033[0;34m│\033[0m"
    echo -e "\033[0;34m │  \033[0;32m[10]\033[0;36m Advanced Settings                                 \033[0;34m│\033[0m"
    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
    echo -e ""
    echo -e "\033[0;31m ┌─────────────────────────────────────────────────────────┐\033[0m"
    echo -e "\033[0;31m │  \033[0;32m[00]\033[0;31m Exit Dashboard                                    \033[0;31m│\033[0m"
    echo -e "\033[0;31m └─────────────────────────────────────────────────────────┘\033[0m"
    echo -e ""
}
