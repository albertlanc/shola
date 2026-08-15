port_change_menu() {
    while true; do
        clear
        # Detect current ports dynamically
        local ssh_port=$(ss -tlnp | grep -w sshd | awk '{print $4}' | awk -F':' '{print $NF}' | head -n 1)
        [ -z "$ssh_port" ] && ssh_port="22"

        local stunnel_port=$(grep -i "accept" /etc/stunnel/stunnel.conf 2>/dev/null | awk -F'=' '{print $2}' | tr -d ' ' | head -n 1)
        [ -z "$stunnel_port" ] && stunnel_port="443"

        local xray_tls=$(jq -r '.inbounds[] | select(.streamSettings.security=="tls") | .port' /usr/local/etc/xray/config.json 2>/dev/null | head -n 1)
        [ -z "$xray_tls" ] && xray_tls="8443"

        local xray_ntls=$(jq -r '.inbounds[] | select(.streamSettings.security=="none") | .port' /usr/local/etc/xray/config.json 2>/dev/null | head -n 1)
        [ -z "$xray_ntls" ] && xray_ntls="8080"

        local dnstt_port="53"

        echo -e "\033[0;36m┌─ PORT-CHANGE MANAGER ────────────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Change SSH Port                  \033[1;33m[$ssh_port]\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Change Stunnel SSL Port          \033[1;33m[$stunnel_port]\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[3]\033[0;36m Change Xray TLS Port             \033[1;33m[$xray_tls]\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[4]\033[0;36m Change Xray Non-TLS Port         \033[1;33m[$xray_ntls]\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[5]\033[0;36m Change SlowDNS Port (UDP)        \033[1;33m[$dnstt_port]\033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-5]: \033[0m"
        read -r p_opt

        case $p_opt in
            1)
                clear
                echo -e "\033[0;36m┌─ CHANGE SSH PORT ────────────────────────────────────────\033[0m"
                read -p "│  Enter new SSH Port: " new_port
                if [[ ! "$new_port" =~ ^[0-9]+$ ]]; then
                    echo -e "│  \033[1;31mInvalid port number!\033[0m"
                else
                    sed -i "s/#Port 22/Port $new_port/g" /etc/ssh/sshd_config
                    sed -i "s/Port [0-9]*/Port $new_port/g" /etc/ssh/sshd_config
                    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
                    ufw allow "$new_port"/tcp >/dev/null 2>&1
                    echo -e "│  \033[0;32m● SUCCESS: SSH port changed to $new_port\033[0m"
                fi
                read -p "Press Enter to return..."
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ CHANGE STUNNEL SSL PORT ────────────────────────────────\033[0m"
                read -p "│  Enter new Stunnel Port: " new_port
                if [[ ! "$new_port" =~ ^[0-9]+$ ]]; then
                    echo -e "│  \033[1;31mInvalid port number!\033[0m"
                else
                    sed -i "s/accept = [0-9]*/accept = $new_port/g" /etc/stunnel/stunnel.conf
                    systemctl restart stunnel4
                    ufw allow "$new_port"/tcp >/dev/null 2>&1
                    echo -e "│  \033[0;32m● SUCCESS: Stunnel port changed to $new_port\033[0m"
                fi
                read -p "Press Enter to return..."
                ;;
            3)
                clear
                echo -e "\033[0;36m┌─ CHANGE XRAY TLS PORT ───────────────────────────────────\033[0m"
                read -p "│  Enter new Xray TLS Port: " new_port
                if [[ ! "$new_port" =~ ^[0-9]+$ ]]; then
                    echo -e "│  \033[1;31mInvalid port number!\033[0m"
                else
                    jq --argjson p "$new_port" '(.inbounds[] | select(.streamSettings.security=="tls")).port = $p' /usr/local/etc/xray/config.json > /tmp/xray_tmp && mv /tmp/xray_tmp /usr/local/etc/xray/config.json
                    systemctl restart xray
                    ufw allow "$new_port"/tcp >/dev/null 2>&1
                    echo -e "│  \033[0;32m● SUCCESS: Xray TLS port changed to $new_port\033[0m"
                fi
                read -p "Press Enter to return..."
                ;;
            4)
                clear
                echo -e "\033[0;36m┌─ CHANGE XRAY NON-TLS PORT ───────────────────────────────\033[0m"
                read -p "│  Enter new Xray Non-TLS Port: " new_port
                if [[ ! "$new_port" =~ ^[0-9]+$ ]]; then
                    echo -e "│  \033[1;31mInvalid port number!\033[0m"
                else
                    jq --argjson p "$new_port" '(.inbounds[] | select(.streamSettings.security=="none")).port = $p' /usr/local/etc/xray/config.json > /tmp/xray_tmp && mv /tmp/xray_tmp /usr/local/etc/xray/config.json
                    systemctl restart xray
                    ufw allow "$new_port"/tcp >/dev/null 2>&1
                    echo -e "│  \033[0;32m● SUCCESS: Xray Non-TLS port changed to $new_port\033[0m"
                fi
                read -p "Press Enter to return..."
                ;;
            5)
                clear
                echo -e "\033[0;36m┌─ CHANGE SLOWDNS PORT ────────────────────────────────────\033[0m"
                read -p "│  Enter new SlowDNS UDP Port: " new_port
                if [[ ! "$new_port" =~ ^[0-9]+$ ]]; then
                    echo -e "│  \033[1;31mInvalid port number!\033[0m"
                else
                    sed -i "s/-udp :[0-9]*/-udp :$new_port/g" /etc/systemd/system/dnstt-server.service
                    systemctl daemon-reload
                    systemctl restart dnstt-server
                    ufw allow "$new_port"/udp >/dev/null 2>&1
                    echo -e "│  \033[0;32m● SUCCESS: SlowDNS UDP port changed to $new_port\033[0m"
                fi
                read -p "Press Enter to return..."
                ;;
            0) return ;;
        esac
    done
}
