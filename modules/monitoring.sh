monitoring_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ MONITORING & TOOLS ─────────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Full System Diagnostic                                \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Network Traffic & Active Connections                 \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Check Service Health                                  \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-3]: \033[0m"
        read -r mon_opt

        case $mon_opt in
            1)
                clear
                echo -e "\033[0;36m┌─ SYSTEM DIAGNOSTICS ─────────────────────────────────────\033[0m"
                echo "│  Running System Diagnostics..."
                echo "│  - IP Route: $(ip route get 8.8.8.8 | awk '{print $7}')"
                echo "│  - DNS Res: $(nslookup google.com >/dev/null 2>&1 && echo 'OK' || echo 'FAIL')"
                echo "│  - Disk Space: $(df -h / | awk '$NF=="/"{printf "%s", $5}')"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ NETWORK TRAFFIC & CONNECTIONS ──────────────────────────\033[0m"
                ss -tulpen
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ SERVICE HEALTH CHECK ───────────────────────────────────\033[0m"
                echo "│  Checking core services..."
                for svc in ssh xray dropbear fail2ban dnstt-server; do
                    if systemctl is-active --quiet $svc; then
                        echo -e "│  $svc: \033[0;32m● ONLINE\033[0m"
                    else
                        echo -e "│  $svc: \033[0;31m● OFFLINE\033[0m"
                    fi
                done
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
