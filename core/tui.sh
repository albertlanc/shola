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

    local SSH_RAW=$(systemctl is-active --quiet ssh && echo "OK" || echo "FAIL")
    local XRAY_RAW=$(systemctl is-active --quiet xray && echo "OK" || echo "FAIL")
    local OVPN_RAW=$(systemctl is-active --quiet openvpn@server-tcp && echo "OK" || echo "FAIL")
    local HY2_RAW=$(systemctl is-active --quiet hysteria-server && echo "OK" || echo "FAIL")

    # 2. Perfect Padding Strings (Ensures borders never break)
    local OS_VAL=$(printf "%-40s" "${OS_INFO:0:40}")
    local DOMAIN_VAL=$(printf "%-40s" "${HOSTNAME:0:40}")
    local TIME_VAL=$(printf "%-40s" "${DATE:0:40}")
    local UPTIME_VAL=$(printf "%-40s" "${UPTIME:0:40}")
    local USERS_VAL=$(printf "%-40s" "${SSH_USERS} (SSH)  |  ${XRAY_USERS} (XRAY)")
    local IP_VAL=$(printf "%-40s" "${IP:0:40}")
    local SVC_VAL=$(printf "%-40s" "XR:${XRAY_RAW}  SSH:${SSH_RAW}  OVPN:${OVPN_RAW}  HY2:${HY2_RAW}")

    # 3. Draw Premium Header
    echo -e ""
    echo -e "\033[1;35m •────────────────────────────────────────────────────────────────────•\033[0m"
    echo -e "\033[1;35m │                 \033[1;36m★ \033[1;32mTECHFEEDS MASTER VPN PRO V3.5 \033[1;36m★                \033[1;35m│\033[0m"
    echo -e "\033[1;35m │                  \033[1;37mFast • Secure • Stable • Unlimited                \033[1;35m│\033[0m"
    echo -e "\033[1;35m •────────────────────────────────────────────────────────────────────•\033[0m"
    echo -e ""
    
    # 4. Draw System Information Box
    echo -e "\033[1;36m                       [ \033[1;35mSYSTEM INFORMATION \033[1;36m]\033[0m"
    echo -e "\033[1;32m ╭────────────────────────────────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;32m │  \033[1;37m🐧 OS            : \033[1;37m${OS_VAL}\033[1;32m│\033[0m"
    echo -e "\033[1;32m │  \033[1;37m🌐 Domain        : \033[1;37m${DOMAIN_VAL}\033[1;32m│\033[0m"
    echo -e "\033[1;32m │  \033[1;37m🕒 Time          : \033[1;37m${TIME_VAL}\033[1;32m│\033[0m"
    echo -e "\033[1;32m │  \033[1;37m⚡ Uptime        : \033[1;37m${UPTIME_VAL}\033[1;32m│\033[0m"
    echo -e "\033[1;32m │  \033[1;37m👥 Online Users  : \033[1;37m${USERS_VAL}\033[1;32m│\033[0m"
    echo -e "\033[1;32m │  \033[1;37m🆔 IP Address    : \033[1;37m${IP_VAL}\033[1;32m│\033[0m"
    echo -e "\033[1;32m │  \033[1;37m⚙️  Services      : \033[1;36m${SVC_VAL}\033[1;32m│\033[0m"
    echo -e "\033[1;32m ╰────────────────────────────────────────────────────────────────────╯\033[0m"
    echo -e ""

    # 5. Draw 2-Column Main Menu Box
    echo -e "\033[1;35m                           [ \033[1;36mMAIN MENU \033[1;35m]\033[0m"
    echo -e "\033[1;35m ╭─────────────────────────────────┬──────────────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[01] \033[1;37mSSH & UDP Custom     \033[1;34m🛡️ \033[1;37m>\033[1;35m │ \033[1;32m[08] \033[1;37mXray & Transport Mgt \033[1;36m🛠️ \033[1;37m>\033[1;35m  │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[02] \033[1;37mOpenVPN Manager      \033[1;34m🌐 \033[1;37m>\033[1;35m │ \033[1;32m[09] \033[1;37mSSL/TLS & Domain Mgt \033[1;36m🔒 \033[1;37m>\033[1;35m  │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[03] \033[1;37mXray VLESS Manager   \033[1;34m✌️ \033[1;37m>\033[1;35m │ \033[1;32m[10] \033[1;37mServer & Security    \033[1;36m🛡️ \033[1;37m>\033[1;35m  │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[04] \033[1;37mXray VMESS Manager   \033[1;34m🛸 \033[1;37m>\033[1;35m │ \033[1;32m[11] \033[1;37mService & Port Mgt   \033[1;36m⚙️ \033[1;37m>\033[1;35m  │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[05] \033[1;37mXray Trojan Manager  \033[1;34m🐴 \033[1;37m>\033[1;35m │ \033[1;32m[12] \033[1;37mMonitoring & Tools   \033[1;36m📊 \033[1;37m>\033[1;35m  │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[06] \033[1;37mShadowsocks Manager  \033[1;34m🚀 \033[1;37m>\033[1;35m │ \033[1;32m[13] \033[1;37mAdvanced Settings    \033[1;36m🎛️ \033[1;37m>\033[1;35m  │\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[07] \033[1;37mHysteria V2 Manager  \033[1;34m⚡ \033[1;37m>\033[1;35m │ \033[1;32m[14] \033[1;37mChange Server Ports  \033[1;36m🔌 \033[1;37m>\033[1;35m  │\033[0m"
    echo -e "\033[1;35m ├─────────────────────────────────┴──────────────────────────────────┤\033[0m"
    echo -e "\033[1;35m │ \033[1;31m[00] \033[1;37mExit Dashboard                                           \033[1;31m🚪 >\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────────────────────────────────────────────────╯\033[0m"
    echo -e ""
    echo -e "\033[1;36m ╭────────────────────────────────────────────────────────────────────╮\033[0m"
}
