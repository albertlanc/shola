ssh_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ SSH & SSHWS MANAGER ────────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Create Premium SSH User                       \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Create Trial SSH User (6 Hours)             \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Delete SSH User                             \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m Renew/Extend User                           \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[5]\033[0;36m List SSH Users                              \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
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
                if id "$user" &>/dev/null; then[span_3](start_span)[span_3](end_span)
                    echo -e "│  \033[0;31mUser already exists!\033[0m[span_4](start_span)"[span_4](end_span)
                    echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                    read -p "Press Enter..."; continue[span_5](start_span)[span_5](end_span)
                fi
                
                read -p "│  Max Logins (Devices): " maxlogin
                [ -z "$pass" ] && pass=$(openssl rand -base64 8)[span_6](start_span)[span_6](end_span)
                [ -z "$maxlogin" ] && maxlogin=2[span_7](start_span)[span_7](end_span)
                
                if [ "$ssh_opt" -eq 1 ]; then[span_8](start_span)[span_8](end_span)
                    read -p "│  Days active: " days
                    useradd -m -s /bin/false -e $(date -d "+$days days" +"%Y-%m-%d") "$user[span_9](start_span)"[span_9](end_span)
                    EXP_TEXT="$days Days[span_10](start_span)"[span_10](end_span)
                else
                    useradd -m -s /bin/false "$user[span_11](start_span)"[span_11](end_span)
                    echo "userdel -r -f $user 2>/dev/null" | at now + 6 hours[span_12](start_span)[span_12](end_span)
                    EXP_TEXT="6 Hours (Trial)[span_13](start_span)"[span_13](end_span)
                fi
                
                echo "$user:$pass" | chpasswd[span_14](start_span)[span_14](end_span)
                
                sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf[span_15](start_span)[span_15](end_span)
                echo "$user hard maxlogins $maxlogin" >> /etc/security/limits.conf[span_16](start_span)[span_16](end_span)
                
                IP=$(curl -s4 ifconfig.me)
                DOMAIN=$(ls /etc/ssl/techfeeds/ 2>/dev/null | grep -v "private.key" | head -n 1 | sed 's/.cer//' || echo "$IP")[span_17](start_span)[span_17](end_span)
                [ -z "$DOMAIN" ] && DOMAIN=$IP[span_18](start_span)[span_18](end_span)
                PUBKEY=$(cat /usr/local/bin/server.pub 2>/dev/null || echo "Not Configured")[span_19](start_span)[span_19](end_span)
                NS=$(cat /usr/local/bin/domain 2>/dev/null || echo "Not Configured")[span_20](start_span)[span_20](end_span)
                EXP_DATE=$(chage -l "$user" | grep 'Password expires' | awk -F': ' '{print $2}')[span_21](start_span)[span_21](end_span)
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
                read -p "Press Enter to return...[span_22](start_span)"[span_22](end_span)
                ;;
            3) 
                clear
                echo -e "\033[0;36m┌─ DELETE SSH USER ────────────────────────────────────────\033[0m"
                read -p "│  Username to delete: " user
                userdel -r "$user" 2>/dev/null && sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf && echo -e "│  \033[0;32mDeleted.\033[0m[span_23](start_span)"[span_23](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_24](start_span)"[span_24](end_span)
                ;;
            4) 
                clear
                echo -e "\033[0;36m┌─ RENEW SSH USER ─────────────────────────────────────────\033[0m"
                read -p "│  Username to extend: " user
                read -p "│  Add how many days?: " days
                chage -E $(date -d "+$days days" +"%Y-%m-%d") "$user" 2>/dev/null && echo -e "│  \033[0;32mExtended.\033[0m[span_25](start_span)"[span_25](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_26](start_span)"[span_26](end_span)
                ;;
            5) 
                clear
                echo -e "\033[0;36m┌─ LIST SSH USERS ─────────────────────────────────────────\033[0m"
                awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print "│  " $1 }' /etc/passwd[span_27](start_span)[span_27](end_span)
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_28](start_span)"[span_28](end_span)
                ;;
            0) return ;;
        esac
    done
}
