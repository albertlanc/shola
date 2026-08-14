advanced_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mAdvanced Settings\033[0m"
        echo "================================================================"
        echo "1. Backup Techfeeds VPN Pro Configurations"
        echo "2. Restore Configuration Backup"
        echo "3. Update Package Repositories"
        echo "4. Uninstall Techfeeds VPN Pro"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-4]: "
        read -r adv_opt

        case $adv_opt in
            1)
                DATE=$(date +"%Y%m%d_%H%M%S")
                BACKUP_FILE="/opt/techfeeds-vpn-pro/backups/vpn_backup_$DATE.tar.gz"
                echo "Creating backup..."
                tar -czf "$BACKUP_FILE" /usr/local/etc/xray /etc/ssh /opt/techfeeds-vpn-pro/users 2>/dev/null
                echo -e "\033[0;32m● Backup saved to: $BACKUP_FILE\033[0m"
                read -p "Press Enter..."
                ;;
            2)
                echo "Available backups in /opt/techfeeds-vpn-pro/backups/:"
                ls -lh /opt/techfeeds-vpn-pro/backups/
                read -p "Enter full backup filename to restore: " b_file
                if [ -f "/opt/techfeeds-vpn-pro/backups/$b_file" ]; then
                    tar -xzf "/opt/techfeeds-vpn-pro/backups/$b_file" -C /
                    echo "Restore complete! Restarting services..."
                    systemctl restart ssh xray
                else
                    echo "Backup not found."
                fi
                read -p "Press Enter..."
                ;;
            3)
                apt-get update -y
                read -p "Press Enter..."
                ;;
            4)
                read -p "DANGER: Type 'YES' to completely uninstall Techfeeds VPN Pro: " confirm
                if [ "$confirm" == "YES" ]; then
                    echo "Stopping services and removing directories..."
                    systemctl stop xray dnstt-server 2>/dev/null
                    rm -rf /opt/techfeeds-vpn-pro
                    rm -f /usr/local/bin/techfeeds-vpn-pro
                    echo "Uninstallation complete. Exiting..."
                    exit 0
                fi
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
