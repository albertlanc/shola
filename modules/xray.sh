xray_user_manager() {
    local proto=$1
    while true; do
        clear
        local CONF="/usr/local/etc/xray/config.json"
        local XRAY_USERS=0
        [ -f "$CONF" ] && XRAY_USERS=$(jq -r '.inbounds[].settings.clients[]? | select(.email != null) | .email' "$CONF" 2>/dev/null | sort -u | grep -i "$proto" | wc -l)
        
        local XRAY_STAT=$(systemctl is-active --quiet xray && echo -e "\033[0;32m[ONLINE]\033[0m" || echo -e "\033[0;31m[OFFLINE]\033[0m")
        local RAW_STAT=$(systemctl is-active --quiet xray && echo "[ONLINE]" || echo "[OFFLINE]")
        
        local L_HEAD="  Total Accounts : ${XRAY_USERS}      Service : ${RAW_STAT}"
        local PAD_HEAD=$(( 57 - ${#L_HEAD} ))
        [ $PAD_HEAD -lt 0 ] && PAD_HEAD=0

        echo -e "\033[0;34m ┌── \033[0;33m${proto^^} MANAGER\033[0;34m ────────────────────────────────────────┐\033[0m"
        echo -e "\033[0;34m │                                                         │\033[0m"
        echo -e "\033[0;34m │\033[0;36m  Total Accounts : \033[0;32m${XRAY_USERS}\033[0;36m      Service : ${XRAY_STAT}\033[0m$(printf "%${PAD_HEAD}s" "")\033[0;34m│\033[0m"
        echo -e "\033[0;34m │                                                         │\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mACCOUNT PROVISIONING \033[0;34m──────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m Create Premium Account (TCP TLS - Port 8443)      \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[02]\033[0;36m Create Premium Account (WebSocket - Port 443/80)  \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[03]\033[0;36m Create Trial Account (12 Hours - WS)              \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mACCOUNT MANAGEMENT \033[0;34m────────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[04]\033[0;36m Delete ${proto^^} Account                                \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mMONITORING & DIAGNOSTICS \033[0;34m──────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[05]\033[0;36m List Active ${proto^^} Accounts                          \033[0;34m│\033[0m"
        echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -e ""
        echo -e "\033[0;31m ┌─────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[0;31m │  \033[0;32m[00]\033[0;31m Back to Main Menu                                 \033[0;31m│\033[0m"
        echo -e "\033[0;31m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -ne "\n\033[0;32mSelect option [00-05]: \033[0m"
        read -r opt
        
        case $opt in
            1|01|2|02|3|03)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mCREATE ${proto^^} ACCOUNT\033[0;34m ─────────────────────────────────┐\033[0m"
                read -p " │  Username (No spaces): " raw_user
                local user="${proto}_${raw_user}"
                
                local credential=$(uuidgen)
                local DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || curl -s4 ifconfig.me)
                local PORT=8443
                local INBOUND_IDX=0
                local SECURITY="tls"
                local NET_TYPE="tcp"
                local PATH_VAR="/"
                local TRANSPORT_MODE="tcp"
                
                if [ "$opt" -eq 2 ] || [ "$opt" -eq 3 ] || [ "$opt" -eq 02 ] || [ "$opt" -eq 03 ]; then
                    NET_TYPE="ws"
                    echo -e "\033[0;34m ├─ \033[0;34mWEBSOCKET MODE \033[0;34m──────────────────────────────────────┤\033[0m"
                    echo -e "\033[0;34m │  \033[0;32m[1]\033[0;36m WebSocket TLS (Port 443)                      \033[0;34m│\033[0m"
                    echo -e "\033[0;34m │  \033[0;32m[2]\033[0;36m WebSocket Non-TLS (Port 80)                   \033[0;34m│\033[0m"
                    echo -ne " \033[0;32mSelect WS Mode [1-2]: \033[0m"
                    read -r ws_mode
                    
                    if [ "$ws_mode" -eq 2 ]; then
                        SECURITY="none"
                        PORT=80
                        TRANSPORT_MODE="ws-nontls"
                    else
                        SECURITY="tls"
                        PORT=443
                        TRANSPORT_MODE="ws-tls"
                    fi

                    if [ "$proto" = "vless" ]; then
                        INBOUND_IDX=2
                        PATH_VAR="/vless-ws"
                    elif [ "$proto" = "vmess" ]; then
                        INBOUND_IDX=3
                        PATH_VAR="/vmess-ws"
                    elif [ "$proto" = "trojan" ]; then
                        INBOUND_IDX=4
                        PATH_VAR="/trojan-ws"
                    fi
                else
                    INBOUND_IDX=0
                    NET_TYPE="tcp"
                    SECURITY="tls"
                    PORT=8443
                    PATH_VAR="/"
                    TRANSPORT_MODE="tcp-tls"
                fi

                if [ "$opt" -eq 3 ] || [ "$opt" -eq 03 ]; then
                    local EXP_TEXT="12 Hours (Trial)"
                    local EXP_DATE=$(date -d "+12 hours" +"%Y-%m-%d %H:%M:%S")
                    if [ "$proto" = "trojan" ]; then
                        echo "jq 'del(.inbounds[].settings.clients[] | select(.password==\"$credential\"))' $CONF > /tmp/xray_tmp && mv /tmp/xray_tmp $CONF && systemctl restart xray" | at now + 12 hours >/dev/null 2>&1
                    else
                        echo "jq 'del(.inbounds[].settings.clients[] | select(.id==\"$credential\"))' $CONF > /tmp/xray_tmp && mv /tmp/xray_tmp $CONF && systemctl restart xray" | at now + 12 hours >/dev/null 2>&1
                    fi
                else
                    echo -e "\033[0;34m ├─────────────────────────────────────────────────────────┤\033[0m"
                    read -p " │  Duration (Days): " days
                    local EXP_TEXT="$days Days"
                    local EXP_DATE=$(date -d "+$days days" +"%Y-%m-%d")
                fi
                
                if [ -f "$CONF" ]; then
                    if [ "$proto" = "trojan" ]; then
                        jq --arg p "$credential" --arg u "$user" \
                        ".inbounds[$INBOUND_IDX].settings.clients += [{\"password\": \$p, \"email\": \$u}]" "$CONF" > tmp.json && mv tmp.json "$CONF"
                        
                        if [ "$NET_TYPE" = "ws" ] && [ "$INBOUND_IDX" -ne 4 ]; then
                            jq --arg p "$credential" --arg u "$user" \
                            ".inbounds[4].settings.clients += [{\"password\": \$p, \"email\": \$u}]" "$CONF" > tmp.json && mv tmp.json "$CONF"
                        fi

                        if [ "$TRANSPORT_MODE" = "ws-nontls" ]; then
                            local LINK="trojan://${credential}@${DOMAIN}:${PORT}?type=ws&security=none&path=${PATH_VAR}&host=${DOMAIN}#${user}"
                        elif [ "$TRANSPORT_MODE" = "ws-tls" ]; then
                            local LINK="trojan://${credential}@${DOMAIN}:${PORT}?type=ws&security=tls&path=${PATH_VAR}&sni=${DOMAIN}#${user}"
                        else
                            local LINK="trojan://${credential}@${DOMAIN}:${PORT}?type=tcp&security=tls&sni=${DOMAIN}#${user}"
                        fi
                        
                    elif [ "$proto" = "vmess" ]; then
                        jq --arg id "$credential" --arg u "$user" \
                        ".inbounds[$INBOUND_IDX].settings.clients += [{\"id\": \$id, \"alterId\": 0, \"email\": \$u}]" "$CONF" > tmp.json && mv tmp.json "$CONF"

                        if [ "$NET_TYPE" = "ws" ] && [ "$INBOUND_IDX" -ne 3 ]; then
                            jq --arg id "$credential" --arg u "$user" \
                            ".inbounds[3].settings.clients += [{\"id\": \$id, \"alterId\": 0, \"email\": \$u}]" "$CONF" > tmp.json && mv tmp.json "$CONF"
                        fi
                        
                        local VMESS_JSON="{\"v\":\"2\",\"ps\":\"$user\",\"add\":\"$DOMAIN\",\"port\":\"$PORT\",\"id\":\"$credential\",\"aid\":\"0\",\"net\":\"$NET_TYPE\",\"type\":\"none\",\"host\":\"$DOMAIN\",\"path\":\"$PATH_VAR\",\"tls\":\"${SECURITY}\",\"sni\":\"$DOMAIN\"}"
                        local LINK="vmess://$(echo -n $VMESS_JSON | base64 -w 0)"
                        
                    else
                        jq --arg id "$credential" --arg u "$user" \
                        ".inbounds[$INBOUND_IDX].settings.clients += [{\"id\": \$id, \"email\": \$u}]" "$CONF" > tmp.json && mv tmp.json "$CONF"

                        if [ "$NET_TYPE" = "ws" ] && [ "$INBOUND_IDX" -ne 2 ]; then
                            jq --arg id "$credential" --arg u "$user" \
                            ".inbounds[2].settings.clients += [{\"id\": \$id, \"email\": \$u}]" "$CONF" > tmp.json && mv tmp.json "$CONF"
                        fi
                        
                        if [ "$TRANSPORT_MODE" = "ws-nontls" ]; then
                            local LINK="vless://${credential}@${DOMAIN}:${PORT}?type=ws&security=none&path=${PATH_VAR}&host=${DOMAIN}#${user}"
                        elif [ "$TRANSPORT_MODE" = "ws-tls" ]; then
                            local LINK="vless://${credential}@${DOMAIN}:${PORT}?type=ws&security=tls&path=${PATH_VAR}&sni=${DOMAIN}#${user}"
                        else
                            local LINK="vless://${credential}@${DOMAIN}:${PORT}?type=tcp&security=tls&sni=${DOMAIN}#${user}"
                        fi
                    fi
                    
                    systemctl restart xray
                    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                    
                    clear
                    echo -e "\033[0;34m ┌── \033[0;33m${proto^^} ACCOUNT CREATED SUCCESSFULLY\033[0;34m ──────────────────┐\033[0m"
                    echo -e "\033[0;34m │\033[0;36m  Username     : \033[1;37m$user\033[0m"
                    echo -e "\033[0;34m │\033[0;36m  Domain       : \033[1;36m$DOMAIN\033[0m"
                    echo -e "\033[0;34m │\033[0;36m  Duration     : \033[1;33m$EXP_TEXT\033[0m"
                    echo -e "\033[0;34m │\033[0;36m  Transport    : \033[1;32m$NET_TYPE ($PATH_VAR)\033[0m"
                    echo -e "\033[0;34m │\033[0;36m  Port & Sec   : \033[1;32mPort $PORT ($SECURITY)\033[0m"
                    echo -e "\033[0;34m │\033[0;36m  Expiry Date  : \033[1;31m$EXP_DATE\033[0m"
                    echo -e "\033[0;34m ├─ \033[0;34mCONFIGURATION LINK \033[0;34m────────────────────────────────────┤\033[0m"
                    echo -e "\033[0;34m │  \033[36m$LINK\033[0m"
                    echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                else
                    echo " │  \033[0;31mError: Xray config not found. Run installer first.\033[0m"
                fi
                read -p "Press Enter to return..."
                ;;
            4|04)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mDELETE ${proto^^} ACCOUNT\033[0;34m ─────────────────────────────────┐\033[0m"
                read -p " │  Enter username to delete: " user
                
                # Check if they typed the raw name or the prefixed name
                if [[ "$user" != ${proto}_* ]]; then
                    user="${proto}_${user}"
                fi

                if [ -f "$CONF" ]; then
                    jq --arg u "$user" \
                    '.inbounds[].settings.clients |= map(select(.email != $u))' "$CONF" > tmp.json && mv tmp.json "$CONF"
                    systemctl restart xray
                    echo -e " │  \033[0;32m● SUCCESS: $user deleted and Xray restarted.\033[0m"
                fi
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            5|05)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mACTIVE ${proto^^} ACCOUNTS\033[0;34m ────────────────────────────────┐\033[0m"
                if [ -f "$CONF" ]; then
                    local count=$(jq -r '.inbounds[].settings.clients[]? | select(.email != null) | .email' "$CONF" | sort -u | grep -i "$proto" | wc -l)
                    if [ "$count" -eq 0 ]; then
                        echo -e "\033[0;34m │\033[0;37m  No active $proto accounts found.                     \033[0;34m│\033[0m"
                    else
                        jq -r '.inbounds[].settings.clients[]? | select(.email != null) | .email' "$CONF" | sort -u | grep -i "$proto" | while read -r acc; do
                            echo -e "\033[0;34m │  \033[0;36m👤 User:\033[0m $acc"
                        done
                    fi
                fi
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            0|00) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}

vless_menu() { xray_user_manager "vless"; }
vmess_menu() { xray_user_manager "vmess"; }
trojan_menu() { xray_user_manager "trojan"; }

ss_menu() {
    while true; do
        clear
        echo -e "\033[0;34m ┌── \033[0;33mSHADOWSOCKS MANAGER\033[0;34m ──────────────────────────────────┐\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m Create Shadowsocks Account                        \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[02]\033[0;36m Delete Shadowsocks Account                        \033[0;34m│\033[0m"
        echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -e "\033[0;31m ┌─────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[0;31m │  \033[0;32m[00]\033[0;31m Back to Main Menu                                 \033[0;31m│\033[0m"
        echo -e "\033[0;31m └─────────────────────────────────────────────────────────┘\033[0m"
        
        echo -ne "\n\033[0;32mSelect option [00-02]: \033[0m"
        read -r opt

        case $opt in
            1|01)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mCREATE SHADOWSOCKS ACCOUNT\033[0;34m ───────────────────────────┐\033[0m"
                read -p " │  Username: " user
                read -p " │  Password (blank for secure random): " pass
                [ -z "$pass" ] && pass=$(openssl rand -base64 12)
                
                local CONF="/usr/local/etc/xray/config.json"
                
                # Inject user into both TCP and WebSocket inbounds
                jq --arg user "$user" --arg pass "$pass" '
                (.inbounds[] | select(.tag=="shadowsocks-tcp") | .settings.clients) += [{"email": $user, "password": $pass}] |
                (.inbounds[] | select(.tag=="shadowsocks-ws") | .settings.clients) += [{"email": $user, "password": $pass}]
                ' "$CONF" > /tmp/xray.json && mv /tmp/xray.json "$CONF"
                
                systemctl restart xray
                
                local DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || curl -s4 ifconfig.me)
                local P_TCP=$(jq -r '.inbounds[] | select(.tag=="shadowsocks-tcp") | .port' "$CONF" 2>/dev/null)
                [ -z "$P_TCP" ] && P_TCP="8388"
                local P_MUX="80"
                
                local METHOD="aes-256-gcm"
                local CRED=$(echo -n "${METHOD}:${pass}" | base64 -w 0)
                local LINK_TCP="ss://${CRED}@${DOMAIN}:${P_TCP}#${user}-TCP"
                
                local PLUGIN_OPTS=$(echo -n "obfs=websocket;obfs-host=${DOMAIN};path=/ss-ws" | jq -sRr @uri)
                local LINK_WS="ss://${CRED}@${DOMAIN}:${P_MUX}/?plugin=v2ray-plugin%3B${PLUGIN_OPTS}#${user}-WS"
                
                echo -e "\033[0;34m ├─ \033[0;32mSUCCESS: Account Created\033[0;34m ──────────────────────────────┤\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Username   : \033[1;37m$user\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Password   : \033[1;37m$pass\033[0m"
                echo -e "\033[0;34m │\033[0;36m  Method     : \033[1;37m$METHOD\033[0m"
                echo -e "\033[0;34m ├─ \033[0;34mSHADOWSOCKS TCP LINK (Port $P_TCP) \033[0;34m──────────────────────┤\033[0m"
                echo -e "\033[0;32m$LINK_TCP\033[0m"
                echo -e "\033[0;34m ├─ \033[0;34mSHADOWSOCKS WS LINK (Port 80 via MUX) \033[0;34m─────────────────┤\033[0m"
                echo -e "\033[0;32m$LINK_WS\033[0m"
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            2|02)
                clear
                echo -e "\033[0;34m ┌── \033[0;33mDELETE SHADOWSOCKS ACCOUNT\033[0;34m ───────────────────────────┐\033[0m"
                read -p " │  Username to delete: " user
                local CONF="/usr/local/etc/xray/config.json"
                
                jq --arg user "$user" '
                (.inbounds[] | select(.tag=="shadowsocks-tcp") | .settings.clients) |= map(select(.email != $user)) |
                (.inbounds[] | select(.tag=="shadowsocks-ws") | .settings.clients) |= map(select(.email != $user))
                ' "$CONF" > /tmp/xray.json && mv /tmp/xray.json "$CONF"
                
                systemctl restart xray
                echo -e " │  \033[0;32m● SUCCESS: Account $user deleted.\033[0m"
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            0|00) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
