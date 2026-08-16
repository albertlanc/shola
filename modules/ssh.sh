ssh_menu() {
    while true; do
        clear
        local SSH_USERS=$(awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd | wc -l)
        local SSH_STAT=$(systemctl is-active --quiet ssh && echo -e "\033[0;32m[ONLINE]\033[0m" || echo -e "\033[0;31m[OFFLINE]\033[0m")
        local RAW_STAT=$(systemctl is-active --quiet ssh && echo "[ONLINE]" || echo "[OFFLINE]")
        
        local L_HEAD="  Total Accounts : ${SSH_USERS}      Service : ${RAW_STAT}"
        local PAD_HEAD=$(( 57 - ${#L_HEAD} ))
        [ $PAD_HEAD -lt 0 ] && PAD_HEAD=0

        echo -e "\033[0;34m ┌── \033[0;33mSSH & SSHWS MANAGER\033[0;34m ──────────────────────────────────┐\033[0m"
        echo -e "\033[0;34m │                                                         │\033[0m"
        echo -e "\033[0;34m │\033[0;36m  Total Accounts : \033[0;32m${SSH_USERS}\033[0;36m      Service : ${SSH_STAT}\033[0m$(printf "%${PAD_HEAD}s" "")\033[0;34m│\033[0m"
        echo -e "\033[0;34m │                                                         │\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mACCOUNT PROVISIONING \033[0;34m──────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m Create Premium SSH User                           \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[02]\033[0;36m Create Trial SSH User (12 Hours)                \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mACCOUNT MANAGEMENT \033[0;34m────────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[03]\033[0;36m Renew / Extend SSH User                         \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[04]\033[0;36m Lock SSH User (Disable Login)                     \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[05]\033[0;36m Unlock SSH User (Enable Login)                    \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[06]\033[0;36m Delete SSH User                                   \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mMONITORING & DIAGNOSTICS \033[0;34m──────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[07]\033[0;36m Live Monitor & Multi-Login Manager                \033[0;34m│\033[0m"
        echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -e ""
        echo -e "\033[0;31m ┌─────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[0;31m │  \033[0;32m[00]\033[0;31m Back to Main Menu                                 \033[0;31m│\033[0m"
        echo -e "\033[0;31m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -ne "\n\033[0;32mSelect an option [00-07]: \033[0m"
        read -r ssh_opt

        case $ssh_opt in
            1|01|2|02)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mACCOUNT CONFIGURATION\033[0;34m ────────────────────────────────┐\033[0m"
                read -p " │  Username: " user
                read -p " │  Password (blank for random): " pass
                if id "$user" &>/dev/null; then
                    echo -e " │  \033[0;31mERROR: User already exists!\033[0m"
                    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                    read -p "Press Enter..."; continue
                fi
                
                read -p " │  Max Logins (Devices): " maxlogin
                read -p " │  Data Quota (e.g. 5GB, 500MB, blank for Unltd): " quota
                
                [ -z "$pass" ] && pass=$(openssl rand -base64 8)
                [ -z "$maxlogin" ] && maxlogin=2
                [ -z "$quota" ] && quota="Unlimited"
                
                if [ "$ssh_opt" = "1" ] || [ "$ssh_opt" = "01" ]; then
                    read -p " │  Days active: " days
                    useradd -m -s /bin/false -e $(date -d "+$days days" +"%Y-%m-%d") "$user"
                    EXP_TEXT="$days Days"
                else
                    useradd -m -s /bin/false "$user"
                    echo "userdel -r -f $user 2>/dev/null" | at now + 12 hours
                    EXP_TEXT="12 Hours (Trial)"
                fi
                
                echo "$user:$pass" | chpasswd
                
                sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf
                echo "$user hard maxlogins $maxlogin" >> /etc/security/limits.conf
                
                # Setup Quota System Tracking
                if [[ "$quota" != "Unlimited" && -n "$quota" ]]; then
                    if [[ "$quota" =~ [Gg][Bb]?$ ]]; then
                        val=$(echo "$quota" | sed -E 's/[Gg][Bb]?//')
                        bytes=$(awk "BEGIN {printf \"%.0f\", $val * 1073741824}")
                    elif [[ "$quota" =~ [Mm][Bb]?$ ]]; then
                        val=$(echo "$quota" | sed -E 's/[Mm][Bb]?//')
                        bytes=$(awk "BEGIN {printf \"%.0f\", $val * 1048576}")
                    else
                        bytes="Unlimited"
                    fi
                    
                    if [ "$bytes" != "Unlimited" ]; then
                        mkdir -p /etc/techfeeds/quota
                        echo "$bytes" > "/etc/techfeeds/quota/$user.limit"
                        echo "0" > "/etc/techfeeds/quota/$user.total"
                        echo "0" > "/etc/techfeeds/quota/$user.last"
                        iptables -I OUTPUT -m owner --uid-owner "$user" 2>/dev/null
                    fi
                fi

                IP=$(curl -s4 ifconfig.me)
                DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || echo "$IP")
                [ -z "$DOMAIN" ] && DOMAIN=$IP
                PUBKEY=$(cat /etc/techfeeds/pubkey.txt 2>/dev/null || echo "Not Configured")
                NS=$(cat /etc/techfeeds/ns 2>/dev/null || echo "Not Configured")
                
                EXP_DATE=$(chage -l "$user" | grep 'Account expires' | awk -F': ' '{print $2}')
                
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                
                clear
                echo -e "\033[0;34m ┌── \033[0;33mSSH & SSHWS ACCOUNT CREATED\033[0;34m ──────────────────────────┐\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Username       : \033[1;37m$user\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Password       : \033[1;37m$pass\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Expiry Days    : \033[1;33m$EXP_TEXT ($EXP_DATE)\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Max Logins     : \033[1;31m$maxlogin Devices\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Data Quota     : \033[1;32m$quota\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Domain/Host    : \033[1;36m$DOMAIN\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Nameserver     : \033[1;36m$NS\033[0m"
                echo -e "\033[0;34m │\033[0;36m  SlowDNS PubKey : \033[1;36m$PUBKEY\033[0m"
                echo -e "\033[0;34m ├─ \033[0;34mACTIVE PORTS & PROTOCOLS \033[0;34m──────────────────────────────┤\033[0m"
                echo -e "\033[0;34m │\033[0;36m  OpenSSH (TCP)  : \033[1;37m22\033[0m"
                echo -e "\033[0;34m │\033[0;36m  SlowDNS (UDP)  : \033[1;37m53\033[0m"
                echo -e "\033[0;34m │\033[0;36m  SSHWS Non-TLS  : \033[1;37m80\033[0m"
                echo -e "\033[0;34m │\033[0;36m  SSHWS TLS (SSL): \033[1;37m443\033[0m"
                echo -e "\033[0;34m ├─ \033[0;34mHTTP PAYLOAD (Port 80) \033[0;34m────────────────────────────────┤\033[0m"
                echo -e "\033[0;34m │\033[0;36m  \033[36mGET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]\033[0m"
                echo -e "\033[0;34m ├─ \033[0;34mSSHWS PAYLOAD (Port 80 / 443) \033[0;34m─────────────────────────┤\033[0m"
                echo -e "\033[0;34m │\033[0;36m  \033[36mGET /ssh HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf]Connection: Keep-Alive[crlf][crlf]\033[0m"
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            3|03) 
                clear
                echo -e "\033[0;34m ┌── \033[0;33mRENEW SSH USER\033[0;34m ───────────────────────────────────────┐\033[0m"
                read -p " │  Username to extend: " user
                if id "$user" &>/dev/null; then
                    read -p " │  Add how many days?: " days
                    chage -E $(date -d "+$days days" +"%Y-%m-%d") "$user" 2>/dev/null
                    
                    if [ -f "/etc/techfeeds/quota/$user.exceeded" ]; then
                        mv "/etc/techfeeds/quota/$user.exceeded" "/etc/techfeeds/quota/$user.limit"
                    fi
                    [ -f "/etc/techfeeds/quota/$user.total" ] && echo "0" > "/etc/techfeeds/quota/$user.total"
                    
                    echo -e " │  \033[0;32m● SUCCESS: Account extended and quota reset.\033[0m"
                else
                    echo -e " │  \033[0;31m● ERROR: User not found.\033[0m"
                fi
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            4|04)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mLOCK SSH USER\033[0;34m ────────────────────────────────────────┐\033[0m"
                read -p " │  Username to lock: " user
                if id "$user" &>/dev/null; then
                    passwd -l "$user" &>/dev/null
                    pkill -u "$user" sshd &>/dev/null
                    echo -e " │  \033[0;32m● SUCCESS: Account locked and kicked offline.\033[0m"
                else
                    echo -e " │  \033[0;31m● ERROR: User not found.\033[0m"
                fi
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            5|05)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mUNLOCK SSH USER\033[0;34m ──────────────────────────────────────┐\033[0m"
                read -p " │  Username to unlock: " user
                if id "$user" &>/dev/null; then
                    passwd -u "$user" &>/dev/null
                    echo -e " │  \033[0;32m● SUCCESS: Account unlocked. Logins restored.\033[0m"
                else
                    echo -e " │  \033[0;31m● ERROR: User not found.\033[0m"
                fi
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            6|06) 
                clear
                echo -e "\033[0;34m ┌── \033[0;33mDELETE SSH USER\033[0;34m ──────────────────────────────────────┐\033[0m"
                read -p " │  Username to delete: " user
                if id "$user" &>/dev/null; then
                    userdel -r "$user" 2>/dev/null
                    sed -i "/^$user hard maxlogins/d" /etc/security/limits.conf
                    rm -f /etc/techfeeds/quota/$user.*
                    iptables -D OUTPUT -m owner --uid-owner "$user" 2>/dev/null
                    echo -e " │  \033[0;32m● SUCCESS: Account, limits, and quotas deleted.\033[0m"
                else
                    echo -e " │  \033[0;31m● ERROR: User not found.\033[0m"
                fi
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            7|07) 
                while true; do
                    clear
                    echo -e "\033[0;34m ┌── \033[0;33mLIVE USERS & MULTI-LOGIN MONITOR\033[0;34m ─────────────────┐\033[0m"
                    echo -e "\033[0;34m │\033[0;36m  USER             SESSIONS     STATUS               \033[0;34m│\033[0m"
                    echo -e "\033[0;34m ├─────────────────────────────────────────────────────────┤\033[0m"
                    
                    TMP_ONLINE=$(mktemp)
                    ps -eo user,comm | grep -E 'sshd|dropbear' | grep -v "^root" | awk '{print $1}' | sort | uniq -c > "$TMP_ONLINE"
                    
                    if [ ! -s "$TMP_ONLINE" ]; then
                        echo -e "\033[0;34m │\033[0;37m  No users are currently online.                         \033[0;34m│\033[0m"
                    else
                        while read count user; do
                            local line="  $user"
                            local pad1=$(( 18 - ${#user} ))
                            [ $pad1 -lt 1 ] && pad1=1
                            line+="$(printf "%${pad1}s" "")"
                            
                            line+="$count"
                            local pad2=$(( 13 - ${#count} ))
                            [ $pad2 -lt 1 ] && pad2=1
                            line+="$(printf "%${pad2}s" "")"
                            
                            if [ "$count" -gt 1 ]; then
                                local raw_stat="MULTI-LOGIN"
                                line+="\033[0;31m${raw_stat}\033[0m"
                            else
                                local raw_stat="NORMAL"
                                line+="\033[0;32m${raw_stat}\033[0m"
                            fi
                            
                            local pad3=$(( 57 - 18 - 13 - ${#raw_stat} ))
                            [ $pad3 -lt 0 ] && pad3=0
                            
                            echo -e "\033[0;34m │\033[1;37m${line}$(printf "%${pad3}s" "")\033[0;34m│\033[0m"
                        done < "$TMP_ONLINE"
                    fi
                    rm -f "$TMP_ONLINE"
                    
                    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                    echo -ne "\n\033[0;32mEnter a Username to manage (or leave blank to return): \033[0m"
                    read -r target_user
                    
                    if [ -z "$target_user" ]; then
                        break
                    fi
                    
                    if id "$target_user" &>/dev/null; then
                        echo -e "\n\033[0;33m Action for $target_user:\033[0m"
                        echo -e " \033[0;36m[1]\033[0m Force Offline (Drop Active Connections)"
                        echo -e " \033[0;36m[2]\033[0m Lock Account  (Force Offline + Prevent Logins)"
                        echo -e " \033[0;36m[3]\033[0m Unlock Account(Set Online / Allow Logins)"
                        echo -ne " \033[0;32mSelect action [1-3]: \033[0m"
                        read -r action
                        case $action in
                            1)
                                pkill -u "$target_user" sshd &>/dev/null
                                echo -e " \033[0;32m● SUCCESS: $target_user has been forced offline.\033[0m"
                                ;;
                            2)
                                passwd -l "$target_user" &>/dev/null
                                pkill -u "$target_user" sshd &>/dev/null
                                echo -e " \033[0;32m● SUCCESS: $target_user is LOCKED and disconnected.\033[0m"
                                ;;
                            3)
                                passwd -u "$target_user" &>/dev/null
                                echo -e " \033[0;32m● SUCCESS: $target_user is UNLOCKED and set online.\033[0m"
                                ;;
                            *)
                                echo -e " \033[0;31m● Action cancelled.\033[0m"
                                ;;
                        esac
                    else
                        echo -e " \033[0;31m● ERROR: User not found in system.\033[0m"
                    fi
                    sleep 2
                done
                ;;
            0|00) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
