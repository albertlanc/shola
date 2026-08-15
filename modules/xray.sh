# Ensure the 'at' daemon is installed for Trial Account scheduling
dpkg -s at &>/dev/null || apt-get install -y at >/dev/null 2>&1

xray_user_manager() {
    local proto=$1
    while true; do
        clear
        echo -e "\033[0;36m┌─ ${proto^^} MANAGER (TLS Port: 8443) ───────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Create Premium ${proto^^} Account                   \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Create Trial ${proto^^} Account (6 Hours)           \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Delete ${proto^^} Account                           \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m List ${proto^^} Accounts                            \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-4]: \033[0m"
        read -r opt

        local CONF="/usr/local/etc/xray/config.json"
        
        case $opt in
            1|2)
                clear
                echo -e "\033[0;36m┌─ CREATE ${proto^^} ACCOUNT ───────────────────────────────\033[0m"
                read -p "│  Username: " user
                
                local credential=$(uuidgen)
                local DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || curl -s4 ifconfig.me)
                local PORT=8443
                local PATH_VAR="/"
                
                if [ "$opt" -eq 1 ]; then
                    read -p "│  Duration (Days): " days
                    local EXP_TEXT="$days Days"
                    local EXP_DATE=$(date -d "+$days days" +"%Y-%m-%d")
                else
                    local EXP_TEXT="6 Hours (Trial)"
                    local EXP_DATE=$(date -d "+6 hours" +"%Y-%m-%d %H:%M:%S")
                    if [ "$proto" = "trojan" ]; then
                        echo "jq 'del(.inbounds[0].settings.clients[] | select(.password==\"$credential\"))' $CONF > /tmp/xray_tmp && mv /tmp/xray_tmp $CONF && systemctl restart xray" | at now + 6 hours >/dev/null 2>&1
                    else
                        echo "jq 'del(.inbounds[0].settings.clients[] | select(.id==\"$credential\"))' $CONF > /tmp/xray_tmp && mv /tmp/xray_tmp $CONF && systemctl restart xray" | at now + 6 hours >/dev/null 2>&1
                    fi
                fi
                
                if [ -f "$CONF" ]; then
                    if [ "$proto" = "trojan" ]; then
                        jq --arg p "$credential" --arg u "$user" \
                        '.inbounds[0].settings.clients += [{"password": $p, "email": $u}]' "$CONF" > tmp.json && mv tmp.json "$CONF"
                        local LINK="trojan://${credential}@${DOMAIN}:${PORT}?type=tcp&security=tls&sni=${DOMAIN}#${user}"
                    elif [ "$proto" = "vmess" ]; then
                        jq --arg id "$credential" --arg u "$user" \
                        '.inbounds[0].settings.clients += [{"id": $id, "alterId": 0, "email": $u}]' "$CONF" > tmp.json && mv tmp.json "$CONF"
                        local VMESS_JSON="{\"v\":\"2\",\"ps\":\"$user\",\"add\":\"$DOMAIN\",\"port\":\"$PORT\",\"id\":\"$credential\",\"aid\":\"0\",\"net\":\"tcp\",\"type\":\"none\",\"host\":\"$DOMAIN\",\"path\":\"$PATH_VAR\",\"tls\":\"tls\",\"sni\":\"$DOMAIN\"}"
                        local LINK="vmess://$(echo -n $VMESS_JSON | base64 -w 0)"
                    else
                        jq --arg id "$credential" --arg u "$user" \
                        '.inbounds[0].settings.clients += [{"id": $id, "email": $u}]' "$CONF" > tmp.json && mv tmp.json "$CONF"
                        local LINK="vless://${credential}@${DOMAIN}:${PORT}?type=tcp&security=tls&sni=${DOMAIN}#${user}"
                    fi
                    
                    systemctl restart xray
                    
                    clear
                    echo -e "\033[0;36m┌─ ${proto^^} ACCOUNT CREATED SUCCESSFULLY ──────────────────\033[0m"
                    echo -e "\033[0;36m│  Username     : \033[1;37m$user\033[0m"
                    echo -e "\033[0;36m│  Domain       : \033[1;36m$DOMAIN\033[0m"
                    echo -e "\033[0;36m│  Duration     : \033[1;33m$EXP_TEXT\033[0m"
                    echo -e "\033[0;36m│  Path         : \033[1;37m$PATH_VAR\033[0m"
                    echo -e "\033[0;36m│  Expiry Date  : \033[1;31m$EXP_DATE\033[0m"
                    echo -e "\033[0;36m├─ CONFIGURATION LINK (Copy below) ────────────────────────\033[0m"
                    echo -e "\033[0;36m│  \033[36m$LINK\033[0m"
                    echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                else
                    echo "│  Error: Xray config not found. Run installer first."
                fi
                read -p "Press Enter to return..."
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ DELETE ${proto^^} ACCOUNT ───────────────────────────────\033[0m"
                read -p "│  Enter username to delete: " user
                if [ -f "$CONF" ]; then
                    jq --arg u "$user" \
                    '.inbounds[0].settings.clients |= map(select(.email != $u))' "$CONF" > tmp.json && mv tmp.json "$CONF"
                    systemctl restart xray
                    echo -e "│  \033[0;32m● SUCCESS: $user deleted and Xray restarted.\033[0m"
                fi
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ ACTIVE ${proto^^} ACCOUNTS ──────────────────────────────\033[0m"
                if [ -f "$CONF" ]; then
                    jq -r '.inbounds[0].settings.clients[] | "│  User: \(.email)"' "$CONF"
                fi
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}

vless_menu() { xray_user_manager "vless"; }
vmess_menu() { xray_user_manager "vmess"; }
trojan_menu() { xray_user_manager "trojan"; }
