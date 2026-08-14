ssl_menu() {
    while true; do
        clear
        echo "================================================================"
        echo -e " \033[1;37mSSL/TLS & Domain Manager\033[0m"
        echo "================================================================"
        echo "1. Install acme.sh (Let's Encrypt Client)"
        echo "2. Issue SSL Certificate (Standalone)"
        echo "3. Renew Certificates"
        echo "4. Check Certificate Status"
        echo "0. Back to Main Menu"
        echo -ne "\nSelect option [0-4]: "
        read -r ssl_opt

        case $ssl_opt in
            1)
                echo "Installing acme.sh..."
                curl https://get.acme.sh | sh
                echo "acme.sh installed."
                read -p "Press Enter..."
                ;;
            2)
                read -p "Enter your domain (e.g., vpn.yourdomain.com): " domain
                echo "Checking port 80 for conflicts..."
                if ss -tuln | grep -q ":80 "; then
                    echo "Port 80 is in use. Please stop the conflicting service first."
                else
                    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --keylength ec-256
                    mkdir -p /usr/local/etc/xray
                    ~/.acme.sh/acme.sh --install-cert -d "$domain" --ecc \
                        --fullchain-file /usr/local/etc/xray/fullchain.cer \
                        --key-file /usr/local/etc/xray/private.key
                    echo "Certificate issued and installed for Xray."
                fi
                read -p "Press Enter..."
                ;;
            3)
                ~/.acme.sh/acme.sh --cron --home ~/.acme.sh
                echo "Certificates renewed (if applicable)."
                read -p "Press Enter..."
                ;;
            4)
                ~/.acme.sh/acme.sh --list
                read -p "Press Enter..."
                ;;
            0) return ;;
            *) echo "Invalid option."; sleep 1 ;;
        esac
    done
}
