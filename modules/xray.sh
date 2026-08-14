xray_user_manager() {
    local proto=$1
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37m${proto^^} Manager\033[0m"
        echo "================================================================"
        echo "1. Create ${proto^^} Account"
        echo "2. Delete ${proto^^} Account"
        echo "3. List ${proto^^} Accounts"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-3]: "
        read -r opt

        local CONF="/usr/local/etc/xray/config.json"
        
        case $opt in
            1)
                read -p "Enter username for ${proto^^}: " user
                local uuid=$(uuidgen)
                echo "Generating $proto account for $user with UUID: $uuid..."
                
                # Safely inject user into JSON using jq (prevents syntax breaking)
                if [ -f "$CONF" ]; then
                    jq --arg u "$user" --arg id "$uuid" \
                    '.inbounds[0].settings.clients += [{"id": $id, "email": $u}]' "$CONF" > tmp.json && mv tmp.json "$CONF"
                    systemctl restart xray
                    echo -e "\033[0;32m● SUCCESS: $user added and Xray restarted.\033[0m"
                    echo -e "UUID: \033[1;33m$uuid\033[0m"
                else
                    echo "Error: Xray config not found. Run installer first."
                fi
                read -p "Press Enter..."
                ;;
            2)
                read -p "Enter username to delete: " user
                if [ -f "$CONF" ]; then
                    jq --arg u "$user" \
                    '.inbounds[0].settings.clients |= map(select(.email != $u))' "$CONF" > tmp.json && mv tmp.json "$CONF"
                    systemctl restart xray
                    echo -e "\033[0;32m● SUCCESS: $user deleted and Xray restarted.\033[0m"
                fi
                read -p "Press Enter..."
                ;;
            3)
                echo -e "\n--- Active ${proto^^} Accounts ---"
                if [ -f "$CONF" ]; then
                    jq -r '.inbounds[0].settings.clients[] | "User: \(.email) - UUID: \(.id)"' "$CONF"
                fi
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}

vless_menu() { xray_user_manager "vless"; }
vmess_menu() { xray_user_manager "vmess"; }
trojan_menu() { xray_user_manager "trojan"; }
