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
                echo "│  Configuring UFW to allow VPN ports...[span_40](start_span)"[span_40](end_span)
                ufw allow 22/tcp[span_41](start_span)[span_41](end_span)
                ufw allow 80/tcp[span_42](start_span)[span_42](end_span)
                ufw allow 443/tcp[span_43](start_span)[span_43](end_span)
                ufw allow 8080/tcp[span_44](start_span)[span_44](end_span)
                ufw allow 53/udp[span_45](start_span)[span_45](end_span)
                echo "y" | ufw enable[span_46](start_span)[span_46](end_span)
                echo -e "│  \033[0;32mUFW enabled safely.\033[0m[span_47](start_span)"[span_47](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_48](start_span)"[span_48](end_span)
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ DISABLE UFW FIREWALL ───────────────────────────────────\033[0m"
                ufw disable[span_49](start_span)[span_49](end_span)
                echo -e "│  \033[1;33mUFW disabled.\033[0m[span_50](start_span)"[span_50](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_51](start_span)"[span_51](end_span)
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ INSTALL FAIL2BAN ───────────────────────────────────────\033[0m"
                apt-get install fail2ban -y[span_52](start_span)[span_52](end_span)
                systemctl enable fail2ban[span_53](start_span)[span_53](end_span)
                systemctl start fail2ban[span_54](start_span)[span_54](end_span)
                echo -e "│  \033[0;32mFail2ban installed and started to protect SSH.\033[0m[span_55](start_span)"[span_55](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_56](start_span)"[span_56](end_span)
                ;;
            4)
                clear
                echo -e "\033[0;36m┌─ UFW STATUS ─────────────────────────────────────────────\033[0m"
                ufw status verbose[span_57](start_span)[span_57](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_58](start_span)"[span_58](end_span)
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;[span_59](start_span)[span_59](end_span)
        esac
    done
}
