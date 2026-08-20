draw_dashboard() {
    clear
    
    # 1. Fetch System Information
    local HOSTNAME=$(cat /etc/techfeeds/domain 2>/dev/null || hostname)
    local IP=$(curl -s4 ifconfig.me 2>/dev/null || echo "Unknown")
    local UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' | sed 's/ days/d/' | sed 's/ day/d/' | sed 's/ hours/h/' | sed 's/ hour/h/' | sed 's/ minutes/m/' | sed 's/ minute/m/' || echo "Unknown")
    local DATE=$(date +"%Y-%m-%d %H:%M:%S")
    local OS_INFO=$(cat /etc/os-release 2>/dev/null | grep "^PRETTY_NAME" | cut -d= -f2 | tr -d '"')
    [ -z "$OS_INFO" ] && OS_INFO="Linux"
    
    local SSH_USERS=$(awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd | wc -l)
    local XRAY_USERS=0
    [ -f "/usr/local/etc/xray/config.json" ] && XRAY_USERS=$(jq -r '.inbounds[].settings.clients[]? | select(.email != null) | .email' /usr/local/etc/xray/config.json 2>/dev/null | sort -u | wc -l)

    # Status Indicators
    local X_STAT=$(systemctl is-active --quiet xray && echo -e "\033[1;32mOK\033[0m" || echo -e "\033[1;31mFAIL\033[0m")
    local S_STAT=$(systemctl is-active --quiet ssh && echo -e "\033[1;32mOK\033[0m" || echo -e "\033[1;31mFAIL\033[0m")
    local O_STAT=$(systemctl is-active --quiet openvpn@server-tcp && echo -e "\033[1;32mOK\033[0m" || echo -e "\033[1;31mFAIL\033[0m")
    local H_STAT=$(systemctl is-active --quiet hysteria-server && echo -e "\033[1;32mOK\033[0m" || echo -e "\033[1;31mFAIL\033[0m")

    # Dynamic Padding for System Info (Exact 34-character interior alignment)
    local OS_VAL=$(printf "%-34.34s" "$OS_INFO")
    local DOMAIN_VAL=$(printf "%-34.34s" "$HOSTNAME")
    local TIME_VAL=$(printf "%-34.34s" "$DATE")
    local UPTIME_VAL=$(printf "%-34.34s" "$UPTIME")
    local USERS_VAL=$(printf "%-34.34s" "$SSH_USERS (SSH) | $XRAY_USERS (XRAY)")
    local IP_VAL=$(printf "%-34.34s" "$IP")

    # 2. Header Box
    echo -e ""
    echo -e "\033[1;35m ╭───────────────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;35m │         \033[1;36m★ \033[1;32mTECHFEEDS MASTER VPN PRO V3.5 \033[1;36m★         \033[1;35m│\033[0m"
    echo -e "\033[1;35m │         \033[1;37mFast • Secure • Stable • Unlimited        \033[1;35m│\033[0m"
    echo -e "\033[1;35m ╰───────────────────────────────────────────────────╯\033[0m"
    echo -e ""
    
    # 3. System Information Box
    echo -e "\033[1;36m               [ \033[1;35mSYSTEM INFORMATION \033[1;36m]\033[0m"
    echo -e "\033[1;36m ╭───────────────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;36m │\033[0m 🐧 \033[1;37mOS        : \033[1;36m${OS_VAL}\033[1;36m │\033[0m"
    echo -e "\033[1;36m │\033[0m 🌐 \033[1;37mDomain    : \033[1;36m${DOMAIN_VAL}\033[1;36m │\033[0m"
    echo -e "\033[1;36m │\033[0m 🕒 \033[1;37mTime      : \033[1;36m${TIME_VAL}\033[1;36m │\033[0m"
    echo -e "\033[1;36m │\033[0m ⚡ \033[1;37mUptime    : \033[1;36m${UPTIME_VAL}\033[1;36m │\033[0m"
    echo -e "\033[1;36m │\033[0m 👥 \033[1;37mUsers     : \033[1;36m${USERS_VAL}\033[1;36m │\033[0m"
    echo -e "\033[1;36m │\033[0m 🆔 \033[1;37mIP Address: \033[1;36m${IP_VAL}\033[1;36m │\033[0m"
    echo -e "\033[1;36m │\033[0m ⚙️  \033[1;37mServices  : \033[0mXR:${X_STAT} \033[0mSH:${S_STAT} \033[0mOV:${O_STAT} \033[0mHY:${H_STAT}   \033[1;36m│\033[0m"
    echo -e "\033[1;36m ╰───────────────────────────────────────────────────╯\033[0m"
    echo -e ""

    # 4. Main Menu - Separated Independent Buttons
    echo -e "\033[1;35m                    [ \033[1;36mMAIN MENU \033[1;35m]\033[0m"
    
    echo -e "\033[1;35m ╭────────────────────────╮ ╭────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[01]\033[1;37m SSH/UDP     \033[0m🛡️  \033[1;36m>\033[1;35m │ │ \033[1;32m[08]\033[1;37m Transport   \033[0m🛠️  \033[1;36m>\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────╯ ╰────────────────────────╯\033[0m"
    
    echo -e "\033[1;35m ╭────────────────────────╮ ╭────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[02]\033[1;37m OpenVPN     \033[0m🌐  \033[1;36m>\033[1;35m │ │ \033[1;32m[09]\033[1;37m SSL/Domain  \033[0m🔒  \033[1;36m>\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────╯ ╰────────────────────────╯\033[0m"
    
    echo -e "\033[1;35m ╭────────────────────────╮ ╭────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[03]\033[1;37m Xray VLESS  \033[0m✌️  \033[1;36m>\033[1;35m │ │ \033[1;32m[10]\033[1;37m Security    \033[0m🛡️  \033[1;36m>\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────╯ ╰────────────────────────╯\033[0m"
    
    echo -e "\033[1;35m ╭────────────────────────╮ ╭────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[04]\033[1;37m Xray VMESS  \033[0m🛸  \033[1;36m>\033[1;35m │ │ \033[1;32m[11]\033[1;37m Service/Pt  \033[0m⚙️  \033[1;36m>\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────╯ ╰────────────────────────╯\033[0m"
    
    echo -e "\033[1;35m ╭────────────────────────╮ ╭────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[05]\033[1;37m Xray Troj   \033[0m🐴  \033[1;36m>\033[1;35m │ │ \033[1;32m[12]\033[1;37m Monitoring  \033[0m📊  \033[1;36m>\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────╯ ╰────────────────────────╯\033[0m"
    
    echo -e "\033[1;35m ╭────────────────────────╮ ╭────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[06]\033[1;37m Shadowsks   \033[0m🚀  \033[1;36m>\033[1;35m │ │ \033[1;32m[13]\033[1;37m Advanced    \033[0m🎛️  \033[1;36m>\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────╯ ╰────────────────────────╯\033[0m"
    
    echo -e "\033[1;35m ╭────────────────────────╮ ╭────────────────────────╮\033[0m"
    echo -e "\033[1;35m │ \033[1;32m[07]\033[1;37m Hysteria 2  \033[0m⚡  \033[1;36m>\033[1;35m │ │ \033[1;32m[14]\033[1;37m Chg Ports   \033[0m🔌  \033[1;36m>\033[1;35m │\033[0m"
    echo -e "\033[1;35m ╰────────────────────────╯ ╰────────────────────────╯\033[0m"
    
    # Exit Button Box
    echo -e "\033[1;31m ╭───────────────────────────────────────────────────╮\033[0m"
    echo -e "\033[1;31m │ \033[1;31m[00]\033[1;37m EXIT DASHBOARD                             \033[0m🚪 \033[1;31m>\033[1;31m│\033[0m"
    echo -e "\033[1;31m ╰───────────────────────────────────────────────────╯\033[0m"
    echo -e ""
}
