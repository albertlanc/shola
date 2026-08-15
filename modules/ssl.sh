ssl_menu() {
    while true; do
        clear
        echo -e "\033[0;36m┌─ SSL/TLS & DOMAIN MANAGER ───────────────────────────────\033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[1]\033[0;36m Install acme.sh                                       \033[0m"
        echo -e "\033[0;36m│                                                          \033[0m"
        echo -e "\033[0;36m│  \033[0;32m[2]\033[0;36m Issue & Apply Uniform SSL (Xray, SSH, Dropbear)       \033[0m"
        echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m┌──────────────────────────────────────────────────────────\033[0m"
        echo -e "\033[0;31m│  [0] Back to Main Menu                                   \033[0m"
        echo -e "\033[0;31m└──────────────────────────────────────────────────────────\033[0m"
        echo -ne "\n\033[0;32mSelect option [0-2]: \033[0m"
        read -r ssl_opt

        case $ssl_opt in
            1) 
                clear
                echo -e "\033[0;36m┌─ INSTALLING ACME.SH ─────────────────────────────────────\033[0m"
                curl https://get.acme.sh | sh
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            2)
                clear
                echo -e "\033[0;36m┌─ UNIFORM SSL ISSUANCE ───────────────────────────────────\033[0m"
                read -p "│  Enter your domain (e.g., vpn.yourdomain.com): " domain
                systemctl stop xray 2>/dev/null
                ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --keylength ec-256
                mkdir -p /etc/ssl/techfeeds
                ~/.acme.sh/acme.sh --install-cert -d "$domain" --ecc \
                    --fullchain-file /etc/ssl/techfeeds/fullchain.cer \
                    --key-file /etc/ssl/techfeeds/private.key \
                    --reloadcmd "systemctl restart xray ssh dropbear stunnel4 2>/dev/null"
                echo -e "│  \033[0;32mCertificate applied uniformly across all server protocols.\033[0m"
                systemctl start xray 2>/dev/null
                echo -e "\033[0;36m└──────────────────────────────────────────────────────────\033[0m"
                read -p "Press Enter to return..."
                ;;
            0) return ;;
        esac
    done
}
