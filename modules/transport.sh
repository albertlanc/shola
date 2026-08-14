transport_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mXray & Transport Manager\033[0m"
        echo "================================================================"
        echo "1. Check Xray Status"
        echo "2. View Xray Logs"
        echo "3. Restart Xray Core"
        echo "4. Validate Xray Configuration Syntax"
        echo "5. SlowDNS (DNSTT) Manager"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-5]: "
        read -r t_opt

        case $t_opt in
            1) systemctl is-active --quiet xray && echo -e "\033[0;32m● Xray is ONLINE\033[0m" || echo -e "\033[0;31m● Xray is OFFLINE\033[0m" ; read -p "Press Enter..." ;;
            2) journalctl -u xray -n 50 --no-pager ; read -p "Press Enter..." ;;
            3) systemctl restart xray && echo "Xray restarted successfully." ; read -p "Press Enter..." ;;
            4) /usr/local/bin/xray -test -config /usr/local/etc/xray/config.json ; read -p "Press Enter..." ;;
            5) dns_menu ;; # Calls the SlowDNS menu
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
