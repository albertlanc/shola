ssh_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mSSH Manager\033[0m"
        echo "================================================================"
        echo "1. Create SSH User"
        echo "2. Delete SSH User"
        echo "3. Renew/Extend User"
        echo "4. List SSH Users"
        echo "5. User Information"
        echo "6. Online SSH Users"
        echo "7. SSH Service Management"
        echo "8. SSH Configuration Backup"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-8]: "
        read -r ssh_opt

        case $ssh_opt in
            1)
                read -p "Username: " user
                read -p "Password (blank for random): " pass
                read -p "Days active: " days
                if id "$user" &>/dev/null; then
                    echo -e "\033[0;31mUser already exists!\033[0m"
                else
                    [ -z "$pass" ] && pass=$(openssl rand -base64 8)
                    useradd -m -s /bin/false -e $(date -d "+$days days" +"%Y-%m-%d") "$user"
                    echo "$user:$pass" | chpasswd
                    echo -e "\033[0;32mUser $user created! Pass: $pass\033[0m"
                fi
                read -p "Press Enter..."
                ;;
            2)
                read -p "Username to delete: " user
                if id "$user" &>/dev/null; then
                    userdel -r "$user" && echo -e "\033[0;32mUser $user deleted.\033[0m"
                else
                    echo "User not found."
                fi
                read -p "Press Enter..."
                ;;
            3)
                read -p "Username to extend: " user
                read -p "Add how many days?: " days
                if id "$user" &>/dev/null; then
                    chage -E $(date -d "+$days days" +"%Y-%m-%d") "$user"
                    echo -e "\033[0;32mUser $user extended by $days days.\033[0m"
                else
                    echo "User not found."
                fi
                read -p "Press Enter..."
                ;;
            4)
                echo "--- Registered SSH Users ---"
                awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd
                read -p "Press Enter..."
                ;;
            5)
                read -p "Enter username for info: " user
                chage -l "$user" 2>/dev/null || echo "User not found."
                read -p "Press Enter..."
                ;;
            6)
                echo "--- Online SSH Users ---"
                ps -ef | grep sshd | grep -v root | grep -v grep | awk '{print $1}' | sort | uniq
                read -p "Press Enter..."
                ;;
            7)
                systemctl restart ssh && echo -e "\033[0;32mSSH Service Restarted.\033[0m"
                read -p "Press Enter..."
                ;;
            8)
                cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak_$(date +%s)"
                echo -e "\033[0;32mSSH configuration backed up.\033[0m"
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
