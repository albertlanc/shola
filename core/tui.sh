draw_dashboard() {
    clear
    
    # 1. Fetch System Data
    local HOSTNAME=$(cat /etc/techfeeds/domain 2>/dev/null || hostname)
    local IP=$(curl -s4 ifconfig.me 2>/dev/null || echo "Unknown")
    local UPTIME=$(uptime -p | sed 's/up //')
    local DATE=$(date +"%Y-%m-%d %H:%M:%S")
    local OS_INFO=$(cat /etc/os-release | grep "^PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    
    local SSH_USERS=$(awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd | wc -l)
    local XRAY_USERS=0
    [ -f "/usr/local/etc/xray/config.json" ] && XRAY_USERS=$(jq -r '.inbounds[].settings.clients[]? | select(.email != null) | .email' /usr/local/etc/xray/config.json 2>/dev/null | sort -u | wc -l)

    # Status coloring
    local SSH_RAW=$(systemctl is-active --quiet ssh && echo -e "\033[0;32mOK\033[0m" || echo -e "\033[0;31mFAIL\033[0m")
    local XRAY_RAW=$(systemctl is-active --quiet xray && echo -e "\033[0;32mOK\033[0m" || echo -e "\033[0;31mFAIL\033[0m")
    local OVPN_RAW=$(systemctl is-active --quiet openvpn@server-tcp && echo -e "\033[0;32mOK\033[0m" || echo -e "\033[0;31mFAIL\033[0m")
    local HY2_RAW=$(systemctl is-active --quiet hysteria-server && echo -e "\033[0;32mOK\033[0m" || echo -e "\033[0;31mFAIL\033[0m")
    
    # Raw uncolored string for exact character count calculation
    local RAW_SVC="  Services      : XR:OK SSH:OK OVPN:OK HY2:OK"

    # 2. Dynamic Padding Strings (Ensures right border never breaks)
    local L_OS="  OS            : ${OS_INFO:0:36}"
    local L_DOMAIN="  Domain        : ${HOSTNAME:0:36}"
    local L_TIME="  Time          : $DATE"
    local L_UP="  Uptime        : $UPTIME"
    local L_ONL="  Online Users  : $SSH_USERS (SSH)  |  $XRAY_USERS (XRAY)"
    local L_IP="  IP Address    : $IP"
    local L_SVC="$RAW_SVC"

    # 55 is the exact inner width of the box
    local PAD_OS=$(( 55 - ${#L_OS} ))
    local PAD_DOMAIN=$(( 55 - ${#L_DOMAIN} ))
    local PAD_TIME=$(( 55 - ${#L_TIME} ))
    local PAD_UP=$(( 55 - ${#L_UP} ))
    local PAD_ONL=$(( 55 - ${#L_ONL} ))
    local PAD_IP=$(( 55 - ${#L_IP} ))
    local PAD_SVC=$(( 55 - ${#L_SVC} ))

    # Failsafe if string exceeds max length
    [ $PAD_OS -lt 0 ] && PAD_OS=0
    [ $PAD_DOMAIN -lt 0 ] && PAD_DOMAIN=0
    [ $PAD_TIME -lt 0 ] && PAD_TIME=0
    [ $PAD_UP -lt 0 ] && PAD_UP=0
    [ $PAD_ONL -lt 0 ] && PAD_ONL=0
    [ $PAD_IP -lt 0 ] && PAD_IP=0
    [ $PAD_SVC -lt 0 ] && PAD_SVC=0

    # 3. Draw Premium Header (57 Chars Width)
    echo -e ""
    echo -e "\033[1;35m ╭───────────────────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;35m │          \033[1;36m★ \033[1;32mTECHFEEDS MASTER VPN PRO V3.5 \033[1;36m★          \033[1;35m│\033[0m"
    echo -e "\033[1;35m │          \033[1;37mFast • Secure • Stable • Unlimited           \033[1;35m│\033[0m"
    echo -e "\033[1;35m ╰───────────────────────────────────────────────────────╯\033[0m"
    echo -e ""
    
    # 4. Draw System Information Box
    echo -e "\033[1;36m                  [ \033[1;35mSYSTEM INFORMATION \033[1;36m]\033[0m"
    echo -e "\033[1;36m ╭───────────────────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;36m │\033[1;37m  OS            : \033[1;37m${OS_INFO:0:36}\033[0m$(printf "%${PAD_OS}s" "")\033[1;36m│\033[0m"
    echo -e "\033[1;36m │\033[1;37m  Domain        : \033[1;37m${HOSTNAME:0:36}\033[0m$(printf "%${PAD_DOMAIN}s" "")\033[1;36m│\033[0m"
    echo -e "\033[1;36m │\033[1;37m  Time          : \033[1;37m${DATE}\033[0m$(printf "%${PAD_TIME}s" "")\033[1;36m│\033[0m"
    echo -e "\033[1;36m │\033[1;37m  Uptime        : \033[1;37m${UPTIME}\033[0m$(printf "%${PAD_UP}s" "")\033[1;36m│\033[0m"
    echo -e "\033[1;36m │\033[1;37m  Online Users  : \033[1;37m${SSH_USERS} (SSH)  |  ${XRAY_USERS} (XRAY)\033[0m$(printf "%${PAD_ONL}s" "")\033[1;36m│\033[0m"
    echo -e "\033[1;36m │\033[1;37m  IP Address    : \033[1;37m${IP}\033[0m$(printf "%${PAD_IP}s" "")\033[1;36m│\033[0m"
    echo -e "\033[1;36m │\033[1;37m  Services      : \033[1;36mXR:${XRAY_RAW}\033[1;36m SSH:${SSH_RAW}\033[1;36m OVPN:${OVPN_RAW}\033[1;36m HY2:${HY2_RAW}\033[0m$(printf "%${PAD_SVC}s" "")\033[1;36m│\033[0m"
    echo -e "\033[1;36m ╰───────────────────────────────────────────────────────╯\033[0m"
    echo -e ""

    # 5. Draw Perfectly Measured 2-Column Main Menu Box
    echo -e "\033[1;35m                      [ \033[1;36mMAIN MENU \033[1;35m]\033[0m"
    echo -e "\033[1;35m ╭──────────────────────────┬────────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[01]\033[1;37m SSH & UDP Custom  \033[1;35m│ \033[1;32m[08]\033[1;37m Xray & Transport Mgt\033[1;35m │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[02]\033[1;37m OpenVPN Manager   \033[1;35m│ \033[1;32m[09]\033[1;37m SSL/TLS & Domain Mgt\033[1;35m │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[03]\033[1;37m Xray VLESS Mgt    \033[1;35m│ \033[1;32m[10]\033[1;37m Server & Security   \033[1;35m │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[04]\033[1;37m Xray VMESS Mgt    \033[1;35m│ \033[1;32m[11]\033[1;37m Service & Port Mgt  \033[1;35m │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[05]\033[1;37m Xray Trojan Mgt   \033[1;35m│ \033[1;32m[12]\033[1;37m Monitoring & Tools  \033[1;35m │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[06]\033[1;37m Shadowsocks Mgt   \033[1;35m│ \033[1;32m[13]\033[1;37m Advanced Settings   \033[1;35m │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[07]\033[1;37m Hysteria V2 Mgt   \033[1;35m│ \033[1;32m[14]\033[1;37m Change Server Ports \033[1;35m │\033[0m"
    echo -e "\033[1;35m ├──────────────────────────┴────────────────────────────┤\033[0m"
    echo -e "\033[1;35m │ \033[1;31m[00]\033[1;37m Exit Dashboard                                   \033[1;35m│\033[0m"
    echo -e "\033[1;35m ╰───────────────────────────────────────────────────────╯\033[0m"
    echo -e ""
}
