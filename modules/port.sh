port_change_menu() {
    while true; do
        clear
        
        # Read Live Ports from Configs
        local P_SSH="22" # Fixed System default
        local P_WS=$(awk '/bind/ {print $2}' /usr/local/bin/ws-proxy.py 2>/dev/null | grep -o "[0-9]*" | head -n 1)
        local P_STUNNEL=$(awk '/accept =/ {print $3}' /etc/stunnel/stunnel.conf 2>/dev/null | head -n 1)
        
        local CONF="/usr/local/etc/xray/config.json"
        local P_VLESS_TCP=$(jq -r '.inbounds[] | select(.tag=="vless-tls") | .port' "$CONF" 2>/dev/null)
        local P_SS_TCP=$(jq -r '.inbounds[] | select(.tag=="shadowsocks-tcp") | .port' "$CONF" 2>/dev/null)
        local P_MUX=$(jq -r '.inbounds[] | select(.tag=="multiplexer-tcp") | .port' "$CONF" 2>/dev/null)
        
        local P_OVPN_TCP=$(awk '/^port / {print $2}' /etc/openvpn/server-tcp.conf 2>/dev/null)
        local P_OVPN_UDP=$(awk '/^port / {print $2}' /etc/openvpn/server-udp.conf 2>/dev/null)
        local P_HY2=$(awk '/listen:/ {print $2}' /etc/hysteria/config.yaml 2>/dev/null | grep -o "[0-9]*")
        local P_UDPC=$(grep -oE -- '-l :[0-9]+' /etc/systemd/system/udp-custom.service 2>/dev/null | cut -d':' -f2)

        [ -z "$P_WS" ] && P_WS="8080"
        [ -z "$P_STUNNEL" ] && P_STUNNEL="443"
        [ -z "$P_VLESS_TCP" ] && P_VLESS_TCP="8443"
        [ -z "$P_SS_TCP" ] && P_SS_TCP="8388"
        [ -z "$P_MUX" ] && P_MUX="80"
        [ -z "$P_OVPN_TCP" ] && P_OVPN_TCP="1194"
        [ -z "$P_OVPN_UDP" ] && P_OVPN_UDP="1194"
        [ -z "$P_HY2" ] && P_HY2="443"
        [ -z "$P_UDPC" ] && P_UDPC="36712"

        echo -e "\033[0;34m ┌── \033[0;33mSERVER PORT MANAGER\033[0;34m ──────────────────────────────────────┐\033[0m"
        echo -e "\033[0;34m │\033[0;36m  Manage and modify your active protocol ports.            \033[0;34m│\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mCORE SERVICES (TCP) \033[0;34m───────────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[01]\033[0;36m OpenSSH                 : \033[1;37m$P_SSH\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[02]\033[0;36m Stunnel (TLS)           : \033[1;37m$P_STUNNEL\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[03]\033[0;36m WebSocket Proxy         : \033[1;37m$P_WS\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[04]\033[0;36m Xray MUX (WS/HTTP)      : \033[1;37m$P_MUX\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mADVANCED PROTOCOLS (TCP) \033[0;34m──────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[05]\033[0;36m Xray VLESS (TCP/TLS)    : \033[1;37m$P_VLESS_TCP\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[06]\033[0;36m Shadowsocks (TCP)       : \033[1;37m$P_SS_TCP\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[07]\033[0;36m OpenVPN (TCP)           : \033[1;37m$P_OVPN_TCP\033[0m"
        echo -e "\033[0;34m ├─ \033[0;34mADVANCED PROTOCOLS (UDP) \033[0;34m──────────────────────────────┤\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[08]\033[0;36m OpenVPN (UDP)           : \033[1;37m$P_OVPN_UDP\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[09]\033[0;36m Hysteria V2 (UDP)       : \033[1;37m$P_HY2\033[0m"
        echo -e "\033[0;34m │  \033[0;32m[10]\033[0;36m UDP Custom Forwarder    : \033[1;37m$P_UDPC\033[0m"
        echo -e "\033[0;34m └─────────────────────────────────────────────────────────┘\033[0m"
        echo -e ""
        echo -e "\033[0;31m ┌─────────────────────────────────────────────────────────┐\033[0m"
        echo -e "\033[0;31m │  \033[0;32m[00]\033[0;31m Back to Main Menu                                 \033[0;31m│\033[0m"
        echo -e "\033[0;31m └─────────────────────────────────────────────────────────┘\033[0m"
        
        echo -ne "\n\033[0;32mSelect port to change [00-10]: \033[0m"
        read -r choice
        
        case $choice in
            1|01)
                echo -e " \033[0;31mNotice: Changing SSH port is highly risky. We recommend keeping it on 22.\033[0m"; sleep 2 ;;
            2|02)
                read -p " Enter new Stunnel (TLS) port: " new_port
                sed -i -E "s/accept = [0-9]+/accept = $new_port/" /etc/stunnel/stunnel.conf
                ufw allow $new_port/tcp > /dev/null 2>&1
                systemctl restart stunnel4
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            3|03)
                read -p " Enter new WS Proxy port: " new_port
                sed -i -E "s/bind\(\('127.0.0.1', [0-9]+\)\)/bind(('127.0.0.1', $new_port))/" /usr/local/bin/ws-proxy.py
                ufw allow $new_port/tcp > /dev/null 2>&1
                systemctl restart ws-proxy
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            4|04)
                read -p " Enter new Xray MUX port: " new_port
                jq --argjson p "$new_port" '(.inbounds[] | select(.tag=="multiplexer-tcp") | .port) = $p' "$CONF" > tmp.json && mv tmp.json "$CONF"
                ufw allow $new_port/tcp > /dev/null 2>&1
                systemctl restart xray
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            5|05)
                read -p " Enter new Xray VLESS (TCP/TLS) port: " new_port
                jq --argjson p "$new_port" '(.inbounds[] | select(.tag=="vless-tls") | .port) = $p' "$CONF" > tmp.json && mv tmp.json "$CONF"
                ufw allow $new_port/tcp > /dev/null 2>&1
                systemctl restart xray
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            6|06)
                read -p " Enter new Shadowsocks (TCP) port: " new_port
                jq --argjson p "$new_port" '(.inbounds[] | select(.tag=="shadowsocks-tcp") | .port) = $p' "$CONF" > tmp.json && mv tmp.json "$CONF"
                ufw allow $new_port/tcp > /dev/null 2>&1
                systemctl restart xray
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            7|07)
                read -p " Enter new OpenVPN (TCP) port: " new_port
                sed -i -E "s/^port [0-9]+/port $new_port/" /etc/openvpn/server-tcp.conf
                ufw allow $new_port/tcp > /dev/null 2>&1
                systemctl restart openvpn@server-tcp
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            8|08)
                read -p " Enter new OpenVPN (UDP) port: " new_port
                sed -i -E "s/^port [0-9]+/port $new_port/" /etc/openvpn/server-udp.conf
                ufw allow $new_port/udp > /dev/null 2>&1
                systemctl restart openvpn@server-udp
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            9|09)
                read -p " Enter new Hysteria V2 (UDP) port: " new_port
                sed -i -E "s/listen: :[0-9]+/listen: :$new_port/" /etc/hysteria/config.yaml
                ufw allow $new_port/udp > /dev/null 2>&1
                systemctl restart hysteria-server
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            10)
                read -p " Enter new UDP Custom Forwarder port: " new_port
                sed -i -E "s/-l :[0-9]+/-l :$new_port/" /etc/systemd/system/udp-custom.service
                sed -i -E "s/-exclude [0-9]+/-exclude $new_port/" /etc/systemd/system/udp-custom.service
                ufw allow $new_port/udp > /dev/null 2>&1
                systemctl daemon-reload
                systemctl restart udp-custom
                echo -e " \033[0;32m● Port updated to $new_port successfully.\033[0m"; sleep 2 ;;
            0|00) return ;;
            *) echo -e "\033[1;31mInvalid option.\033[0m"; sleep 1 ;;
        esac
    done
}
