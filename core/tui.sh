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

    # 2. Modern Status Indicators
    local X_STAT=$(systemctl is-active --quiet xray && echo -e "\033[1;32mON \033[0m" || echo -e "\033[1;31mOFF\033[0m")
    local S_STAT=$(systemctl is-active --quiet ssh && echo -e "\033[1;32mON \033[0m" || echo -e "\033[1;31mOFF\033[0m")
    local O_STAT=$(systemctl is-active --quiet openvpn@server-tcp && echo -e "\033[1;32mON \033[0m" || echo -e "\033[1;31mOFF\033[0m")
    local H_STAT=$(systemctl is-active --quiet hysteria-server && echo -e "\033[1;32mON \033[0m" || echo -e "\033[1;31mOFF\033[0m")

    # 3. Theme Colors & Layout Constants
    local C_CYAN="\033[1;36m"
    local C_GOLD="\033[1;33m"
    local C_WHITE="\033[1;37m"
    local C_RED="\033[1;31m"
    local C_RST="\033[0m"
    local LINE="${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
    local P="   " # Center Margin

    # 4. Premium Full-Width Header
    echo -e ""
    echo -e "${P}${LINE}"
    echo -e "${P}${C_GOLD}         🌟 TECHFEEDS MASTER VPN PRO V3.5 🌟${C_RST}"
    echo -e "${P}${C_WHITE}         ⚡ Fast • Secure • Stable • Unlimited${C_RST}"
    echo -e "${P}${LINE}"
    echo -e ""
    
    # 5. Telemetry Section
    echo -e "${P}${C_CYAN}               [ ${C_WHITE}✦ SYSTEM TELEMETRY ✦ ${C_CYAN}]${C_RST}"
    echo -e "${P}${LINE}"
    echo -e "${P}  ${C_GOLD}OS      :${C_WHITE} ${OS_INFO}"
    echo -e "${P}  ${C_GOLD}Domain  :${C_WHITE} ${HOSTNAME}"
    echo -e "${P}  ${C_GOLD}Time    :${C_WHITE} ${DATE}"
    echo -e "${P}  ${C_GOLD}Uptime  :${C_WHITE} ${UPTIME}"
    echo -e "${P}  ${C_GOLD}Users   :${C_WHITE} ${SSH_USERS} SSH | ${XRAY_USERS} XRAY"
    echo -e "${P}  ${C_GOLD}IP Addr :${C_WHITE} ${IP}"
    echo -e "${P}  ${C_GOLD}Status  :${C_WHITE} XRAY[${X_STAT}${C_WHITE}] SSH[${S_STAT}${C_WHITE}] OVPN[${O_STAT}${C_WHITE}] HY2[${H_STAT}${C_WHITE}]"
    echo -e "${P}${LINE}"
    echo -e ""

    # 6. Command Center Menu (ANSI locked right-column positioning \033[30G)
    echo -e "${P}${C_CYAN}                 [ ${C_WHITE}✦ COMMAND CENTER ✦ ${C_CYAN}]${C_RST}"
    echo -e ""
    
    echo -e "${P} ${C_CYAN}[${C_GOLD}01${C_CYAN}]${C_RST} 🚀 ${C_WHITE}SSH & UDP\033[30G${C_CYAN}[${C_GOLD}08${C_CYAN}]${C_RST} 🛰️ ${C_WHITE}TRANSPORT"
    echo -e "${P} ${C_CYAN}[${C_GOLD}02${C_CYAN}]${C_RST} 🌍 ${C_WHITE}OPENVPN\033[30G${C_CYAN}[${C_GOLD}09${C_CYAN}]${C_RST} 🔐 ${C_WHITE}SSL/DOMAIN"
    echo -e "${P} ${C_CYAN}[${C_GOLD}03${C_CYAN}]${C_RST} ⚡ ${C_WHITE}XRAY VLESS\033[30G${C_CYAN}[${C_GOLD}10${C_CYAN}]${C_RST} 🛑 ${C_WHITE}SECURITY"
    echo -e "${P} ${C_CYAN}[${C_GOLD}04${C_CYAN}]${C_RST} 🛸 ${C_WHITE}XRAY VMESS\033[30G${C_CYAN}[${C_GOLD}11${C_CYAN}]${C_RST} ⚙️ ${C_WHITE}SERVICES"
    echo -e "${P} ${C_CYAN}[${C_GOLD}05${C_CYAN}]${C_RST} 🐎 ${C_WHITE}XRAY TROJAN\033[30G${C_CYAN}[${C_GOLD}12${C_CYAN}]${C_RST} 📈 ${C_WHITE}MONITORING"
    echo -e "${P} ${C_CYAN}[${C_GOLD}06${C_CYAN}]${C_RST} 🌑 ${C_WHITE}SHADOWSOCKS\033[30G${C_CYAN}[${C_GOLD}13${C_CYAN}]${C_RST} 🛠️ ${C_WHITE}ADVANCED"
    echo -e "${P} ${C_CYAN}[${C_GOLD}07${C_CYAN}]${C_RST} 🌪️ ${C_WHITE}HYSTERIA V2\033[30G${C_CYAN}[${C_GOLD}14${C_CYAN}]${C_RST} 🔌 ${C_WHITE}PORTS"

    # 7. Clean Red Exit Line
    echo -e ""
    echo -e "${P}${LINE}"
    echo -e "${P} ${C_RED}[00] ❌ EXIT DASHBOARD${C_RST}"
    echo -e "${P}${LINE}"
    echo -e ""
}
