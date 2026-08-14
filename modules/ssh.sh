ssh_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mSSH & SSHWS Manager\033[0m"
        echo "================================================================"
        echo "1. Create Premium SSH User"
        echo "2. Create Trial SSH User (6 Hours)"
        echo "3. Delete SSH User"
        echo "4. Renew/Extend User"
        echo "5. List SSH Users"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-5]: "
        read -r ssh_opt

        case $ssh_opt in
            1|2)
                read -p "Username: " user
                read -p "Password (blank for random): " pass
                if id "$user" &>/dev/null; then
                    echo -e "\033[0;31mUser already exists!\033[0m"
                    read -p "Press Enter..."; continue
                fi
                
                read -p "Max Logins (Devices): " maxlogin
                [ -z "$pass" ] && pass=$(openssl rand -base64 8)
                [ -z "$maxlogin" ] && maxlogin=2
                
                if [ "$ssh_opt" -eq 1 ]; then
                    read -p "Days active: " days
                    useradd -m -s /bin/false -e $(date -d "+$days days" +"%Y-%m-%d") "$user"
                    EXP_TEXT="$days Days"
                else
                    useradd -m -s /bin/false "$user"
                    echo "userdel -r -f $user 2>/dev/null" | at now + 6 hours
                    EXP_TEXT="6 Hours (Trial)"
                fi
                
                echo "$user:$pass" | chpasswd
                
                # Enforce Max Logins via PAM Limits
                sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf
                echo "$user hard maxlogins $maxlogin" >> /etc/security/limits.conf
                
                # Fetch System Data
                IP=$(curl -s4 ifconfig.me)
                DOMAIN=$(ls /etc/ssl/techfeeds/ 2>/dev/null | grep -v "private.key" | head -n 1 | sed 's/.cer//' || echo "$IP")
                [ -z "$DOMAIN" ] && DOMAIN=$IP
                PUBKEY=$(cat /usr/local/bin/server.pub 2>/dev/null || echo "Not Configured")
                NS=$(cat /usr/local/bin/domain 2>/dev/null || echo "Not Configured")
                EXP_DATE=$(chage -l "$user" | grep 'Password expires' | awk -F': ' '{print $2}')
                
                echo -e "\n=============================================="
                echo -e "\033[1;32m       SSH & SSHWS ACCOUNT CREATED            \033[0m"
                echo -e "=============================================="
                echo -e "Username       : \033[1;37m$user\033[0m"
                echo -e "Password       : \033[1;37m$pass\033[0m"
                echo -e "Expiry Days    : \033[1;33m$EXP_TEXT ($EXP_DATE)\033[0m"
                echo -e "Max Logins     : \033[1;31m$maxlogin Devices\033[0m"
                echo -e "Domain/Host    : \033[1;36m$DOMAIN\033[0m"
                echo -e "Nameserver     : \033[1;36m$NS\033[0m"
                echo -e "SlowDNS PubKey : \033[1;36m$PUBKEY\033[0m"
                echo -e "----------------------------------------------"
                echo -e "\033[1;37m[ ACTIVE PORTS & PROTOCOLS ]\033[0m"
                echo -e "OpenSSH (TCP)  : 22"
                echo -e "SlowDNS (UDP)  : 53"
                echo -e "SSHWS Non-TLS  : 80"
                echo -e "SSHWS TLS (SSL): 443"
                echo -e "----------------------------------------------"
                echo -e "\033[1;37m[ HTTP PAYLOAD (Port 80) ]\033[0m"
                echo -e "\033[36mGET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]\033[0m"
                echo -e "----------------------------------------------"
                echo -e "\033[1;37m[ SSHWS PAYLOAD (Port 80 / 443) ]\033[0m"
                echo -e "\033[36mGET /ssh HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf]Connection: Keep-Alive[crlf][crlf]\033[0m"
                echo -e "=============================================="
                read -p "Press Enter..."
                ;;
            3) read -p "Username to delete: " user; userdel -r "$user" 2>/dev/null && sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf && echo -e "\033[0;32mDeleted.\033[0m"; read -p "Press Enter..." ;;
            4) read -p "Username to extend: " user; read -p "Add how many days?: " days; chage -E $(date -d "+$days days" +"%Y-%m-%d") "$user" 2>/dev/null && echo -e "\033[0;32mExtended.\033[0m"; read -p "Press Enter..." ;;
            5) awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd ; read -p "Press Enter..." ;;
            0) return ;;
        esac
    done
}
