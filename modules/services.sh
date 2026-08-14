service_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mService & Port Manager\033[0m"
        echo "================================================================"
        echo "1. List All Listening Ports (ss)"
        echo "2. Restart Core Services (SSH, Xray, DNSTT)"
        echo "3. Stop a Service"
        echo "4. View Service Logs (journalctl)"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-4]: "
        read -r srv_opt

        case $srv_opt in
            1)
                ss -tulpen
                read -p "Press Enter..."
                ;;
            2)
                echo "Restarting services..."
                systemctl restart ssh xray dnstt-server 2>/dev/null
                echo -e "\033[0;32m● Services restarted.\033[0m"
                read -p "Press Enter..."
                ;;
            3)
                read -p "Enter service name to stop (e.g., xray): " svc_name
                systemctl stop "$svc_name"
                echo "$svc_name stopped."
                read -p "Press Enter..."
                ;;
            4)
                read -p "Enter service name to view logs (e.g., dnstt-server): " svc_name
                journalctl -u "$svc_name" -n 50 --no-pager
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
