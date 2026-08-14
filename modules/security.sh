security_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mServer & Security Manager\033[0m"
        echo "================================================================"
        echo "1. Enable UFW Firewall (Safe Mode)"
        echo "2. Disable UFW Firewall"
        echo "3. Install & Start Fail2Ban"
        echo "4. View UFW Status"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-4]: "
        read -r sec_opt

        case $sec_opt in
            1)
                echo "Configuring UFW to allow VPN ports..."
                ufw allow 22/tcp
                ufw allow 80/tcp
                ufw allow 443/tcp
                ufw allow 8080/tcp
                ufw allow 53/udp
                echo "y" | ufw enable
                echo "UFW enabled safely."
                read -p "Press Enter..."
                ;;
            2)
                ufw disable
                echo "UFW disabled."
                read -p "Press Enter..."
                ;;
            3)
                apt-get install fail2ban -y
                systemctl enable fail2ban
                systemctl start fail2ban
                echo "Fail2ban installed and started to protect SSH."
                read -p "Press Enter..."
                ;;
            4)
                ufw status verbose
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
