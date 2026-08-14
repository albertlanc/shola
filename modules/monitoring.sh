monitoring_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mMonitoring & Tools\033[0m"
        echo "================================================================"
        echo "1. Full System Diagnostic"
        echo "2. Network Traffic & Active Connections"
        echo "3. Check Service Health"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-3]: "
        read -r mon_opt

        case $mon_opt in
            1)
                echo "Running System Diagnostics..."
                echo "- IP Route: $(ip route get 8.8.8.8 | awk '{print $7}')"
                echo "- DNS Res: $(nslookup google.com >/dev/null 2>&1 && echo 'OK' || echo 'FAIL')"
                echo "- Disk Space: $(df -h / | awk '$NF=="/"{printf "%s", $5}')"
                read -p "Press Enter..."
                ;;
            2)
                ss -tulpen
                read -p "Press Enter..."
                ;;
            3)
                echo "Checking core services..."
                for svc in ssh xray dropbear fail2ban dnstt-server; do
                    if systemctl is-active --quiet $svc; then
                        echo -e "$svc: \033[0;32m● ONLINE\033[0m"
                    else
                        echo -e "$svc: \033[0;31m● OFFLINE\033[0m"
                    fi
                done
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
