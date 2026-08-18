openvpn_menu() {
    while true; do
        clear
        echo -e "\033[0;34m ┌── \033[0;33mOPENVPN MANAGER\033[0;34m ──────────────────────────────────────┐\033[0m"
        echo -e "\033[0;34m │\033[0;36m  OpenVPN uses the exact same accounts as SSH. Generate  \033[0;34m│\033[0m"
        echo -e "\033[0;34m │\033[0;36m  the client connection profiles (.ovpn) below.          \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mCONFIGURATION PROFILES \033[0;34m────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m Generate OpenVPN TCP Profile                      \033[0;34m│\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[02]\033[0;36m Generate OpenVPN UDP Profile                      \033[0;34m│\033[0m"
        echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -e ""
        echo -e "\033[0;31m ┌─────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[0;31m │  \033[0;32m[00]\033[0;31m Back to Main Menu                                 \033[0;31m│\033[0m"
        echo -e "\033[0;31m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -ne "\n\033[0;32mSelect option [00-02]: \033[0m"
        read -r opt

        case $opt in
            1|01|2|02)
                clear
                local DOMAIN=$(cat /etc/techfeeds/domain 2>/dev/null || curl -s4 ifconfig.me)
                local CA=$(cat /etc/openvpn/ca.crt 2>/dev/null)
                local TLS=$(cat /etc/openvpn/tls-crypt.key 2>/dev/null)
                
                local PROTO="tcp"
                local PORT=$(awk '/^port / {print $2}' /etc/openvpn/server-tcp.conf 2>/dev/null)
                [ -z "$PORT" ] && PORT="1194"

                if [ "$opt" -eq 2 ] || [ "$opt" -eq 02 ]; then
                    PROTO="udp"
                    PORT=$(awk '/^port / {print $2}' /etc/openvpn/server-udp.conf 2>/dev/null)
                    [ -z "$PORT" ] && PORT="1194"
                fi

                echo -e "\033[0;34m ┌── \033[0;33mOPENVPN $PROTO PROFILE\033[0;34m ─────────────────────────────────┐\033[0m"
                echo -e "\033[0;34m │\033[0;37m Copy the text below and save it as client.ovpn        \033[0;34m│\033[0m"
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                echo -e "\033[0;36m"
                cat <<EOF
client
dev tun
proto $PROTO
remote $DOMAIN $PORT
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
cipher AES-256-GCM
verb 3
<ca>
$CA
</ca>
<tls-crypt>
$TLS
</tls-crypt>
EOF
                echo -e "\033[0m"
                echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
                read -p "Press Enter to return..."
                ;;
            0|00) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
