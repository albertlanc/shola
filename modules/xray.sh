xray_user_manager() {
    local proto=$1
    while true; do
        clear
        echo -e "\033[0;36m┌─ ${proto^^} MANAGER ───────────────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Create ${proto^^} Account                             \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Delete ${proto^^} Account                             \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m List ${proto^^} Accounts                                \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-3]: \033[0m"
        read -r opt

        local CONF="/usr/local/etc/xray/config.json[span_0](start_span)"[span_0](end_span)
        
        case $opt in
            1)
                clear
                echo -e "\033[0;36m┌─ CREATE ${proto^^} ACCOUNT ───────────────────────────────\033[0m"
                read -p "│  Enter username for ${proto^^}: " user[span_1](start_span)[span_1](end_span)
                local uuid=$(uuidgen)[span_2](start_span)[span_2](end_span)
                echo "│  Generating $proto account for $user with UUID: $uuid...[span_3](start_span)"[span_3](end_span)
                
                if [ -f "$CONF" ]; then[span_4](start_span)[span_4](end_span)
                    jq --arg u "$user" --arg id "$uuid" \
                    '.inbounds[0].settings.clients += [{"id": $id, "email": $u}]' "$CONF" > tmp.json && mv tmp.json "$CONF[span_5](start_span)"[span_5](end_span)
                    systemctl restart xray[span_6](start_span)[span_6](end_span)
                    echo -e "│  \033[0;32m● SUCCESS: $user added and Xray restarted.\033[0m[span_7](start_span)"[span_7](end_span)
                    echo -e "│  UUID: \033[1;33m$uuid\033[0m[span_8](start_span)"[span_8](end_span)
                else
                    echo "│  Error: Xray config not found. Run installer first.[span_9](start_span)"[span_9](end_span)
                fi
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_10](start_span)"[span_10](end_span)
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ DELETE ${proto^^} ACCOUNT ───────────────────────────────\033[0m"
                read -p "│  Enter username to delete: " user[span_11](start_span)[span_11](end_span)
                if [ -f "$CONF" ]; then[span_12](start_span)[span_12](end_span)
                    jq --arg u "$user" \
                    '.inbounds[0].settings.clients |= map(select(.email != $u))' "$CONF" > tmp.json && mv tmp.json "$CONF[span_13](start_span)"[span_13](end_span)
                    systemctl restart xray[span_14](start_span)[span_14](end_span)
                    echo -e "│  \033[0;32m● SUCCESS: $user deleted and Xray restarted.\033[0m[span_15](start_span)"[span_15](end_span)
                fi
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_16](start_span)"[span_16](end_span)
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ ACTIVE ${proto^^} ACCOUNTS ──────────────────────────────\033[0m"
                echo -e "│  --- Active ${proto^^} Accounts ---[span_17](start_span)"[span_17](end_span)
                if [ -f "$CONF" ]; then[span_18](start_span)[span_18](end_span)
                    jq -r '.inbounds[0].settings.clients[] | "│  User: \(.email) - UUID: \(.id)"' "$CONF[span_19](start_span)"[span_19](end_span)
                fi
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return...[span_20](start_span)"[span_20](end_span)
                ;;
            0) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;[span_21](start_span)[span_21](end_span)
        esac
    done
}

vless_menu() { xray_user_manager "vless"; }[span_22](start_span)[span_22](end_span)
vmess_menu() { xray_user_manager "vmess"; }[span_23](start_span)[span_23](end_span)
trojan_menu() { xray_user_manager "trojan"; }[span_24](start_span)[span_24](end_span)
