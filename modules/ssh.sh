ssh_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ SSH & SSHWS MANAGER ────────────────────────────────────\033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Create Premium SSH User                       \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Create Trial SSH User (6 Hours)             \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Delete SSH User                             \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m Renew/Extend User                           \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[5]\033[0;36m List SSH Users                              \033[0m"
        echo -e "\033[0;36m├──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-5]: \033[0m"
        read -r ssh_opt

        case $ssh_opt in
            1|2)
                clear
                echo -e "\033[0;36m┌─ ACCOUNT CONFIGURATION ──────────────────────────────────\033[0m"
                read -p "│  Username: " user
                read -p "│  Password (blank for random): " pass
                if id "$user" &>/dev/null; then
                    echo -e "│  \033[0;31mUser already exists!\033[0m"
                    echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                    read -p "Press Enter..."; continue
                fi
                
                read -p "│  Max Logins (Devices): " maxlogin
                [ -z "$pass" ] && pass=$(openssl rand -base64 8)
                [ -z "$maxlogin" ] && maxlogin=2
                
                if [ "$ssh_opt" -eq 1 ]; then
                    read -p "│  Days active: " days
                    useradd -m -s /bin/false -e $(date -d "+$days days" +"%Y-%m-%d") "$user"
                    EXP_TEXT="$days Days"
                else
                    useradd -m -s /bin/false "$user"
                    echo "userdel -r -f $user 2>/dev/null" | at now + 6 hours
                    EXP_TEXT="6 Hours (Trial)"
                fi
                
                echo "$user:$pass" | chpasswd
                
                sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf
                echo "$user hard maxlogins $maxlogin" >> /etc/security/limits.conf
                
                # FIXED: Read from correct installer paths instead of hacking SSL directory
                IP=$(curl -s4 ifconfig.me)
                DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || echo "$IP")
                [ -z "$DOMAIN" ] && DOMAIN=$IP
                PUBKEY=$(cat /etc/techfeeds/pubkey.txt 2>/dev/null || echo "Not Configured")
                NS=$(cat /etc/techfeeds/ns 2>/dev/null || echo "Not Configured")
                
                # FIXED: Search for Account Expiry instead of Password Expiry
                EXP_DATE=$(chage -l "$user" | grep 'Account expires' | awk -F': ' '{print $2}')
                
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                
                clear
                echo -e "\033[0;36m┌─ SSH & SSHWS ACCOUNT CREATED ────────────────────────────\033[0m"
                echo -e "\033[0;36m│  Username       : \033[1;37m$user\033[0m"
                echo -e "\033[0;36m│  Password       : \033[1;37m$pass\033[0m"
                echo -e "\033[0;36m│  Expiry Days    : \033[1;33m$EXP_TEXT ($EXP_DATE)\033[0m"
                echo -e "\033[0;36m│  Max Logins     : \033[1;31m$maxlogin Devices\033[0m"
                echo -e "\033[0;36m│  Domain/Host    : \033[1;36m$DOMAIN\033[0m"
                echo -e "\033[0;36m│  Nameserver     : \033[1;36m$NS\033[0m"
                echo -e "\033[0;36m│  SlowDNS PubKey : \033[1;36m$PUBKEY\033[0m"
                echo -e "\033[0;36m├─ ACTIVE PORTS & PROTOCOLS ───────────────────────────────\033[0m"
                echo -e "\033[0;36m│  OpenSSH (TCP)  : 22\033[0m"
                echo -e "\033[0;36m│  SlowDNS (UDP)  : 53\033[0m"
                echo -e "\033[0;36m│  SSHWS Non-TLS  : 80\033[0m"
                echo -e "\033[0;36m│  SSHWS TLS (SSL): 443\033[0m"
                echo -e "\033[0;36m├─ HTTP PAYLOAD (Port 80) ─────────────────────────────────\033[0m"
                echo -e "\033[0;36m│  \033[36mGET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]\033[0m"
                echo -e "\033[0;36m├─ SSHWS PAYLOAD (Port 80 / 443) ──────────────────────────\033[0m"
                echo -e "\033[0;36m│  \033[36mGET /ssh HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf]Connection: Keep-Alive[crlf][crlf]\033[0m"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            3) 
                clear
                echo -e "\033[0;36m┌─ DELETE SSH USER ────────────────────────────────────────\033[0m"
                read -p "│  Username to delete: " user
                userdel -r "$user" 2>/dev/null && sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf && echo -e "│  \033[0;32mDeleted.\033[0m"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            4) 
                clear
                echo -e "\033[0;36m┌─ RENEW SSH USER ─────────────────────────────────────────\033[0m"
                read -p "│  Username to extend: " user
                read -p "│  Add how many days?: " days
                chage -E $(date -d "+$days days" +"%Y-%m-%d") "$user" 2>/dev/null && echo -e "│  \033[0;32mExtended.\033[0m"
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            5) 
                clear
                echo -e "\033[0;36m┌─ LIST SSH USERS ─────────────────────────────────────────\033[0m"
                awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print "│  " $1 }' /etc/passwd
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            0) return ;;
        esac
    done
}
