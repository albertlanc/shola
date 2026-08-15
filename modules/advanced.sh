advanced_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ ADVANCED SETTINGS ──────────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Backup Techfeeds VPN Pro Configurations               \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Restore Configuration Backup                          \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Update Package Repositories                         \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m Uninstall Techfeeds VPN Pro                         \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[5]\033[0;36m Change Protocol Ports (Port-Change)                 \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-5]: \033[0m"
        read -r adv_opt

        case $adv_opt in
            1)
                clear
                echo -e "\033[0;36m┌─ SYSTEM BACKUP ──────────────────────────────────────────\033[0m"
                DATE=$(date +"%Y%m%d_%H%M%S")
                mkdir -p /opt/techfeeds-vpn-pro/backups
                BACKUP_FILE="/opt/techfeeds-vpn-pro/backups/vpn_backup_$DATE.tar.gz"
                echo "│  Creating backup..."
                tar -czf "$BACKUP_FILE" /usr/local/etc/xray /etc/ssh /opt/techfeeds-vpn-pro/users 2>/dev/null
                echo -e "│  \033[0;32mBackup saved to: $BACKUP_FILE\033[0m"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ RESTORE BACKUP ─────────────────────────────────────────\033[0m"
                echo "│  Available backups in /opt/techfeeds-vpn-pro/backups/:"
                echo -e "└──────────────────────────────────────────────────────────\033[0m"
                ls -lh /opt/techfeeds-vpn-pro/backups/ 2>/dev/null
                echo -ne "\n"
                read -p "Enter full backup filename to restore: " b_file
                if [ -f "/opt/techfeeds-vpn-pro/backups/$b_file" ]; then
                    tar -xzf "/opt/techfeeds-vpn-pro/backups/$b_file" -C /
                    echo -e "\033[0;32mRestore complete! Restarting services...\033[0m"
                    systemctl restart ssh xray
                else
                    echo -e "\033[0;31mBackup not found.\033[0m"
                fi
                read -p "Press Enter to return..."
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ UPDATE REPOSITORIES ────────────────────────────────────\033[0m"
                apt-get update -y && apt-get upgrade -y
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            4)
                clear
                echo -e "\033[0;31m┌─ DANGER: UNINSTALL ──────────────────────────────────────\033[0m"
                read -p "│  Type 'YES' to completely uninstall Techfeeds VPN Pro: " confirm
                echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
                if [ "$confirm" == "YES" ]; then
                    echo "Stopping services and removing directories..."
                    systemctl stop xray dnstt-server 2>/dev/null
                    rm -rf /opt/techfeeds-vpn-pro
                    rm -f /usr/local/bin/techfeeds-vpn-pro
                    echo -e "\033[0;32mUninstallation complete. Exiting...\033[0m"
                    exit 0
                fi
                ;;
            5) port_change_menu ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
