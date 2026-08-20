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

    # 2. Fixed-Width Status Indicators (Forces alignment)
    local X_STAT=$(systemctl is-active --quiet xray && echo -e "\033[1;32mOK\033[0m  " || echo -e "\033[1;31mFAIL\033[0m")
    local S_STAT=$(systemctl is-active --quiet ssh && echo -e "\033[1;32mOK\033[0m  " || echo -e "\033[1;31mFAIL\033[0m")
    local O_STAT=$(systemctl is-active --quiet openvpn@server-tcp && echo -e "\033[1;32mOK\033[0m  " || echo -e "\033[1;31mFAIL\033[0m")
    local H_STAT=$(systemctl is-active --quiet hysteria-server && echo -e "\033[1;32mOK\033[0m  " || echo -e "\033[1;31mFAIL\033[0m")

    # 3. Strict 32-Character Padding
    local OS_VAL=$(printf "%-32.32s" "$OS_INFO")
    local DOMAIN_VAL=$(printf "%-32.32s" "$HOSTNAME")
    local TIME_VAL=$(printf "%-32.32s" "$DATE")
    local UPTIME_VAL=$(printf "%-32.32s" "$UPTIME")
    local USERS_VAL=$(printf "%-32.32s" "$SSH_USERS (SSH) | $XRAY_USERS (XRAY)")
    local IP_VAL=$(printf "%-32.32s" "$IP")

    # CENTER MARGIN (Pushes the whole UI to the middle of the screen)
    local P="   "

    # 4. Premium Header Box
    echo -e ""
    echo -e "${P}\033[1;35m╭───────────────────────────────────────────────────╮\033[0m"
    echo -e "${P}\033[1;35m│\033[1;36m         ★ \033[1;32mTECHFEEDS MASTER VPN PRO V3.5 \033[1;36m★         \033[1;35m│\033[0m"
    echo -e "${P}\033[1;35m│\033[1;37m         Fast • Secure • Stable • Unlimited        \033[1;35m│\033[0m"
    echo -e "${P}\033[1;35m╰───────────────────────────────────────────────────╯\033[0m"
    echo -e ""
    
    # 5. System Information Box
    echo -e "${P}\033[1;35m               [ \033[1;36mSYSTEM INFORMATION \033[1;35m]\033[0m"
    echo -e "${P}\033[1;32m╭───────────────────────────────────────────────────╮\033[0m"
    echo -e "${P}\033[1;32m│\033[0m 🐧 \033[1;37mOS         : \033[1;36m${OS_VAL}\033[1;32m│\033[0m"
    echo -e "${P}\033[1;32m│\033[0m 🌐 \033[1;37mDomain     : \033[1;36m${DOMAIN_VAL}\033[1;32m│\033[0m"
    echo -e "${P}\033[1;32m│\033[0m 🕒 \033[1;37mTime       : \033[1;36m${TIME_VAL}\033[1;32m│\033[0m"
    echo -e "${P}\033[1;32m│\033[0m ⚡ \033[1;37mUptime     : \033[1;36m${UPTIME_VAL}\033[1;32m│\033[0m"
    echo -e "${P}\033[1;32m│\033[0m 👥 \033[1;37mUsers      : \033[1;36m${USERS_VAL}\033[1;32m│\033[0m"
    echo -e "${P}\033[1;32m│\033[0m 🆔 \033[1;37mIP Address : \033[1;36m${IP_VAL}\033[1;32m│\033[0m"
    echo -e "${P}\033[1;32m│\033[0m ⚙️ \033[1;37m Services   : \033[0mXR:${X_STAT} \033[0mSH:${S_STAT} \033[0mOV:${O_STAT} \033[0mHY:${H_STAT} \033[1;32m│\033[0m"
    echo -e "${P}\033[1;32m╰───────────────────────────────────────────────────╯\033[0m"
    echo -e ""

    # 6. Main Menu Box (Hand-calibrated emoji spacing to prevent zigzag)
    echo -e "${P}\033[1;36m                    [ \033[1;35mMAIN MENU \033[1;36m]\033[0m"
    
    echo -e "${P}\033[1;34m╭───────────────────────╮ ╭───────────────────────╮\033[0m"
    echo -e "${P}\033[1;34m│ \033[1;32m[\033[1;37m01\033[1;32m] \033[1;37mSSH & UDP    \033[0m🛡️\033[1;37m>\033[1;34m│ │ \033[1;32m[\033[1;37m08\033[1;32m] \033[1;37mTRANSPORT    \033[0m🛠️\033[1;37m>\033[1;34m│\033[0m"
    echo -e "${P}\033[1;34m╰───────────────────────╯ ╰───────────────────────╯\033[0m"
    
    echo -e "${P}\033[1;34m╭───────────────────────╮ ╭───────────────────────╮\033[0m"
    echo -e "${P}\033[1;34m│ \033[1;32m[\033[1;37m02\033[1;32m] \033[1;37mOPENVPN       \033[0m🌐\033[1;37m>\033[1;34m│ │ \033[1;32m[\033[1;37m09\033[1;32m] \033[1;37mSSL & DOMAIN  \033[0m🔒\033[1;37m>\033[1;34m│\033[0m"
    echo -e "${P}\033[1;34m╰───────────────────────╯ ╰───────────────────────╯\033[0m"
    
    echo -e "${P}\033[1;34m╭───────────────────────╮ ╭───────────────────────╮\033[0m"
    echo -e "${P}\033[1;34m│ \033[1;32m[\033[1;37m03\033[1;32m] \033[1;37mXRAY VLESS   \033[0m✌️\033[1;37m>\033[1;34m│ │ \033[1;32m[\033[1;37m10\033[1;32m] \033[1;37mSECURITY     \033[0m🛡️\033[1;37m>\033[1;34m│\033[0m"
    echo -e "${P}\033[1;34m╰───────────────────────╯ ╰───────────────────────╯\033[0m"
    
    echo -e "${P}\033[1;34m╭───────────────────────╮ ╭───────────────────────╮\033[0m"
    echo -e "${P}\033[1;34m│ \033[1;32m[\033[1;37m04\033[1;32m] \033[1;37mXRAY VMESS    \033[0m🛸\033[1;37m>\033[1;34m│ │ \033[1;32m[\033[1;37m11\033[1;32m] \033[1;37mSERVICE & PRT\033[0m⚙️\033[1;37m>\033[1;34m│\033[0m"
    echo -e "${P}\033[1;34m╰───────────────────────╯ ╰───────────────────────╯\033[0m"
    
    echo -e "${P}\033[1;34m╭───────────────────────╮ ╭───────────────────────╮\033[0m"
    echo -e "${P}\033[1;34m│ \033[1;32m[\033[1;37m05\033[1;32m] \033[1;37mXRAY TROJAN   \033[0m🐴\033[1;37m>\033[1;34m│ │ \033[1;32m[\033[1;37m12\033[1;32m] \033[1;37mMONITORING    \033[0m📊\033[1;37m>\033[1;34m│\033[0m"
    echo -e "${P}\033[1;34m╰───────────────────────╯ ╰───────────────────────╯\033[0m"
    
    echo -e "${P}\033[1;34m╭───────────────────────╮ ╭───────────────────────╮\033[0m"
    echo -e "${P}\033[1;34m│ \033[1;32m[\033[1;37m06\033[1;32m] \033[1;37mSHADOWSOCKS   \033[0m🚀\033[1;37m>\033[1;34m│ │ \033[1;32m[\033[1;37m13\033[1;32m] \033[1;37mADVANCED     \033[0m🎛️\033[1;37m>\033[1;34m│\033[0m"
    echo -e "${P}\033[1;34m╰───────────────────────╯ ╰───────────────────────╯\033[0m"
    
    echo -e "${P}\033[1;34m╭───────────────────────╮ ╭───────────────────────╮\033[0m"
    echo -e "${P}\033[1;34m│ \033[1;32m[\033[1;37m07\033[1;32m] \033[1;37mHYSTERIA V2  \033[0m⚡\033[1;37m>\033[1;34m│ │ \033[1;32m[\033[1;37m14\033[1;32m] \033[1;37mCHANGE PORTS  \033[0m🔌\033[1;37m>\033[1;34m│\033[0m"
    echo -e "${P}\033[1;34m╰───────────────────────╯ ╰───────────────────────╯\033[0m"
    
    # 7. Red Exit Button (Added 1 space to tuck the door perfectly inside)
    echo -e "${P}\033[1;31m╭─────────────────────────────────────────────────╮\033[0m"
    echo -e "${P}\033[1;31m│ \033[1;32m[\033[1;31m00\033[1;32m] \033[1;37mEXIT DASHBOARD                          \033[0m🚪\033[1;37m>\033[1;31m│\033[0m"
    echo -e "${P}\033[1;31m╰─────────────────────────────────────────────────╯\033[0m"
    echo -e ""
}
