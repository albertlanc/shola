dns_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mSlowDNS (DNSTT) Manager\033[0m"
        echo "================================================================"
        echo "1. Install & Configure DNSTT Server"
        echo "2. Start/Restart DNSTT"
        echo "3. View DNSTT Logs"
        echo "0. Back to Transport Manager"
        echo -ne "\nSelect option [0-3]: "
        read -r dns_opt

        case $dns_opt in
            1)
                echo "Checking Port 53 UDP for conflicts..."
                if ss -uln | grep -q ":53 "; then
                    echo "Warning: Port 53 is in use (likely by systemd-resolved)."
                    echo "You must disable systemd-resolved stub listener first."
                else
                    echo "Downloading DNSTT Server..."
                    wget -qO /usr/local/bin/dnstt-server https://github.com/Techfeeds/dnstt/releases/latest/download/dnstt-server
                    chmod +x /usr/local/bin/dnstt-server
                    echo "DNSTT Server installed."
                fi
                read -p "Press Enter..."
                ;;
            2)
                systemctl restart dnstt-server || echo "Systemd service not configured yet."
                read -p "Press Enter..."
                ;;
            3)
                journalctl -u dnstt-server -n 20 --no-pager
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
