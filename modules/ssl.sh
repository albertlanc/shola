ssl_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mSSL/TLS & Domain Manager\033[0m"
        echo "================================================================"
        echo "1. Install acme.sh"
        echo "2. Issue & Apply Uniform SSL (Xray, SSH, Dropbear)"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-2]: "
        read -r ssl_opt

        case $ssl_opt in
            1) curl https://get.acme.sh | sh ; read -p "Press Enter..." ;;
            2)
                read -p "Enter your domain (e.g., vpn.yourdomain.com): " domain
                # Stop port 80 momentarily if Xray is using it
                systemctl stop xray 2>/dev/null
                ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --keylength ec-256
                mkdir -p /etc/ssl/techfeeds
                # Apply uniformly and force reload on ALL protocols
                ~/.acme.sh/acme.sh --install-cert -d "$domain" --ecc \
                    --fullchain-file /etc/ssl/techfeeds/fullchain.cer \
                    --key-file /etc/ssl/techfeeds/private.key \
                    --reloadcmd "systemctl restart xray ssh dropbear stunnel4 2>/dev/null"
                echo -e "\033[0;32mCertificate applied uniformly across all server protocols.\033[0m"
                systemctl start xray 2>/dev/null
                read -p "Press Enter..."
                ;;
            0) return ;;
        esac
    done
}
