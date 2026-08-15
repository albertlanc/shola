security_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ SERVER & SECURITY MANAGER ──────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Enable UFW Firewall (Safe Mode)                       \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Disable UFW Firewall                                  \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Install & Start Fail2Ban                              \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m View UFW Status                                       \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-4]: \033[0m"
        read -r sec_opt

        case $sec_opt in
            1)
                clear
                echo -e "\033[0;36m┌─ ENABLE UFW FIREWALL ────────────────────────────────────\033[0m"
                echo "│  Configuring UFW to allow VPN ports..."
                ufw allow 22/tcp
                ufw allow 80/tcp
                ufw allow 443/tcp
                ufw allow 8080/tcp
                ufw allow 53/udp
                echo "y" | ufw enable
                echo -e "│  \033[0;32mUFW enabled safely.\033[0m"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ DISABLE UFW FIREWALL ───────────────────────────────────\033[0m"
                ufw disable
                echo -e "│  \033[1;33mUFW disabled.\033[0m"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ INSTALL FAIL2BAN ───────────────────────────────────────\033[0m"
                apt-get install fail2ban -y
                systemctl enable fail2ban
                systemctl start fail2ban
                echo -e "│  \033[0;32mFail2ban installed and started to protect SSH.\033[0m"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            4)
                clear
                echo -e "\033[0;36m┌─ UFW STATUS ─────────────────────────────────────────────\033[0m"
                ufw status verbose
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
